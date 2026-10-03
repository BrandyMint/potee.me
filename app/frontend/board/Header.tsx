import { useEffect, useRef, useState } from "react";
import logoUrl from "../images/logo.png";
import { useBoard, useBoardView } from "./context";
import { t } from "./i18n";
import { SCALE, scaleMode, xOf, type ScaleMode } from "./timeline";

const SCALE_BUTTONS: { mode: ScaleMode; pixelsPerDay: number }[] = [
  { mode: "days", pixelsPerDay: SCALE.DAYS },
  { mode: "weeks", pixelsPerDay: SCALE.WEEKS },
  { mode: "months", pixelsPerDay: SCALE.MONTHS },
];

export function Header({ onNewProject, onShowAll }: { onNewProject: () => void; onShowAll: () => void }) {
  const { timeline, today, viewportWidth, scrollLeft, goToToday } = useBoardView();
  const pixelsPerDay = useBoard((state) => state.pixelsPerDay);
  const setScale = useBoard((state) => state.setScale);
  const user = useBoard((state) => state.user);
  const planEnabled = useBoard((state) => state.features.plan_from_text);
  const setPlanOpen = useBoard((state) => state.setPlanOpen);
  const mode = scaleMode(pixelsPerDay);
  const text = t();

  const todayX = xOf(timeline, today) + pixelsPerDay / 2;
  const todayDirection = todayX < scrollLeft ? "left" : todayX > scrollLeft + viewportWidth ? "right" : null;

  return (
    <header className="board-header">
      <button type="button" className="brand" onClick={onShowAll} title={text.showAll} aria-label={text.showAll}>
        <img src={logoUrl} alt="Potee" />
      </button>
      <div className="scale-buttons" role="group" aria-label={text.zoomHint} title={text.zoomHint}>
        {SCALE_BUTTONS.map((button) => (
          <button
            key={button.mode}
            type="button"
            className={mode === button.mode ? "active" : undefined}
            aria-label={text[button.mode]}
            onClick={() => setScale(button.pixelsPerDay)}
          >
            <span className="label-long">{text[button.mode]}</span>
            <span className="label-short" aria-hidden>
              {text[`${button.mode}Short`]}
            </span>
          </button>
        ))}
      </div>
      {todayDirection && (
        <button type="button" className="today-link" onClick={goToToday} title={text.goToToday}>
          {todayDirection === "left" ? text.moveToTodayLeft : text.moveToTodayRight}
        </button>
      )}
      <button type="button" className="new-project" onClick={onNewProject} title={text.newProjectHint} aria-label={text.newProject}>
        <span aria-hidden>+</span>
        <span className="label-long">{text.newProject}</span>
      </button>
      {planEnabled && (
        <button type="button" className="plan-button" onClick={() => setPlanOpen(true)} title={text.planFromText} aria-label={text.planFromText}>
          <span aria-hidden>✨</span>
          <span className="label-long">{text.planFromText}</span>
        </button>
      )}
      <div className="header-spacer" />
      <HelpButton />
      <Account email={user.email} anonymous={user.anonymous} />
    </header>
  );
}

function HelpButton() {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const text = t();

  useEffect(() => {
    if (!open) return;
    const close = (event: Event) => {
      if (event instanceof globalThis.KeyboardEvent ? event.key === "Escape" : !ref.current?.contains(event.target as Node)) {
        setOpen(false);
      }
    };
    window.addEventListener("pointerdown", close);
    window.addEventListener("keydown", close);
    return () => {
      window.removeEventListener("pointerdown", close);
      window.removeEventListener("keydown", close);
    };
  }, [open]);

  return (
    <div className="help" ref={ref}>
      <button type="button" className="help-button" aria-expanded={open} aria-label={text.help} title={text.help} onClick={() => setOpen(!open)}>
        ?
      </button>
      {open && (
        <div className="popover help-popover" role="dialog" aria-label={text.helpTitle}>
          <h2>{text.helpTitle}</h2>
          <dl>
            {text.helpItems.map(([action, result]) => (
              <div key={action}>
                <dt>{action}</dt>
                <dd>{result}</dd>
              </div>
            ))}
          </dl>
        </div>
      )}
    </div>
  );
}

function Account({ email, anonymous }: { email: string | null; anonymous: boolean }) {
  const text = t();
  if (anonymous) {
    return (
      <nav className="account">
        <a className="signup-hint" href="/signup">
          <span className="label-long">{text.signUp}</span>
          <span className="label-short">{text.signUpShort}</span>
        </a>
        <a href="/login">{text.logIn}</a>
      </nav>
    );
  }
  const token = document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')?.content ?? "";
  return (
    <form className="account" method="post" action="/logout">
      <input type="hidden" name="_method" value="delete" />
      <input type="hidden" name="authenticity_token" value={token} />
      <a className="account-email" href="/account">
        {email}
      </a>
      <button type="submit">{text.logOut}</button>
    </form>
  );
}
