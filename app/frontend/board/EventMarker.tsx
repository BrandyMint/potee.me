import { parseISO } from "date-fns";
import { useState, type KeyboardEvent } from "react";
import { useBoard, useBoardView } from "./context";
import { startDrag } from "./drag";
import { isSaved } from "./store";
import { dateAt, xOf } from "./timeline";
import type { BoardEvent } from "./types";

interface Props {
  projectId: number;
  event: BoardEvent;
  /** Timeline x range the marker may be dragged within (the project's days). */
  minX: number;
  maxX: number;
  closest: boolean;
}

export function EventMarker({ projectId, event, minX, maxX, closest }: Props) {
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
  if (passed) classes.push("passed");
  if (closest) classes.push("closest");
  if (editing) classes.push("editing");
  if (dragX !== null) classes.push("dragging");

  return (
    <div className={classes.join(" ")} style={{ left: x }} data-event-id={event.id}>
      {editing ? (
        <EventForm
          title={event.title}
          onSave={(title) => {
            editEvent(null);
            if (title !== event.title) void updateEvent(projectId, event.id, { title });
          }}
          onCancel={() => editEvent(null)}
          onRemove={() => void deleteEvent(projectId, event.id)}
        />
      ) : (
        <div className="event-title" onPointerDown={onPointerDown}>
          {event.title}
        </div>
      )}
      <div className="event-bar" onPointerDown={onPointerDown} onDoubleClick={(e) => e.stopPropagation()} />
    </div>
  );
}

function EventForm(props: { title: string; onSave: (title: string) => void; onCancel: () => void; onRemove: () => void }) {
  const [title, setTitle] = useState(props.title);
  const onKeyDown = (event: KeyboardEvent) => {
    if (event.key === "Enter") props.onSave(title.trim() || props.title);
    if (event.key === "Escape") props.onCancel();
  };
  return (
    <form className="event-form" onSubmit={(event) => event.preventDefault()} onPointerDown={(e) => e.stopPropagation()}>
      <input
        aria-label="Event title"
        value={title}
        autoFocus
        onFocus={(event) => event.currentTarget.select()}
        onChange={(event) => setTitle(event.target.value)}
        onKeyDown={onKeyDown}
        onBlur={() => props.onSave(title.trim() || props.title)}
      />
      <button type="button" className="danger" onMouseDown={(e) => e.preventDefault()} onClick={props.onRemove}>
        remove
      </button>
    </form>
  );
}
