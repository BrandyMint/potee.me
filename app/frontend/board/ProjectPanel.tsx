import { format, set as setTime } from "date-fns";
import {
  useEffect,
  useRef,
  useState,
  type CSSProperties,
  type PointerEvent,
  type ReactNode,
} from "react";
import { useBoard, useBoardView } from "./context";
import { startDrag } from "./drag";
import { dateLocale, formatTime, t } from "./i18n";
import { isSaved } from "./store";
import { COLORS_COUNT, formatDay, parseDay, projectDays } from "./timeline";
import type { BoardEvent, Card } from "./types";

/**
 * Tools of the selected project, shown in the board header in place of "New
 * project" and "Plan from text": rename (in the bar), share, colour, Entire,
 * delete, details (the dialog below) and deselect.
 */
export function ProjectTools() {
  const card = useBoard((state) => state.projects.find((project) => project.id === state.selectedId));
  if (!card || !isSaved(card.id)) return null;
  return <Tools key={card.id} card={card} />;
}

function Tools({ card }: { card: Card }) {
  const { showProject } = useBoardView();
  const updateProject = useBoard((state) => state.updateProject);
  const deleteProject = useBoard((state) => state.deleteProject);
  const renameProject = useBoard((state) => state.renameProject);
  const openPanel = useBoard((state) => state.openPanel);
  const select = useBoard((state) => state.select);
  const [share, setShare] = useState<"idle" | "copied" | "manual">("idle");
  const [paletteOpen, setPaletteOpen] = useState(false);
  const palette = useRef<HTMLDivElement>(null);
  const text = t();

  // The palette closes on a click elsewhere.
  useEffect(() => {
    if (!paletteOpen) return;
    const close = (event: Event) => {
      if (!palette.current?.contains(event.target as Node)) setPaletteOpen(false);
    };
    document.addEventListener("pointerdown", close);
    return () => document.removeEventListener("pointerdown", close);
  }, [paletteOpen]);

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
  const removeLabel = card.owner ? text.delete : text.removeFromBoard;

  return (
    <div className={`panel-toolbar project-tools project-color-${card.color_index}`} role="toolbar" aria-label={card.title}>
      <ToolButton label={text.rename} onClick={() => renameProject(card.id)}>
        <Icon path="M4 20h4L19 9l-4-4L4 16z" />
      </ToolButton>
      <ToolButton label={share === "copied" ? `✓ ${text.linkCopied}` : text.share} hint={text.shareHint} onClick={() => void copyLink()} text>
        <Icon path="M10 14a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1M14 10a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1" />
      </ToolButton>
      <div className="project-tools-colour" ref={palette}>
        <ToolButton label={text.changeColour} pressed={paletteOpen} onClick={() => setPaletteOpen(!paletteOpen)}>
          <span className="panel-colour" />
        </ToolButton>
        {paletteOpen && (
          <div className="popover panel-palette" role="group" aria-label={text.changeColour}>
            {Array.from({ length: COLORS_COUNT }, (_, index) => (
              <button
                key={index}
                type="button"
                className={`project-color-${index}${index === card.color_index ? " current" : ""}`}
                aria-label={text.colour(index + 1)}
                aria-pressed={index === card.color_index}
                onClick={() => {
                  setPaletteOpen(false);
                  void updateProject(card.id, { color_index: index });
                }}
              />
            ))}
          </div>
        )}
      </div>
      <ToolButton label={text.entire} hint={text.entireHint} onClick={() => showProject(card.id)}>
        <Icon path="M15 3h6v6M21 3l-7 7M9 21H3v-6M3 21l7-7M21 15v6h-6M21 21l-7-7M3 9V3h6M3 3l7 7" />
      </ToolButton>
      <ToolButton label={removeLabel} className="danger" onClick={() => deleteProject(card.id)}>
        <Icon path="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13" />
      </ToolButton>
      <span className="panel-separator" />
      <ToolButton label={text.details} hint={text.detailsHint} onClick={() => openPanel(true)} text>
        <Icon path="M4 6h16M4 12h16M4 18h10" />
      </ToolButton>
      <ToolButton label={text.close} hint={`${text.close} (Esc)`} onClick={() => select(null)}>
        <Icon path="M6 6l12 12M18 6L6 18" />
      </ToolButton>
      {share === "manual" && (
        <input
          className="popover panel-share-url"
          readOnly
          autoFocus
          aria-label={text.copyLink}
          value={card.share_url}
          onFocus={(event) => event.currentTarget.select()}
          onBlur={() => setShare("idle")}
        />
      )}
    </div>
  );
}

/**
 * Details of the selected project in a dialog in the middle of the blurred
 * board: dates and the milestone list (add, move, reorder, delete).
 * Opened by "Details" in the header or a second click on the project; on
 * narrow screens it is a bottom sheet.
 */
export function ProjectPanel() {
  const card = useBoard((state) => state.projects.find((project) => project.id === state.selectedId));
  const renaming = useBoard((state) => state.renamingId !== null && state.renamingId === state.selectedId);
  const open = useBoard((state) => state.panelOpen);
  // While the title is edited in the bar, the dialog steps aside.
  const visible = card !== undefined && isSaved(card.id) && open && !renaming;
  // A closed dialog stays a moment longer, fading out (not clickable).
  const [shown, setShown] = useState<Card | null>(null);
  useEffect(() => {
    if (visible) {
      setShown(card);
      return;
    }
    const timer = window.setTimeout(() => setShown(null), PANEL_FADE_MS);
    return () => window.clearTimeout(timer);
  }, [visible, card]);
  const current = visible ? card : shown;
  if (!current) return null;
  return <Panel key={current.id} card={current} closing={!visible} />;
}

/** Fade-out of a closed dialog; matches the panel-out animation in board.css. */
const PANEL_FADE_MS = 140;

function Panel({ card, closing }: { card: Card; closing: boolean }) {
  const { goToDate, today } = useBoardView();
  const updateProject = useBoard((state) => state.updateProject);
  const addEvent = useBoard((state) => state.addEvent);
  const openPanel = useBoard((state) => state.openPanel);
  const text = t();

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

  const events = [...card.events].sort((a, b) => a.at.localeCompare(b.at));

  return (
    <>
      <div className={`panel-backdrop${closing ? " closing" : ""}`} onClick={() => openPanel(false)} aria-hidden />
      <div
        className={`project-panel project-color-${card.color_index}${closing ? " closing" : ""}`}
        role="dialog"
        aria-modal="true"
        aria-label={text.projectPanel}
      >
        <header className="panel-header">
          <span className="panel-colour" aria-hidden />
          <h2>{card.title}</h2>
          <button type="button" className="panel-close" aria-label={text.close} title={`${text.close} (Esc)`} onClick={() => openPanel(false)}>
            <Icon path="M6 6l12 12M18 6L6 18" />
          </button>
        </header>
        <div className="panel-body">
          <section>
            <h3>
              {text.dates}
              <span>{text.daysCount(projectDays(card))}</span>
            </h3>
            <div className="panel-dates">
              <input type="date" aria-label={text.startDate} value={card.started_on} max={card.finished_on} onChange={(event) => changeDate("started_on", event.target.value)} />
              <span aria-hidden>→</span>
              <input type="date" aria-label={text.finishDate} value={card.finished_on} min={card.started_on} onChange={(event) => changeDate("finished_on", event.target.value)} />
            </div>
          </section>

          <section>
            <h3>
              {text.milestones}
              <button type="button" className="panel-link" onClick={addMilestone}>
                + {text.addMilestone}
              </button>
            </h3>
            {events.length === 0 ? (
              <p className="panel-muted">{text.noMilestones}</p>
            ) : (
              <MilestoneList projectId={card.id} events={events} today={today} />
            )}
          </section>
        </div>
      </div>
    </>
  );
}

function ToolButton(props: {
  label: string;
  hint?: string;
  pressed?: boolean;
  className?: string;
  /** Show the label next to the icon, not only as a tooltip. */
  text?: boolean;
  onClick: () => void;
  children: ReactNode;
}) {
  return (
    <button
      type="button"
      className={props.className}
      // Always named: on phones the visible label is hidden.
      aria-label={props.label}
      aria-pressed={props.pressed}
      title={props.hint ?? props.label}
      onClick={props.onClick}
    >
      {props.children}
      {props.text && <span className="panel-label">{props.label}</span>}
    </button>
  );
}

function Icon({ path }: { path: string }) {
  return (
    <svg className="panel-icon" viewBox="0 0 24 24" aria-hidden>
      <path d={path} />
    </svg>
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
    <ul className={`panel-milestones${drag ? " reordering" : ""}`} ref={list}>
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
  const openPanel = useBoard((state) => state.openPanel);
  const dateInput = useRef<HTMLInputElement>(null);
  const timeInput = useRef<HTMLInputElement>(null);
  const text = t();
  const at = new Date(event.at);
  const time = event.timed ? format(at, "HH:mm") : "";
  const shownAt = new Date(slot.at);
  const shownTime = slot.timed ? formatTime(shownAt) : "";

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
          // The milestone is edited on the board: the dialog steps aside.
          openPanel(false);
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
