import { useEffect, useState, type KeyboardEvent } from "react";
import logoUrl from "../images/logo.png";
import { useBoard, useBoardView } from "./context";
import { isSaved } from "./store";
import { COLORS_COUNT, SCALE, scaleMode, xOf, type ScaleMode } from "./timeline";
import type { Card } from "./types";

const SCALE_BUTTONS: { mode: ScaleMode; pixelsPerDay: number }[] = [
  { mode: "days", pixelsPerDay: SCALE.DAYS },
  { mode: "weeks", pixelsPerDay: SCALE.WEEKS },
  { mode: "months", pixelsPerDay: SCALE.MONTHS },
];

export function Header({ onNewProject }: { onNewProject: () => void }) {
  const { timeline, today, viewportWidth, scrollLeft, goToDate } = useBoardView();
  const pixelsPerDay = useBoard((state) => state.pixelsPerDay);
  const setScale = useBoard((state) => state.setScale);
  const user = useBoard((state) => state.user);
  const selected = useBoard((state) => state.projects.find((card) => card.id === state.selectedId));
  const mode = scaleMode(pixelsPerDay);

  const todayX = xOf(timeline, today) + pixelsPerDay / 2;
  const todayDirection = todayX < scrollLeft ? "left" : todayX > scrollLeft + viewportWidth ? "right" : null;

  return (
    <header className="board-header">
      <button type="button" className="brand" onClick={() => goToDate(new Date())} title="Go to today">
        <img src={logoUrl} alt="Potee" />
      </button>
      <div className="scale-buttons" role="group" aria-label="Zoom">
        {SCALE_BUTTONS.map((button) => (
          <button
            key={button.mode}
            type="button"
            className={mode === button.mode ? "active" : undefined}
            onClick={() => setScale(button.pixelsPerDay)}
          >
            {button.mode}
          </button>
        ))}
      </div>
      {todayDirection && (
        <button type="button" className="today-link" onClick={() => goToDate(new Date())}>
          {todayDirection === "left" ? "← move to today" : "move to today →"}
        </button>
      )}
      <div className="header-main">
        {selected && isSaved(selected.id) ? (
          <ProjectPanel key={selected.id} card={selected} />
        ) : (
          <button type="button" className="new-project" onClick={onNewProject}>
            + New project
          </button>
        )}
      </div>
      <Account email={user.email} anonymous={user.anonymous} />
    </header>
  );
}

function ProjectPanel({ card }: { card: Card }) {
  const { showProject } = useBoardView();
  const updateProject = useBoard((state) => state.updateProject);
  const deleteProject = useBoard((state) => state.deleteProject);
  const select = useBoard((state) => state.select);
  const [title, setTitle] = useState(card.title);
  const [copied, setCopied] = useState(false);

  useEffect(() => setTitle(card.title), [card.title]);

  const save = () => {
    const value = title.trim();
    if (value && value !== card.title) void updateProject(card.id, { title: value });
    else setTitle(card.title);
  };
  const onKeyDown = (event: KeyboardEvent<HTMLInputElement>) => {
    if (event.key === "Enter") event.currentTarget.blur();
    if (event.key === "Escape") {
      setTitle(card.title);
      event.currentTarget.blur();
    }
  };
  const share = async () => {
    await navigator.clipboard.writeText(card.share_url);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="project-panel">
      <button
        type="button"
        className={`color-swatch project-color-${card.color_index}`}
        title="Change colour"
        aria-label="Change colour"
        onClick={() => void updateProject(card.id, { color_index: (card.color_index + 1) % COLORS_COUNT })}
      />
      <input
        className="panel-title"
        aria-label="Selected project title"
        value={title}
        onChange={(event) => setTitle(event.target.value)}
        onBlur={save}
        onKeyDown={onKeyDown}
      />
      <button type="button" onClick={() => showProject(card.id)}>
        Entire
      </button>
      <button type="button" onClick={() => void share()} title="Copy the share link">
        {copied ? "Link copied" : "Share"}
      </button>
      <button
        type="button"
        className="danger"
        onClick={() => {
          if (window.confirm(`Delete "${card.title}"?`)) void deleteProject(card.id);
        }}
      >
        Delete
      </button>
      <button type="button" className="close" aria-label="Close" onClick={() => select(null)}>
        ×
      </button>
    </div>
  );
}

function Account({ email, anonymous }: { email: string | null; anonymous: boolean }) {
  if (anonymous) {
    return (
      <nav className="account">
        <a className="signup-hint" href="/signup">
          Sign up to save your projects
        </a>
        <a href="/login">Log in</a>
      </nav>
    );
  }
  const token = document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')?.content ?? "";
  return (
    <form className="account" method="post" action="/logout">
      <input type="hidden" name="_method" value="delete" />
      <input type="hidden" name="authenticity_token" value={token} />
      <span className="account-email">{email}</span>
      <button type="submit">Log out</button>
    </form>
  );
}
