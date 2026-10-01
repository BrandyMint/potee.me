import { addDays, differenceInCalendarDays, parseISO } from "date-fns";
import { memo, useMemo, useState, type KeyboardEvent, type MouseEvent, type PointerEvent } from "react";
import { useBoard, useBoardView } from "./context";
import { startDrag } from "./drag";
import { EventMarker } from "./EventMarker";
import { t } from "./i18n";
import { isSaved } from "./store";
import { dateAt, eventBounds, formatDay, labelStyle, labelTiers, parseDay, xOf } from "./timeline";
import type { Card } from "./types";

interface Props {
  card: Card;
  index: number;
  inactive: boolean;
  draft: boolean;
}

type Edge = "start" | "finish";

export const ProjectRow = memo(function ProjectRow({ card, index, inactive, draft }: Props) {
  const { timeline, viewportWidth, scrollLeft, timelineX, goToDate, rowIndexAt } = useBoardView();
  const select = useBoard((state) => state.select);
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

  const onBarClick = (event: MouseEvent) => {
    event.stopPropagation();
    select(card.id);
  };

  const onBarDoubleClick = (event: MouseEvent) => {
    event.stopPropagation();
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

  const onTitlePointerDown = (pointer: PointerEvent) => {
    pointer.stopPropagation();
    if (draft) return;
    startDrag(
      pointer,
      {
        onMove: (_dx, dy) => setReorderY(dy),
        onEnd: (_dx, _dy, moved, event) => {
          setReorderY(null);
          if (!moved) {
            select(card.id);
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
  const style = labelStyle(ppd);
  const tiers = useMemo(
    () =>
      labelTiers(
        card.events.map((event) => ({ id: event.id, x: xOf(timeline, parseISO(event.at)), title: event.title })),
        (title) => measureLabel(title, style.fontSize),
        style.maxTiers,
      ),
    [card.events, timeline, style.fontSize, style.maxTiers],
  );
  const tiersExtra = (tiers.count - 1) * style.tierHeight;

  const classes = ["project", `project-color-${card.color_index}`];
  if (inactive) classes.push("inactive");
  if (resize) classes.push("resizing");
  if (reorderY !== null) classes.push("reordering");
  if (draft) classes.push("draft");

  return (
    <div
      className={classes.join(" ")}
      style={
        {
          "--tiers-extra": `${tiersExtra}px`,
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
          ) : (
            <span className="project-title-text" onPointerDown={onTitlePointerDown} title={t().reorderHint}>
              {card.title}
            </span>
          )}
        </div>
        <div className="resize-handle finish" onPointerDown={onEdgePointerDown("finish")} />
      </div>
      {draft && (
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
          tier={tiers.tiers.get(event.id) ?? 0}
          tierHeight={style.tierHeight}
          labelHidden={tiers.hidden.has(event.id)}
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

function DraftTitle({ onSave, onCancel }: { onSave: (title: string) => void; onCancel: () => void }) {
  const [title, setTitle] = useState("");
  const onKeyDown = (event: KeyboardEvent) => {
    if (event.key === "Enter") onSave(title);
    if (event.key === "Escape") onCancel();
  };
  return (
    <form className="draft-title" onSubmit={(event) => event.preventDefault()} onPointerDown={(e) => e.stopPropagation()}>
      <input
        aria-label={t().projectTitle}
        placeholder={t().projectPlaceholder}
        value={title}
        autoFocus
        enterKeyHint="done"
        onChange={(event) => setTitle(event.target.value)}
        onKeyDown={onKeyDown}
      />
    </form>
  );
}

/** Width of an event label in pixels (same font as .event-title). */
let measureContext: CanvasRenderingContext2D | null = null;
function measureLabel(title: string, fontSize: number): number {
  measureContext ??= document.createElement("canvas").getContext("2d");
  if (!measureContext) return title.length * fontSize * 0.5;
  measureContext.font = `${fontSize}px "Helvetica Neue", Helvetica, Arial, sans-serif`;
  return measureContext.measureText(title).width;
}
