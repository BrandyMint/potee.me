// "Plan from text" (FT-001): a side panel where a registered user describes a
// plan in plain text; the model's draft is previewed on the board and added
// only when the user confirms.
import { differenceInCalendarDays, parseISO } from "date-fns";
import { useEffect, useRef, useState } from "react";
import { api, ApiError } from "./api";
import { useBoard, useBoardView } from "./context";
import { t } from "./i18n";
import { parseDay, xOf } from "./timeline";
import type { PlanProject } from "./types";

const MAX_LENGTH = 2000;
const FIRST_POLL = 500;
const POLL_EVERY = 1500;

type Phase = { kind: "input" } | { kind: "waiting"; id: number } | { kind: "preview"; id: number } | { kind: "error"; code: string };

export function PlanPanel() {
  const open = useBoard((state) => state.planOpen);
  const enabled = useBoard((state) => state.features.plan_from_text);
  if (!enabled || !open) return null;
  return <Panel />;
}

function Panel() {
  const { fitRanges } = useBoardView();
  const anonymous = useBoard((state) => state.user.anonymous);
  const preview = useBoard((state) => state.planPreview);
  const setPlanOpen = useBoard((state) => state.setPlanOpen);
  const setPlanPreview = useBoard((state) => state.setPlanPreview);
  const appendProjects = useBoard((state) => state.appendProjects);
  const projects = useBoard((state) => state.projects);
  const [prompt, setPrompt] = useState("");
  const [phase, setPhase] = useState<Phase>({ kind: "input" });
  const [applying, setApplying] = useState(false);
  const timer = useRef<ReturnType<typeof setTimeout>>(undefined);
  const text = t();

  useEffect(() => () => clearTimeout(timer.current), []);

  const close = () => {
    clearTimeout(timer.current);
    if (phase.kind === "preview") void api.discardPlan(phase.id).catch(() => undefined);
    setPlanOpen(false);
  };

  useEffect(() => {
    const onKey = (event: KeyboardEvent) => event.key === "Escape" && close();
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  });

  const poll = (id: number, delay: number) => {
    timer.current = setTimeout(async () => {
      try {
        const state = await api.planStatus(id);
        if (state.status === "pending") return poll(id, POLL_EVERY);
        if (state.status === "ready" && state.draft) {
          const draft = state.draft.projects;
          setPlanPreview({ projects: draft, selected: draft.map((project) => project.key) });
          setPhase({ kind: "preview", id });
          fitRanges([...projects, ...draft.map((project) => ({ started_on: project.start_date, finished_on: project.end_date }))]);
          return;
        }
        setPhase({ kind: "error", code: state.error ?? "unknown" });
      } catch {
        setPhase({ kind: "error", code: "llm_unavailable" });
      }
    }, delay);
  };

  const generate = async () => {
    try {
      const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone || "Europe/Moscow";
      const state = await api.createPlan(prompt.trim(), timezone);
      setPhase({ kind: "waiting", id: state.id });
      poll(state.id, FIRST_POLL);
    } catch (error) {
      const code = error instanceof ApiError && isErrorBody(error.body) ? error.body.error : "llm_unavailable";
      setPhase({ kind: "error", code });
    }
  };

  const toggle = (key: string) => {
    if (!preview) return;
    const selected = preview.selected.includes(key) ? preview.selected.filter((k) => k !== key) : [...preview.selected, key];
    setPlanPreview({ ...preview, selected });
  };

  const apply = async () => {
    if (phase.kind !== "preview" || !preview || preview.selected.length === 0) return;
    setApplying(true);
    try {
      const { projects: cards } = await api.applyPlan(phase.id, preview.selected);
      appendProjects(cards);
      setPlanOpen(false);
    } catch {
      setPhase({ kind: "error", code: "apply_failed" });
    } finally {
      setApplying(false);
    }
  };

  const back = () => {
    if (phase.kind === "preview") void api.discardPlan(phase.id).catch(() => undefined);
    setPlanPreview(null);
    setPhase({ kind: "input" });
  };

  return (
    <aside className="plan-panel" role="dialog" aria-label={text.planFromText}>
      <header>
        <h2>✨ {text.planFromText}</h2>
        <button type="button" className="close" aria-label={text.close} onClick={close}>
          ×
        </button>
      </header>

      {anonymous ? (
        <div className="plan-body">
          <p>{text.planSignUpOnly}</p>
          <a className="plan-primary" href="/signup">
            {text.signUpShort}
          </a>
        </div>
      ) : phase.kind === "input" || phase.kind === "waiting" ? (
        <form
          className="plan-body"
          onSubmit={(event) => {
            event.preventDefault();
            if (phase.kind === "input" && prompt.trim()) void generate();
          }}
        >
          <textarea
            aria-label={text.planFromText}
            placeholder={text.planPlaceholder}
            value={prompt}
            maxLength={MAX_LENGTH}
            rows={7}
            autoFocus
            disabled={phase.kind === "waiting"}
            onChange={(event) => setPrompt(event.target.value)}
            onKeyDown={(event) => {
              if (event.key === "Enter" && (event.metaKey || event.ctrlKey)) event.currentTarget.form?.requestSubmit();
            }}
          />
          <p className="plan-note">{text.planProviderNote}</p>
          <button type="submit" className="plan-primary" disabled={phase.kind === "waiting" || !prompt.trim()}>
            {phase.kind === "waiting" ? <span className="plan-spinner">{text.planWorking}</span> : text.planGenerate}
          </button>
        </form>
      ) : phase.kind === "error" ? (
        <div className="plan-body">
          <p className="plan-error" role="alert">
            {text.planErrors[phase.code as keyof typeof text.planErrors] ?? text.planErrors.unknown}
          </p>
          <button type="button" className="plan-primary" onClick={() => setPhase({ kind: "input" })}>
            {text.planRetry}
          </button>
        </div>
      ) : (
        preview && (
          <div className="plan-body">
            <p>{text.planReview}</p>
            <ul className="plan-list">
              {preview.projects.map((project) => (
                <li key={project.key}>
                  <label>
                    <input type="checkbox" checked={preview.selected.includes(project.key)} onChange={() => toggle(project.key)} />
                    <span className="plan-project-title">{project.title}</span>
                    <span className="plan-dates">
                      {shortDate(project.start_date)} – {shortDate(project.end_date)}
                      {project.adjusted && <span title={text.planAdjusted}> *</span>}
                    </span>
                  </label>
                  {project.events.length > 0 && (
                    <ul>
                      {project.events.map((event, index) => (
                        <li key={index}>
                          {shortDate(event.date)}
                          {event.time !== "12:00" && ` ${event.time}`} — {event.title}
                        </li>
                      ))}
                    </ul>
                  )}
                </li>
              ))}
            </ul>
            <div className="plan-actions">
              <button type="button" className="plan-secondary" onClick={back}>
                {text.planBack}
              </button>
              <button type="button" className="plan-primary" disabled={applying || preview.selected.length === 0} onClick={() => void apply()}>
                {text.planAdd(preview.selected.length)}
              </button>
            </div>
          </div>
        )
      )}
    </aside>
  );
}

/** A previewed project drawn on the board like a draft: dashed, not editable. */
export function PreviewRow({ project, colorIndex, selected }: { project: PlanProject; colorIndex: number; selected: boolean }) {
  const { timeline } = useBoardView();
  const start = parseDay(project.start_date);
  const left = xOf(timeline, start);
  const width = (differenceInCalendarDays(parseDay(project.end_date), start) + 1) * timeline.pixelsPerDay;
  return (
    <div className={`project preview project-color-${colorIndex}${selected ? "" : " excluded"}`} data-testid={`preview-${project.title}`}>
      <div className="project-bar" style={{ left, width }}>
        <div className="project-title">
          <span className="project-title-text">{project.title}</span>
        </div>
      </div>
      {project.events.map((event, index) => {
        const x = xOf(timeline, parseISO(`${event.date}T${event.time}`));
        return (
          <div key={index} className="event preview-event" style={{ left: x }}>
            <div className="event-title">{event.title}</div>
            <div className="event-bar" />
          </div>
        );
      })}
    </div>
  );
}

function shortDate(day: string): string {
  return parseDay(day).toLocaleDateString(document.documentElement.lang || undefined, { day: "numeric", month: "short" });
}

function isErrorBody(body: unknown): body is { error: string } {
  return typeof body === "object" && body !== null && typeof (body as { error?: unknown }).error === "string";
}
