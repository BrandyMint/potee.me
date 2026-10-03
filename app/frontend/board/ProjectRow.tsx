import { addDays, differenceInCalendarDays, parseISO } from "date-fns";
import { memo, useMemo, useRef, useState, type KeyboardEvent, type MouseEvent, type PointerEvent } from "react";
import { useBoard, useBoardView } from "./context";
import { startDrag } from "./drag";
import { EventMarker } from "./EventMarker";
import { t } from "./i18n";
import { isSaved } from "./store";
import { dateAt, eventBounds, eventTime, formatDay, labelStyle, labelTiers, parseDay, xOf } from "./timeline";
import type { Card } from "./types";

interface Props {
  card: Card;
  index: number;
  inactive: boolean;
  draft: boolean;
}

type Edge = "start" | "finish";

/** Longer than the gap between the clicks of a double click. */
const DOUBLE_CLICK_MS = 350;

export const ProjectRow = memo(function ProjectRow({ card, index, inactive, draft }: Props) {
  const { timeline, viewportWidth, scrollLeft, timelineX, goToDate, rowIndexAt } = useBoardView();
  const select = useBoard((state) => state.select);
  const renaming = useBoard((state) => state.renamingId === card.id);
  const selected = useBoard((state) => state.selectedId === card.id);
  const panelOpen = useBoard((state) => state.panelOpen);
  const openPanel = useBoard((state) => state.openPanel);
  const renameProject = useBoard((state) => state.renameProject);
  const addEvent = useBoard((state) => state.addEvent);
  const updateProject = useBoard((state) => state.updateProject);
  const moveProject = useBoard((state) => state.moveProject);
  const commitDraft = useBoard((state) => state.commitDraft);
  const cancelDraft = useBoard((state) => state.cancelDraft);

  /** Day shifts of the edges while one is being dragged. */
  const [resize, setResize] = useState<{ edge: Edge; days: number } | null>(null);
  const [reorderY, setReorderY] = useState<number | null>(null);

  const ppd = timeline.pixelsPerDay;
  let start = parseDay(card.started_on);
  let finish = parseDay(card.finished_on);
  if (resize?.edge === "start") start = addDays(start, resize.days);
  if (resize?.edge === "finish") finish = addDays(finish, resize.days);
  const left = xOf(timeline, start);
  const width = (differenceInCalendarDays(finish, start) + 1) * ppd;
  const right = left + width;

  // First click selects the project, the second opens its panel. The panel
  // waits out the double-click interval: a double click adds a milestone only.
  const panelTimer = useRef(0);
  const openPanelSoon = () => {
    window.clearTimeout(panelTimer.current);
    panelTimer.current = window.setTimeout(() => openPanel(true), DOUBLE_CLICK_MS);
  };
  const onBarClick = (event: MouseEvent) => {
    event.stopPropagation();
    // Clicks on the title are handled by its own pointer handler.
    if ((event.target as HTMLElement).closest(".project-title") || event.detail > 1) return;
    if (!selected) select(card.id);
    else if (!panelOpen && isSaved(card.id)) openPanelSoon();
  };

  const onBarDoubleClick = (event: MouseEvent) => {
    event.stopPropagation();
    window.clearTimeout(panelTimer.current);
    if (!isSaved(card.id)) return;
    select(card.id);
    const at = dateAt(timeline, Math.min(right - 1, Math.max(left, timelineX(event.clientX))));
    void addEvent(card.id, at);
  };

  const onEdgePointerDown = (edge: Edge) => (pointer: PointerEvent) => {
    pointer.stopPropagation();
    if (!isSaved(card.id)) return;
    const original = { start: parseDay(card.started_on), finish: parseDay(card.finished_on) };
    const bounds = eventBounds(card);
    const limit = (days: number) => {
      if (edge === "start") {
        const latest = bounds.first && bounds.first < original.finish ? bounds.first : original.finish;
        return Math.min(days, differenceInCalendarDays(latest, original.start));
      }
      const earliest = bounds.last && bounds.last > original.start ? bounds.last : original.start;
      return Math.max(days, differenceInCalendarDays(earliest, original.finish));
    };
    startDrag(pointer, {
      onMove: (dx) => setResize({ edge, days: limit(Math.round(dx / ppd)) }),
      onEnd: (dx, _dy, moved) => {
        setResize(null);
        const days = limit(Math.round(dx / ppd));
        if (!moved || days === 0) return;
        if (edge === "start") void updateProject(card.id, { started_on: formatDay(addDays(original.start, days)) });
        else void updateProject(card.id, { finished_on: formatDay(addDays(original.finish, days)) });
      },
    });
  };

  // Clicks on the title: select, then open the panel, then rename in the bar
  // (a double click renames at once).
  const onTitlePointerDown = (pointer: PointerEvent) => {
    pointer.stopPropagation();
    if (draft) return;
    const wasSelected = selected;
    const wasOpen = panelOpen;
    startDrag(
      pointer,
      {
        onMove: (_dx, dy) => setReorderY(dy),
        onEnd: (_dx, _dy, moved, event) => {
          setReorderY(null);
          if (!moved) {
            if (!wasSelected) select(card.id);
            else if (!wasOpen) openPanelSoon();
            else if (isSaved(card.id)) renameProject(card.id);
            return;
          }
          const target = rowIndexAt(event.clientY, card.id);
          if (target !== index) void moveProject(card.id, target);
        },
      },
      6,
    );
  };

  const [minX, maxX] = [left, right - 1];
  const visibleLeft = scrollLeft;
  const visibleRight = scrollLeft + viewportWidth;
  const offScreen = right < visibleLeft ? "left" : left > visibleRight ? "right" : null;

  // Labels that would overlap go up a tier and the row grows to fit; labels
  // beyond the allowed tiers are hidden until hovered (see labelStyle).
  const labels = useMemo(
    () =>
      layoutLabels(
        card.events.map((event) => {
          const at = parseISO(event.at);
          return { id: event.id, x: xOf(timeline, at), title: event.title, time: eventTime({ ...event, at }, ppd) };
        }),
        ppd,
      ),
    [card.events, timeline, ppd],
  );

  const classes = ["project", `project-color-${card.color_index}`];
  if (inactive) classes.push("inactive");
  if (resize) classes.push("resizing");
  if (reorderY !== null) classes.push("reordering");
  if (draft) classes.push("draft");
  if (renaming) classes.push("renaming");

  return (
    <div
      className={classes.join(" ")}
      style={
        {
          "--tiers-extra": `${labels.tiersExtra}px`,
          "--time-line": `${labels.timeLine}px`,
          ...(reorderY === null ? {} : { transform: `translateY(${reorderY}px)` }),
        } as React.CSSProperties
      }
      data-project-id={card.id}
      data-testid={`project-${card.title}`}
    >
      <div className="project-bar" style={{ left, width }} onClick={onBarClick} onDoubleClick={onBarDoubleClick}>
        <div className="resize-handle start" onPointerDown={onEdgePointerDown("start")} />
        <div className="project-title">
          {draft ? (
            <DraftTitle onSave={(title) => void commitDraft(title)} onCancel={cancelDraft} />
          ) : renaming ? (
            <DraftTitle
              initial={card.title}
              saveOnBlur
              onSave={(title) => {
                renameProject(null);
                const value = title.trim();
                if (value && value !== card.title) void updateProject(card.id, { title: value });
              }}
              onCancel={() => renameProject(null)}
            />
          ) : (
            <span
              className="project-title-text"
              onPointerDown={onTitlePointerDown}
              onDoubleClick={(event) => {
                event.stopPropagation();
                window.clearTimeout(panelTimer.current);
                if (isSaved(card.id)) {
                  select(card.id);
                  renameProject(card.id);
                }
              }}
              title={t().reorderHint}
            >
              {card.title}
            </span>
          )}
        </div>
        <div className="resize-handle finish" onPointerDown={onEdgePointerDown("finish")} />
      </div>
      {(draft || renaming) && (
        <div className="draft-hint" style={{ left }}>
          <kbd>Enter</kbd> — {t().draftSave} · <kbd>Esc</kbd> — {t().draftCancel}
        </div>
      )}
      {card.events.map((event) => (
        <EventMarker
          key={event.id}
          projectId={card.id}
          event={event}
          minX={minX}
          maxX={maxX}
          tier={labels.tiers.get(event.id) ?? 0}
          tierHeight={labels.tierStep}
          labelHidden={labels.hidden.has(event.id)}
        />
      ))}
      {offScreen && (
        <button
          type="button"
          className={`edge-label ${offScreen}`}
          style={offScreen === "left" ? { left: visibleLeft + 8 } : { left: visibleRight - 8 }}
          onClick={(event) => {
            event.stopPropagation();
            select(card.id);
            goToDate(offScreen === "left" ? finish : start);
          }}
        >
          {offScreen === "left" ? "← " : ""}
          {card.title}
          {offScreen === "right" ? " →" : ""}
        </button>
      )}
    </div>
  );
});

/** Title field right in the bar: for a new project and for renaming. */
function DraftTitle({ initial = "", saveOnBlur = false, onSave, onCancel }: {
  initial?: string;
  saveOnBlur?: boolean;
  onSave: (title: string) => void;
  onCancel: () => void;
}) {
  const [title, setTitle] = useState(initial);
  const done = useRef(false);
  const finish = (save: boolean) => {
    if (done.current) return;
    done.current = true;
    if (save) onSave(title);
    else onCancel();
  };
  const onKeyDown = (event: KeyboardEvent) => {
    if (event.key === "Enter") finish(true);
    if (event.key === "Escape") finish(false);
  };
  return (
    <form className="draft-title" onSubmit={(event) => event.preventDefault()} onPointerDown={(e) => e.stopPropagation()}>
      <input
        aria-label={t().projectTitle}
        placeholder={t().projectPlaceholder}
        value={title}
        autoFocus
        enterKeyHint="done"
        onFocus={(event) => event.currentTarget.select()}
        onBlur={saveOnBlur ? () => finish(true) : undefined}
        onChange={(event) => setTitle(event.target.value)}
        onKeyDown={onKeyDown}
      />
    </form>
  );
}

/** Width of an event label in pixels (same font as .event-title). */
let measureContext: CanvasRenderingContext2D | null = null;
export function measureLabel(title: string, fontSize: number): number {
  measureContext ??= document.createElement("canvas").getContext("2d");
  if (!measureContext) return title.length * fontSize * 0.5;
  measureContext.font = `${fontSize}px "Helvetica Neue", Helvetica, Arial, sans-serif`;
  return measureContext.measureText(title).width;
}

/**
 * Tiers of a row's event labels. When any label has a start time, every tier
 * makes room for the time line above the titles (`timeLine`), so titles of a
 * row stay on the same lines. `tiersExtra` is the height the row grows by.
 */
export function layoutLabels(events: { id: number; x: number; title: string; time: string | null }[], pixelsPerDay: number) {
  const style = labelStyle(pixelsPerDay);
  const timeLine = events.some((event) => event.time) ? style.timeHeight : 0;
  const tierStep = style.tierHeight + timeLine;
  const { tiers, hidden, count } = labelTiers(
    events,
    ({ title, time }) => Math.max(measureLabel(title, style.fontSize), time ? measureLabel(time, style.timeSize) : 0),
    style.maxTiers,
  );
  return { tiers, hidden, tierStep, timeLine, tiersExtra: (count - 1) * tierStep + timeLine };
}

