import { startOfDay } from "date-fns";
import { useCallback, useEffect, useLayoutEffect, useMemo, useRef, useState, type MouseEvent, type PointerEvent } from "react";
import { StoreContext, useBoard, useBoardStore, ViewContext, type BoardView } from "./context";
import { isFormControl, startDrag } from "./drag";
import { Header } from "./Header";
import { PlanPanel, PreviewRow } from "./PlanPanel";
import { ProjectPanel } from "./ProjectPanel";
import { dateLocale, t } from "./i18n";
import { ProjectRow } from "./ProjectRow";
import { createBoardStore } from "./store";
import {
  buildTimeline,
  clampScale,
  dateAt,
  dayOffChecker,
  fitAll,
  nextColorIndex,
  fitScale,
  projectMiddle,
  SCALE,
  scaleMode,
  stepScale,
  timelineColumns,
  timelineWidth,
  toggleScale,
  xOf,
  viewCenter,
} from "./timeline";
import { TimelineGrid } from "./TimelineGrid";
import type { BoardData } from "./types";

/** Vertical space the rows block does not get: date header and row paddings (board.css). */
const ROWS_CHROME = 56 + 40 + 60;

export function App({ initial }: { initial: BoardData }) {
  const [store] = useState(() => createBoardStore(initial));
  return (
    <StoreContext.Provider value={store}>
      <Board />
    </StoreContext.Provider>
  );
}

function Board() {
  const store = useBoardStore();
  const projects = useBoard((state) => state.projects);
  const pixelsPerDay = useBoard((state) => state.pixelsPerDay);
  const selectedId = useBoard((state) => state.selectedId);
  const editing = useBoard((state) => state.editingEventId !== null || state.renamingId !== null || state.draftId !== null);
  const draftId = useBoard((state) => state.draftId);
  const toast = useBoard((state) => state.toast);
  const calendar = useBoard((state) => state.calendar);
  const planPreview = useBoard((state) => state.planPreview);
  const planEnabled = useBoard((state) => state.features.plan_from_text);
  const setPlanOpen = useBoard((state) => state.setPlanOpen);
  const dismissToast = useBoard((state) => state.dismissToast);

  const viewportRef = useRef<HTMLDivElement>(null);
  const rowsRef = useRef<HTMLDivElement>(null);
  const [viewportWidth, setViewportWidth] = useState(() => window.innerWidth);
  const [scrollLeft, setScrollLeft] = useState(0);
  // The "now" line moves by itself while the page stays open; today follows midnight.
  const [now, setNow] = useState(() => new Date());
  useEffect(() => {
    const timer = window.setInterval(() => setNow(new Date()), 60_000);
    return () => window.clearInterval(timer);
  }, []);
  const day = startOfDay(now).getTime();
  const today = useMemo(() => new Date(day), [day]);

  const timeline = useMemo(
    () =>
      buildTimeline({
        projects: planPreview ? [...projects, ...planPreview.projects.map(previewRange)] : projects,
        today,
        pixelsPerDay,
        viewportWidth,
      }),
    [projects, planPreview, today, pixelsPerDay, viewportWidth],
  );
  const isDayOff = useMemo(() => (calendar.dim ? dayOffChecker(calendar) : undefined), [calendar]);
  const columns = useMemo(() => timelineColumns(timeline, today, dateLocale(), isDayOff), [timeline, today, isDayOff]);
  const width = timelineWidth(timeline);
  const mode = scaleMode(pixelsPerDay);
  const compact = mode === "days" && pixelsPerDay <= SCALE.COMPACT_DAYS_AT;

  // Keep the remembered moment in the middle of the screen whenever the zoom,
  // the timeline origin or the viewport width changes. On opening, a view of
  // today drops the empty past on its left (viewCenter).
  const originTime = timeline.origin.getTime();
  const opening = useRef(true);
  useLayoutEffect(() => {
    const viewport = viewportRef.current;
    if (!viewport) return;
    if (opening.current) {
      opening.current = false;
      const state = store.getState();
      const center = viewCenter(state.currentDate, { projects: state.projects, today, pixelsPerDay, viewportWidth: viewport.clientWidth });
      if (center !== state.currentDate) state.setView({ currentDate: center });
    }
    const { currentDate } = store.getState();
    viewport.scrollLeft = xOf(timeline, currentDate) - viewport.clientWidth / 2;
    setScrollLeft(viewport.scrollLeft);
  }, [pixelsPerDay, originTime, viewportWidth]);

  // Restore the vertical scroll once, and track the viewport width.
  useLayoutEffect(() => {
    const viewport = viewportRef.current;
    if (!viewport) return;
    viewport.scrollTop = store.getState().scrollTop;
    const observer = new ResizeObserver(() => setViewportWidth(viewport.clientWidth));
    observer.observe(viewport);
    return () => observer.disconnect();
  }, [store]);

  const onScroll = () => {
    const viewport = viewportRef.current;
    if (!viewport) return;
    setScrollLeft(viewport.scrollLeft);
    const middle = dateAt(timeline, viewport.scrollLeft + viewport.clientWidth / 2);
    const state = store.getState();
    const moved = Math.abs(middle.getTime() - state.currentDate.getTime()) > 60_000;
    if (moved || Math.abs(viewport.scrollTop - state.scrollTop) >= 1) {
      state.setView({ currentDate: moved ? middle : state.currentDate, scrollTop: viewport.scrollTop });
    }
  };

  const timelineX = useCallback((clientX: number) => {
    const viewport = viewportRef.current;
    if (!viewport) return 0;
    return clientX - viewport.getBoundingClientRect().left + viewport.scrollLeft;
  }, []);

  const goToDate = useCallback(
    (date: Date) => {
      const viewport = viewportRef.current;
      if (!viewport) return;
      viewport.scrollTo({ left: xOf(timeline, date) - viewport.clientWidth / 2, behavior: "smooth" });
    },
    [timeline],
  );

  const goToToday = useCallback(() => {
    const viewport = viewportRef.current;
    if (!viewport) return;
    const { projects: rows, pixelsPerDay: ppd } = store.getState();
    goToDate(viewCenter(new Date(), { projects: rows, today, pixelsPerDay: ppd, viewportWidth: viewport.clientWidth }));
  }, [store, today, goToDate]);

  const showProject = useCallback(
    (id: number) => {
      const state = store.getState();
      const card = state.projects.find((project) => project.id === id);
      const viewport = viewportRef.current;
      if (!card || !viewport) return;
      state.select(id);
      state.setScale(fitScale(card, viewport.clientWidth), projectMiddle(card));
      requestAnimationFrame(() =>
        viewport.querySelector(`[data-project-id="${id}"]`)?.scrollIntoView({ block: "center", behavior: "smooth" }),
      );
    },
    [store],
  );

  // The logo shows the whole board: the largest zoom at which every project
  // fits the width and every row fits the height.
  const fitRanges = useCallback(
    (ranges: { started_on: string; finished_on: string }[]) => {
      const viewport = viewportRef.current;
      if (!viewport) return;
      const state = store.getState();
      const fit = fitAll({ projects: ranges, viewportWidth: viewport.clientWidth, rowsHeight: viewport.clientHeight - ROWS_CHROME });
      if (fit) state.setScale(fit.pixelsPerDay, fit.middle);
      else state.setScale(SCALE.DAYS, new Date());
      viewport.scrollTo({ top: 0, behavior: "smooth" });
    },
    [store],
  );

  // A new visitor sees the whole plan at once, as after a click on the logo.
  useEffect(() => {
    if (store.getState().freshView) fitRanges(store.getState().projects);
  }, [store, fitRanges]);

  const showAll = useCallback(() => {
    store.getState().select(null);
    fitRanges(store.getState().projects);
  }, [store, fitRanges]);

  const newProject = useCallback(() => {
    const viewport = viewportRef.current;
    const state = store.getState();
    viewport?.scrollTo({ top: 0, behavior: "smooth" });
    state.startDraft(startOfDay(state.currentDate), 0);
  }, [store]);

  // Zoom with ctrl/cmd + wheel (and trackpad pinch), keeping the date under the pointer still.
  useEffect(() => {
    const viewport = viewportRef.current;
    if (!viewport) return;
    const onWheel = (event: WheelEvent) => {
      if (!event.ctrlKey && !event.metaKey) return;
      event.preventDefault();
      const state = store.getState();
      const pointerX = event.clientX - viewport.getBoundingClientRect().left;
      const pointerDate = dateAt(timeline, viewport.scrollLeft + pointerX);
      const next = clampScale(state.pixelsPerDay * Math.exp(-event.deltaY * 0.01));
      if (next === state.pixelsPerDay) return;
      const middleShiftDays = (viewport.clientWidth / 2 - pointerX) / next;
      state.setScale(next, new Date(pointerDate.getTime() + middleShiftDays * 86_400_000));
    };
    viewport.addEventListener("wheel", onWheel, { passive: false });
    return () => viewport.removeEventListener("wheel", onWheel);
  }, [store, timeline]);

  // Keyboard shortcuts (see Keystrokes.md).
  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      // Fields handle their own keys; Esc still works from a focused button
      // (e.g. "Details" right after opening the dialog).
      const typing = event.target instanceof HTMLElement && event.target.closest("input, textarea, select, [contenteditable]") !== null;
      if ((event.key === "Escape" ? typing : isFormControl(event.target)) || event.metaKey || event.ctrlKey || event.altKey) return;
      const state = store.getState();
      switch (event.key) {
        case "+":
        case "=":
          state.setScale(stepScale(state.pixelsPerDay, 1));
          break;
        case "-":
          state.setScale(stepScale(state.pixelsPerDay, -1));
          break;
        case "0":
          state.setScale(toggleScale(state.pixelsPerDay));
          break;
        case " ":
          goToToday();
          break;
        case "Enter":
          newProject();
          break;
        case "Escape":
          if (state.editingEventId !== null) state.editEvent(null);
          else if (state.draftId !== null) state.cancelDraft();
          else if (state.panelOpen) state.openPanel(false);
          else state.select(null);
          break;
        default:
          return;
      }
      event.preventDefault();
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [store, goToToday, newProject]);

  // Save the view state when the page is left before the debounce fires.
  useEffect(() => {
    const flush = () => store.getState().flush();
    window.addEventListener("pagehide", flush);
    return () => window.removeEventListener("pagehide", flush);
  }, [store]);

  // A share link redirects here with ?focus=<row id>: show that project.
  useEffect(() => {
    const url = new URL(window.location.href);
    const focus = Number(url.searchParams.get("focus"));
    if (!focus) return;
    url.searchParams.delete("focus");
    window.history.replaceState(null, "", url);
    showProject(focus);
  }, [showProject]);

  // Drag on empty space (or a project bar) pans the board in both directions.
  // Touch screens scroll natively instead.
  const onPointerDown = (pointer: PointerEvent) => {
    const viewport = viewportRef.current;
    if (!viewport || pointer.pointerType === "touch" || isFormControl(pointer.target)) return;
    const origin = { left: viewport.scrollLeft, top: viewport.scrollTop };
    startDrag(pointer, {
      onMove: (dx, dy) => {
        viewport.classList.add("panning");
        viewport.scrollLeft = origin.left - dx;
        viewport.scrollTop = origin.top - dy;
      },
      onEnd: () => viewport.classList.remove("panning"),
    });
  };

  // Double click on empty space starts a new project at that day and row.
  const onDoubleClick = (event: MouseEvent) => {
    const viewport = viewportRef.current;
    if (!viewport || isFormControl(event.target) || (event.target as HTMLElement).closest(".project-bar, .event")) return;
    const index = rowIndexAt(event.clientY);
    store.getState().startDraft(startOfDay(dateAt(timeline, timelineX(event.clientX))), index);
  };

  // Rows differ in height (label tiers), so positions come from the DOM:
  // the index is the number of other rows whose middle is above the pointer.
  const rowIndexAt = useCallback((clientY: number, excludeId?: number) => {
    const rows = rowsRef.current?.querySelectorAll<HTMLElement>(".project") ?? [];
    let index = 0;
    for (const row of rows) {
      if (excludeId !== undefined && row.dataset.projectId === String(excludeId)) continue;
      const box = row.getBoundingClientRect();
      if (box.top + box.height / 2 < clientY) index++;
    }
    return index;
  }, []);

  const view: BoardView = useMemo(
    () => ({ timeline, today, viewportWidth, scrollLeft, timelineX, goToDate, goToToday, showProject, rowIndexAt, fitRanges }),
    [timeline, today, viewportWidth, scrollLeft, timelineX, goToDate, goToToday, showProject, rowIndexAt, fitRanges],
  );

  const boardClasses = ["board", `scale-${mode}`];
  if (compact) boardClasses.push("scale-compact");
  if (selectedId !== null) boardClasses.push("has-selection");
  if (editing) boardClasses.push("editing");

  return (
    <ViewContext.Provider value={view}>
      <div className={boardClasses.join(" ")}>
        <Header onNewProject={newProject} onShowAll={showAll} />
        <div
          className="viewport"
          ref={viewportRef}
          onScroll={onScroll}
          onPointerDown={onPointerDown}
          onDoubleClick={onDoubleClick}
          onClick={() => store.getState().select(null)}
          data-testid="viewport"
        >
          <div className="canvas" style={{ width }}>
            <TimelineGrid columns={columns} mode={mode} width={width} todayX={xOf(timeline, now)} />
            <div className="rows" ref={rowsRef}>
              {projects.map((card, index) => (
                <ProjectRow
                  key={card.id}
                  card={card}
                  index={index}
                  inactive={selectedId !== null && selectedId !== card.id}
                  draft={card.id === draftId}
                />
              ))}
              {planPreview &&
                previewColors(projects, planPreview.projects.length).map((colorIndex, index) => {
                  const project = planPreview.projects[index]!;
                  return (
                    <PreviewRow
                      key={project.key}
                      project={project}
                      colorIndex={colorIndex}
                      selected={planPreview.selected.includes(project.key)}
                    />
                  );
                })}
            </div>
          </div>
        </div>
        {projects.length === 0 && !planPreview && (
          <div className="empty-state">
            <h2>{t().emptyTitle}</h2>
            <p>{t().emptyText}</p>
            <div className="empty-actions">
              <button type="button" onClick={newProject}>
                + {t().newProject}
              </button>
              {planEnabled && (
                <button type="button" className="secondary" onClick={() => setPlanOpen(true)}>
                  ✨ {t().planFromText}
                </button>
              )}
            </div>
          </div>
        )}
        <ProjectPanel />
        <PlanPanel />
        {toast && (
          <div key={toast.id} className={`toast toast-${toast.kind}`} role={toast.kind === "error" ? "alert" : "status"}>
            <span>{toast.message}</span>
            {toast.undo && (
              <button type="button" className="toast-undo" onClick={toast.undo}>
                {t().undo}
              </button>
            )}
            <button type="button" className="toast-close" onClick={dismissToast} aria-label={t().dismiss}>
              ×
            </button>
          </div>
        )}
      </div>
    </ViewContext.Provider>
  );
}

function previewRange(project: { start_date: string; end_date: string }) {
  return { started_on: project.start_date, finished_on: project.end_date };
}

/** Colours the server will give the previewed projects, in order (same rule as User#next_color_index). */
function previewColors(cards: { color_index: number }[], count: number): number[] {
  const taken = [...cards];
  return Array.from({ length: count }, () => {
    const color = nextColorIndex(taken);
    taken.push({ color_index: color });
    return color;
  });
}
