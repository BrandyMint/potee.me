import { startOfDay } from "date-fns";
import { useCallback, useEffect, useLayoutEffect, useMemo, useRef, useState, type MouseEvent, type PointerEvent } from "react";
import { StoreContext, useBoard, useBoardStore, ViewContext, type BoardView } from "./context";
import { isFormControl, startDrag } from "./drag";
import { Header } from "./Header";
import { ProjectRow } from "./ProjectRow";
import { createBoardStore } from "./store";
import {
  buildTimeline,
  clampScale,
  dateAt,
  fitScale,
  projectMiddle,
  SCALE,
  scaleMode,
  stepScale,
  timelineColumns,
  timelineWidth,
  toggleScale,
  xOf,
} from "./timeline";
import { TimelineGrid } from "./TimelineGrid";
import type { BoardData } from "./types";

/** Row heights per zoom level; they must match board.css. */
const ROW_HEIGHT = { days: 78, compact: 64, weeks: 50, months: 45 } as const;
/** Empty space above the first row (below the sticky header). */
const ROWS_TOP = 60;

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
  const draftId = useBoard((state) => state.draftId);
  const error = useBoard((state) => state.error);
  const dismissError = useBoard((state) => state.dismissError);

  const viewportRef = useRef<HTMLDivElement>(null);
  const [viewportWidth, setViewportWidth] = useState(() => window.innerWidth);
  const [scrollLeft, setScrollLeft] = useState(0);
  const today = useMemo(() => startOfDay(new Date()), []);

  const timeline = useMemo(
    () => buildTimeline({ projects, today, pixelsPerDay, viewportWidth }),
    [projects, today, pixelsPerDay, viewportWidth],
  );
  const columns = useMemo(() => timelineColumns(timeline, today), [timeline, today]);
  const width = timelineWidth(timeline);
  const mode = scaleMode(pixelsPerDay);
  const compact = mode === "days" && pixelsPerDay <= SCALE.COMPACT_DAYS_AT;
  const rowHeight = mode === "days" ? (compact ? ROW_HEIGHT.compact : ROW_HEIGHT.days) : ROW_HEIGHT[mode];

  // Keep the remembered moment in the middle of the screen whenever the zoom,
  // the timeline origin or the viewport width changes.
  const originTime = timeline.origin.getTime();
  useLayoutEffect(() => {
    const viewport = viewportRef.current;
    if (!viewport) return;
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
      if (isFormControl(event.target) || event.metaKey || event.ctrlKey || event.altKey) return;
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
          goToDate(new Date());
          break;
        case "Enter":
          newProject();
          break;
        case "Escape":
          if (state.editingEventId !== null) state.editEvent(null);
          else if (state.draftId !== null) state.cancelDraft();
          else state.select(null);
          break;
        default:
          return;
      }
      event.preventDefault();
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [store, goToDate, newProject]);

  // Save the view state when the page is left before the debounce fires.
  useEffect(() => {
    const flush = () => store.getState().saveDashboardNow();
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
  const onPointerDown = (pointer: PointerEvent) => {
    const viewport = viewportRef.current;
    if (!viewport || isFormControl(pointer.target)) return;
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
    const y = event.clientY - viewport.getBoundingClientRect().top + viewport.scrollTop - ROWS_TOP - headerHeight(viewport);
    const index = Math.max(0, Math.round(y / rowHeight));
    store.getState().startDraft(startOfDay(dateAt(timeline, timelineX(event.clientX))), index);
  };

  const view: BoardView = useMemo(
    () => ({ timeline, today, viewportWidth, scrollLeft, timelineX, goToDate, showProject }),
    [timeline, today, viewportWidth, scrollLeft, timelineX, goToDate, showProject],
  );

  const boardClasses = ["board", `scale-${mode}`];
  if (compact) boardClasses.push("scale-compact");
  if (selectedId !== null) boardClasses.push("has-selection");

  return (
    <ViewContext.Provider value={view}>
      <div className={boardClasses.join(" ")}>
        <Header onNewProject={newProject} />
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
            <TimelineGrid columns={columns} mode={mode} width={width} />
            <div className="rows" style={{ paddingTop: ROWS_TOP }}>
              {projects.map((card, index) => (
                <ProjectRow
                  key={card.id}
                  card={card}
                  index={index}
                  rowHeight={rowHeight}
                  rowsCount={projects.length}
                  inactive={selectedId !== null && selectedId !== card.id}
                  draft={card.id === draftId}
                />
              ))}
            </div>
          </div>
        </div>
        {error && (
          <div className="toast" role="alert">
            {error}
            <button type="button" onClick={dismissError} aria-label="Dismiss">
              ×
            </button>
          </div>
        )}
      </div>
    </ViewContext.Provider>
  );
}

function headerHeight(viewport: HTMLElement): number {
  return viewport.querySelector<HTMLElement>(".timeline-header")?.offsetHeight ?? 0;
}
