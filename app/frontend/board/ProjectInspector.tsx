import { format, set as setTime } from "date-fns";
import { useEffect, useRef, useState, type CSSProperties, type KeyboardEvent, type PointerEvent } from "react";
import { useBoard, useBoardView } from "./context";
import { startDrag } from "./drag";
import { dateLocale, t } from "./i18n";
import { isSaved } from "./store";
import { COLORS_COUNT, formatDay, parseDay, projectDays } from "./timeline";
import type { BoardEvent, Card } from "./types";

/** Side card of the selected project: title, colour, dates, milestones, sharing. */
export function ProjectInspector() {
  const card = useBoard((state) => state.projects.find((project) => project.id === state.selectedId));
  if (!card || !isSaved(card.id)) return null;
  return <Inspector key={card.id} card={card} />;
}

function Inspector({ card }: { card: Card }) {
  const { showProject, goToDate, today } = useBoardView();
  const updateProject = useBoard((state) => state.updateProject);
  const deleteProject = useBoard((state) => state.deleteProject);
  const addEvent = useBoard((state) => state.addEvent);
  const select = useBoard((state) => state.select);
  const [title, setTitle] = useState(card.title);
  const [paletteOpen, setPaletteOpen] = useState(false);
  const [share, setShare] = useState<"idle" | "copied" | "manual">("idle");
  const text = t();

  useEffect(() => setTitle(card.title), [card.title]);

  const saveTitle = () => {
    const value = title.trim();
    if (value && value !== card.title) void updateProject(card.id, { title: value });
    else setTitle(card.title);
  };
  const onTitleKeyDown = (event: KeyboardEvent<HTMLTextAreaElement>) => {
    if (event.key === "Enter") {
      event.preventDefault();
      event.currentTarget.blur();
    }
    if (event.key === "Escape") {
      setTitle(card.title);
      event.currentTarget.blur();
    }
  };
  const changeDate = (field: "started_on" | "finished_on", value: string) => {
    if (!value) return;
    const next = { started_on: card.started_on, finished_on: card.finished_on, [field]: value };
    if (next.started_on <= next.finished_on) void updateProject(card.id, { [field]: value });
  };
  const addMilestone = () => {
    const start = parseDay(card.started_on);
    const finish = parseDay(card.finished_on);
    const at = today < start ? start : today > finish ? finish : today;
    void addEvent(card.id, at);
    goToDate(at);
  };
  const copyLink = async () => {
    try {
      await navigator.clipboard.writeText(card.share_url);
      setShare("copied");
      setTimeout(() => setShare("idle"), 2000);
    } catch {
      // No clipboard access (e.g. plain http): show the link to copy by hand.
      setShare("manual");
    }
  };

  const events = [...card.events].sort((a, b) => a.at.localeCompare(b.at));
  const days = projectDays(card);

  return (
    <aside className={`project-inspector project-color-${card.color_index}`} aria-label={text.projectCard}>
      <div className="inspector-head">
        <button
          type="button"
          className="inspector-colour"
          aria-label={text.changeColour}
          title={text.changeColour}
          aria-expanded={paletteOpen}
          onClick={() => setPaletteOpen(!paletteOpen)}
        />
        <textarea
          className="inspector-title"
          aria-label={text.selectedTitle}
          rows={1}
          value={title}
          onChange={(event) => setTitle(event.target.value.replace(/\n/g, " "))}
          onBlur={saveTitle}
          onKeyDown={onTitleKeyDown}
        />
        <button type="button" className="inspector-close" aria-label={text.close} title={`${text.close} (Esc)`} onClick={() => select(null)}>
          ×
        </button>
      </div>
      <div className="inspector-body">
        {paletteOpen && (
          <div className="inspector-palette" role="group" aria-label={text.changeColour}>
            {Array.from({ length: COLORS_COUNT }, (_, index) => (
              <button
                key={index}
                type="button"
                className={`project-color-${index}${index === card.color_index ? " current" : ""}`}
                aria-label={text.colour(index + 1)}
                aria-pressed={index === card.color_index}
                onClick={() => void updateProject(card.id, { color_index: index })}
              />
            ))}
          </div>
        )}

        <section>
          <h3>
            {text.dates}
            <span>{text.daysCount(days)}</span>
          </h3>
          <div className="inspector-dates">
            <input type="date" aria-label={text.startDate} value={card.started_on} max={card.finished_on} onChange={(event) => changeDate("started_on", event.target.value)} />
            <span aria-hidden>→</span>
            <input type="date" aria-label={text.finishDate} value={card.finished_on} min={card.started_on} onChange={(event) => changeDate("finished_on", event.target.value)} />
          </div>
        </section>

        <section>
          <h3>
            {text.milestones}
            <button type="button" className="inspector-link" onClick={addMilestone}>
              + {text.addMilestone}
            </button>
          </h3>
          {events.length === 0 ? (
            <p className="inspector-muted">{text.noMilestones}</p>
          ) : (
            <MilestoneList projectId={card.id} events={events} today={today} />
          )}
        </section>

        <section>
          <h3>{text.sharing}</h3>
          <button type="button" className="primary inspector-copy" onClick={() => void copyLink()} title={text.shareHint}>
            {share === "copied" ? `✓ ${text.linkCopied}` : text.copyShareLink}
          </button>
          {share === "manual" && (
            <input
              className="inspector-share-url"
              readOnly
              autoFocus
              aria-label={text.copyLink}
              value={card.share_url}
              onFocus={(event) => event.currentTarget.select()}
            />
          )}
          <p className="inspector-muted">{card.owner ? text.shareNote : text.sharedWithYou}</p>
        </section>
      </div>
      <div className="inspector-foot">
        <button type="button" onClick={() => showProject(card.id)} title={text.entireHint}>
          {text.entire}
        </button>
        <button type="button" className="danger" onClick={() => deleteProject(card.id)}>
          {card.owner ? text.delete : text.removeFromBoard}
        </button>
      </div>
    </aside>
  );
}

/**
 * Milestones in date order. Dragging one to another place changes the order of
 * the steps, not the schedule: the dates stay where they are and the events
 * take the dates of their new places.
 */
function MilestoneList({ projectId, events, today }: { projectId: number; events: BoardEvent[]; today: Date }) {
  const updateEvent = useBoard((state) => state.updateEvent);
  const list = useRef<HTMLUListElement>(null);
  const [drag, setDrag] = useState<{ from: number; to: number; dy: number; height: number } | null>(null);

  const reorder = (from: number, to: number) => {
    const order = [...events];
    const [moved] = order.splice(from, 1);
    if (!moved) return;
    order.splice(to, 0, moved);
    order.forEach((event, index) => {
      const slot = events[index]!;
      if (event.at !== slot.at || event.timed !== slot.timed) void updateEvent(projectId, event.id, { at: slot.at, timed: slot.timed });
    });
  };

  const startReorder = (from: number) => (start: PointerEvent<HTMLElement>) => {
    const boxes = [...(list.current?.children ?? [])].map((item) => item.getBoundingClientRect());
    const height = boxes[from]?.height ?? 0;
    let to = from;
    startDrag(start, {
      onMove: (_dx, dy, event) => {
        to = boxes.filter((box, index) => index !== from && event.clientY > box.top + box.height / 2).length;
        setDrag({ from, to, dy, height });
      },
      onEnd: (_dx, _dy, moved) => {
        setDrag(null);
        if (moved && to !== from) reorder(from, to);
      },
    });
  };

  // While dragging, every row shows the date it will get when dropped here.
  const slotOf = (index: number) => {
    if (!drag) return events[index]!;
    const order = events.map((_, i) => i);
    order.splice(drag.from, 1);
    order.splice(drag.to, 0, drag.from);
    return events[order.indexOf(index)]!;
  };

  const shift = (index: number) => {
    if (!drag || index === drag.from) return undefined;
    if (drag.from < index && index <= drag.to) return { transform: `translateY(${-drag.height}px)` };
    if (drag.to <= index && index < drag.from) return { transform: `translateY(${drag.height}px)` };
    return undefined;
  };

  return (
    <ul className={`inspector-milestones${drag ? " reordering" : ""}`} ref={list}>
      {events.map((event, index) => (
        <MilestoneItem
          key={event.id}
          projectId={projectId}
          event={event}
          slot={slotOf(index)}
          past={formatDay(new Date(event.at)) < formatDay(today)}
          dragging={drag?.from === index}
          style={drag?.from === index ? { transform: `translateY(${drag.dy}px)` } : shift(index)}
          onDragStart={startReorder(index)}
        />
      ))}
    </ul>
  );
}

/** A milestone in the card: its date and time open pickers, the title shows it on the board. */
function MilestoneItem({
  projectId,
  event,
  slot,
  past,
  dragging,
  style,
  onDragStart,
}: {
  projectId: number;
  event: BoardEvent;
  /** Where the date and time come from: the event itself, or its place during a drag. */
  slot: BoardEvent;
  past: boolean;
  dragging: boolean;
  style?: CSSProperties;
  onDragStart: (start: PointerEvent<HTMLElement>) => void;
}) {
  const { goToDate } = useBoardView();
  const updateEvent = useBoard((state) => state.updateEvent);
  const deleteEvent = useBoard((state) => state.deleteEvent);
  const editEvent = useBoard((state) => state.editEvent);
  const dateInput = useRef<HTMLInputElement>(null);
  const timeInput = useRef<HTMLInputElement>(null);
  const text = t();
  const at = new Date(event.at);
  const time = event.timed ? format(at, "HH:mm") : "";
  const shownAt = new Date(slot.at);
  const shownTime = slot.timed ? format(shownAt, "HH:mm") : "";

  const changeDay = (day: string) => {
    if (!day || day === formatDay(at)) return;
    const moved = setTime(parseDay(day), { hours: at.getHours(), minutes: at.getMinutes(), seconds: 0, milliseconds: 0 });
    void updateEvent(projectId, event.id, { at: moved.toISOString() });
  };
  const changeTime = (value: string) => {
    if (value === time) return;
    if (!value) {
      void updateEvent(projectId, event.id, { timed: false });
      return;
    }
    const [hours = 0, minutes = 0] = value.split(":").map(Number);
    void updateEvent(projectId, event.id, { at: setTime(at, { hours, minutes, seconds: 0, milliseconds: 0 }).toISOString(), timed: true });
  };
  const openPicker = (input: HTMLInputElement | null) => {
    try {
      input?.showPicker();
    } catch {
      input?.focus();
    }
  };

  return (
    <li className={[past && "past", dragging && "dragging"].filter(Boolean).join(" ") || undefined} style={style}>
      <span className="milestone-handle" title={text.reorderMilestone} aria-hidden onPointerDown={onDragStart}>
        <svg viewBox="0 0 24 24">
          <circle cx="9" cy="6" r="1.4" />
          <circle cx="15" cy="6" r="1.4" />
          <circle cx="9" cy="12" r="1.4" />
          <circle cx="15" cy="12" r="1.4" />
          <circle cx="9" cy="18" r="1.4" />
          <circle cx="15" cy="18" r="1.4" />
        </svg>
      </span>
      <span className="milestone-when">
        <button type="button" className="milestone-date" title={text.moveMilestone} onClick={() => openPicker(dateInput.current)}>
          {format(shownAt, "d MMM", { locale: dateLocale() })}
        </button>
        <input ref={dateInput} type="date" tabIndex={-1} aria-label={text.milestoneDate} value={formatDay(at)} onChange={(e) => changeDay(e.target.value)} />
        <button type="button" className={`milestone-time${shownTime ? "" : " empty"}`} title={text.eventTimeHint} onClick={() => openPicker(timeInput.current)}>
          {shownTime || text.addTime}
        </button>
        <input ref={timeInput} type="time" tabIndex={-1} aria-label={text.milestoneTime} value={time} onChange={(e) => changeTime(e.target.value)} />
      </span>
      <button
        type="button"
        className="milestone-title"
        onPointerDown={onDragStart}
        onClick={() => {
          goToDate(at);
          editEvent(event.id);
        }}
      >
        {event.title}
      </button>
      <button type="button" className="milestone-delete" aria-label={text.deleteMilestone(event.title)} title={text.deleteMilestone(event.title)} onClick={() => deleteEvent(projectId, event.id)}>
        <svg viewBox="0 0 24 24" aria-hidden>
          <path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13" />
        </svg>
      </button>
    </li>
  );
}
