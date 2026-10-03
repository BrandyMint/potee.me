import { parseISO, set as setTime } from "date-fns";
import { useRef, useState, type KeyboardEvent, type MouseEvent } from "react";
import { useBoard, useBoardView } from "./context";
import { startDrag } from "./drag";
import { formatTime, parseTime, t, timeExample, timePlaceholder } from "./i18n";
import { isSaved } from "./store";
import { dateAt, eventTime, xOf } from "./timeline";
import type { BoardEvent } from "./types";

interface Props {
  projectId: number;
  event: BoardEvent;
  /** Timeline x range the marker may be dragged within (the project's days). */
  minX: number;
  maxX: number;
  /** Label tier: 0 sits right above the bar, higher tiers stack upwards. */
  tier: number;
  tierHeight: number;
  /** No room for the label: it shows on hover only. */
  labelHidden: boolean;
}

export function EventMarker({ projectId, event, minX, maxX, tier, tierHeight, labelHidden }: Props) {
  const { timeline, today } = useBoardView();
  const editing = useBoard((state) => state.editingEventId === event.id);
  const updateEvent = useBoard((state) => state.updateEvent);
  const deleteEvent = useBoard((state) => state.deleteEvent);
  const editEvent = useBoard((state) => state.editEvent);
  const select = useBoard((state) => state.select);
  const [dragX, setDragX] = useState<number | null>(null);

  const at = parseISO(event.at);
  const x = dragX ?? xOf(timeline, at);
  const passed = at < today;

  const onPointerDown = (pointer: React.PointerEvent) => {
    if (editing) return;
    pointer.stopPropagation();
    const originX = xOf(timeline, at);
    const clamp = (value: number) => Math.min(maxX, Math.max(minX, value));
    startDrag(pointer, {
      onMove: (dx) => setDragX(clamp(originX + dx)),
      onEnd: (dx, _dy, moved) => {
        setDragX(null);
        if (moved) {
          void updateEvent(projectId, event.id, { at: dateAt(timeline, clamp(originX + dx)).toISOString() });
        } else if (isSaved(event.id)) {
          select(projectId);
          editEvent(event.id);
        }
      },
    });
  };

  const classes = ["event"];
  const time = eventTime({ ...event, at }, timeline.pixelsPerDay, formatTime);
  if (time) classes.push("timed");
  if (passed) classes.push("passed");
  if (labelHidden) classes.push("label-hidden");
  if (editing) classes.push("editing");
  if (dragX !== null) classes.push("dragging");

  return (
    <div
      className={classes.join(" ")}
      style={{ left: x, "--tier-offset": `${tier * tierHeight}px` } as React.CSSProperties}
      data-event-id={event.id}
    >
      {tier > 0 && <div className="event-connector" />}
      {editing ? (
        <EventForm
          title={event.title}
          at={at}
          time={event.timed ? formatTime(at) : ""}
          onSave={(title, time) => {
            editEvent(null);
            const changes: { title?: string; at?: string; timed?: boolean } = {};
            if (title !== event.title) changes.title = title;
            if (time === null) {
              if (event.timed) changes.timed = false;
            } else if (!event.timed || time.hours !== at.getHours() || time.minutes !== at.getMinutes()) {
              changes.at = setTime(at, { ...time, seconds: 0, milliseconds: 0 }).toISOString();
              changes.timed = true;
            }
            if (Object.keys(changes).length > 0) void updateEvent(projectId, event.id, changes);
          }}
          onCancel={() => editEvent(null)}
          onRemove={() => deleteEvent(projectId, event.id)}
        />
      ) : (
        <div className="event-title" onPointerDown={onPointerDown}>
          {time && <span className="event-time">{time}</span>}
          {event.title}
        </div>
      )}
      <div className="event-bar" onPointerDown={onPointerDown} onDoubleClick={(e) => e.stopPropagation()} />
    </div>
  );
}

/**
 * Editing a milestone in place, like a new project: the title with a dashed
 * outline (Enter saves, Esc cancels); the time stays where the label shows it,
 * above the title: "+ time" or a removable chip; save and delete as icons.
 */
function EventForm(props: {
  title: string;
  /** Where the milestone stands: "+ time" starts from this moment. */
  at: Date;
  /** Formatted start time, or "" for an event without a time. */
  time: string;
  onSave: (title: string, time: { hours: number; minutes: number } | null) => void;
  onCancel: () => void;
  onRemove: () => void;
}) {
  const text = t();
  const [title, setTitle] = useState(props.title);
  const [timeText, setTimeText] = useState(props.time);
  const [timeOpen, setTimeOpen] = useState(false);
  const [invalid, setInvalid] = useState(false);
  const done = useRef(false);
  const titleInput = useRef<HTMLInputElement>(null);

  const save = () => {
    if (done.current) return;
    const value = timeText.trim();
    const time = value ? parseTime(value) : null;
    if (value && !time) {
      setInvalid(true);
      setTimeOpen(true);
      return;
    }
    done.current = true;
    props.onSave(title.trim() || props.title, time);
  };
  // "+ time" starts from the moment where the milestone stands, to 15 minutes.
  const addTime = () => {
    const minutes = Math.round((props.at.getHours() * 60 + props.at.getMinutes()) / 15) * 15;
    const rounded = new Date(props.at);
    rounded.setHours(0, Math.min(minutes, 23 * 60 + 45), 0, 0);
    setTimeText(formatTime(rounded));
    setTimeOpen(true);
  };
  const cancel = () => {
    done.current = true;
    props.onCancel();
  };
  const onKeyDown = (event: KeyboardEvent) => {
    if (event.key === "Enter") {
      event.preventDefault();
      save();
    }
    if (event.key === "Escape") cancel();
  };
  // Save when focus leaves the whole form, not when moving between its parts.
  // Checked after the browser has moved the focus: Safari does not focus a
  // clicked button, so relatedTarget alone would look like leaving the form.
  const form = useRef<HTMLFormElement>(null);
  const onBlur = () => {
    requestAnimationFrame(() => {
      if (!form.current?.contains(document.activeElement)) save();
    });
  };
  // Buttons of the form keep the focus where it is.
  const keepFocus = (event: MouseEvent) => event.preventDefault();

  return (
    <form
      ref={form}
      className="inline-form event-form"
      onSubmit={(event) => {
        event.preventDefault();
        save();
      }}
      onPointerDown={(e) => e.stopPropagation()}
      onBlur={onBlur}
    >
      <div className="event-form-time">
        {timeOpen ? (
          <input
            className={`event-time-input${invalid ? " invalid" : ""}`}
            aria-label={text.eventTime}
            aria-invalid={invalid}
            title={invalid ? text.invalidTime(timeExample()) : text.eventTimeHint}
            placeholder={timePlaceholder()}
            value={timeText}
            autoFocus
            onFocus={(event) => event.currentTarget.select()}
            onChange={(event) => {
              setTimeText(event.target.value);
              setInvalid(false);
            }}
            onKeyDown={onKeyDown}
          />
        ) : timeText ? (
          <span className="event-time-chip">
            <button type="button" title={text.eventTimeHint} onMouseDown={keepFocus} onClick={() => setTimeOpen(true)}>
              {timeText}
            </button>
            <button
              type="button"
              aria-label={text.removeTime}
              title={text.removeTime}
              onMouseDown={keepFocus}
              onClick={() => {
                setTimeText("");
                titleInput.current?.focus();
              }}
            >
              ×
            </button>
          </span>
        ) : (
          <button type="button" className="event-add-time" title={text.eventTimeHint} onMouseDown={keepFocus} onClick={addTime}>
            + {text.addTime}
          </button>
        )}
      </div>
      <div className="event-form-row">
        <input
          ref={titleInput}
          className="event-title-input"
          aria-label={text.eventTitle}
          value={title}
          autoFocus={!timeOpen}
          onFocus={(event) => event.currentTarget.select()}
          onChange={(event) => setTitle(event.target.value)}
          onKeyDown={onKeyDown}
        />
        <button type="submit" className="inline-icon" aria-label={text.save} title={`${text.save} (Enter)`} onMouseDown={keepFocus}>
          <svg viewBox="0 0 24 24" aria-hidden>
            <path d="M5 12l5 5L19 7" />
          </svg>
        </button>
        <button
          type="button"
          className="inline-icon danger"
          aria-label={text.delete}
          title={text.delete}
          onMouseDown={keepFocus}
          onClick={props.onRemove}
        >
          <svg viewBox="0 0 24 24" aria-hidden>
            <path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13" />
          </svg>
        </button>
      </div>
      {invalid && (
        <div className="event-form-error" role="alert">
          {text.invalidTime(timeExample())}
        </div>
      )}
    </form>
  );
}
