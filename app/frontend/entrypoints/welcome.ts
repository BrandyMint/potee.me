// Landing page background: an endless board where time runs fast. The "today"
// line passes milestones, and the card counts down to the next step on a
// visible project, which is lit up on the board.

type Texts = {
  today: string;
  next_step: string;
  in_days: Record<string, string>;
  projects: string[][];
};

type Milestone = { day: number; title: string; el: HTMLElement };
type Bar = { el: HTMLElement; start: number; end: number; top: number; title: string; color: string; events: Milestone[] };
type Target = { bar: Bar; milestone: Milestone };

const COLORS = ["#5abce4", "#f57969", "#f5ab69", "#eed88b", "#ca7776", "#c1d270", "#ab88c4", "#71c3e2", "#c0b393", "#7fd9c1"];
const DAY_MS = 1300; // real milliseconds per board day
const VISIBLE_DAYS = 90; // about three months fit the screen width
const TOP = 70;
const BAR_OFFSET = 24;
const MS_PER_DAY = 86_400_000;

const track = document.querySelector<HTMLElement>(".welcome-track");
const todayLine = document.querySelector<HTMLElement>(".welcome-today");
const next = document.querySelector<HTMLElement>(".welcome-next");
const card = document.querySelector<HTMLElement>(".welcome-card");
const data = document.getElementById("welcome-data");

if (track && todayLine && next && card && data) start(JSON.parse(data.textContent || "{}") as Texts);

function start(texts: Texts) {
  const locale = document.documentElement.lang || "ru";
  const plural = new Intl.PluralRules(locale);
  const reduceMotion = matchMedia("(prefers-reduced-motion: reduce)");
  const narrow = innerWidth <= 760;
  const pxPerDay = Math.max(7, innerWidth / VISIBLE_DAYS);
  const rowCount = Math.min(6, Math.max(3, Math.floor((innerHeight - TOP) / 110)));
  const rowHeight = (innerHeight - TOP - 20) / rowCount;
  const now = new Date();
  const base = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const rows = Array.from({ length: rowCount }, () => ({ end: -50 + Math.random() * 40 }));
  const bars: Bar[] = [];
  const months: { el: HTMLElement; day: number }[] = [];
  const lastUsed = new Map<string, number>();
  let monthsUntil = -60;
  let day = 0;
  let last = performance.now();
  let target: Target | null = null;
  let shown = "";
  let cardRect = card!.getBoundingClientRect();
  addEventListener("resize", () => (cardRect = card!.getBoundingClientRect()));

  const nextText = next!.querySelector<HTMLElement>(".welcome-next-text")!;
  const nextDays = next!.querySelector("small")!;
  todayLine!.querySelector("b")!.textContent = texts.today;
  todayLine!.hidden = false;
  next!.hidden = false;

  // The project not seen for the longest time, so the screen has no repeats.
  function pickProject() {
    const onScreen = new Set(bars.map((bar) => bar.title));
    const candidates = texts.projects.filter(([title = ""]) => !onScreen.has(title));
    const pool = candidates.length ? candidates : texts.projects;
    const oldest = Math.min(...pool.map(([title = ""]) => lastUsed.get(title) ?? -1));
    const fresh = pool.filter(([title = ""]) => (lastUsed.get(title) ?? -1) === oldest);
    const project = fresh[Math.floor(Math.random() * fresh.length)] ?? [];
    lastUsed.set(project[0] ?? "", day + Math.random());
    return project;
  }

  function spawn(row: { end: number }, rowIndex: number) {
    const start = row.end + 10 + Math.random() * 16;
    const length = 26 + Math.random() * 20;
    const [title = "", ...milestones] = pickProject();
    const color = COLORS[Math.floor(Math.random() * COLORS.length)] ?? COLORS[0]!;
    const top = TOP + rowIndex * rowHeight + BAR_OFFSET;
    const el = document.createElement("div");
    el.className = "welcome-bar";
    el.style.cssText = `left:${start * pxPerDay}px;top:${top}px;width:${length * pxPerDay}px;--c:${color}`;
    const label = document.createElement("span");
    label.textContent = title;
    el.append(label);
    const events = milestones.map((milestone, i) => {
      const at = start + (length * (i + 1)) / (milestones.length + 0.3);
      const tick = document.createElement("i");
      tick.style.left = `${(at - start) * pxPerDay}px`;
      el.append(tick);
      return { day: at, title: milestone, el: tick };
    });
    track!.append(el);
    bars.push({ el, start, end: start + length, top, title, color, events });
    row.end = start + length;
  }

  function addMonths(untilDay: number) {
    while (monthsUntil < untilDay) {
      const first = new Date(base.getFullYear(), base.getMonth(), base.getDate() + monthsUntil);
      first.setMonth(first.getMonth() + 1, 1);
      const firstDay = Math.round((first.getTime() - base.getTime()) / MS_PER_DAY);
      const el = document.createElement("div");
      el.className = "welcome-month";
      el.style.left = `${firstDay * pxPerDay}px`;
      el.textContent = first.toLocaleDateString(locale, { month: "long", year: "numeric" });
      track!.append(el);
      months.push({ el, day: firstDay });
      monthsUntil = firstDay + 1;
    }
  }

  // A milestone the visitor can see: on screen and not behind the card.
  function visible(bar: Bar, milestone: Milestone, todayX: number) {
    const x = todayX + (milestone.day - day) * pxPerDay;
    if (x > innerWidth - 24) return false;
    const behindCard =
      x > cardRect.left - 12 && x < cardRect.right + 12 && bar.top + 26 > cardRect.top && bar.top - 4 < cardRect.bottom;
    return !behindCard;
  }

  function showNext({ bar, milestone }: Target) {
    const days = Math.max(1, Math.ceil(milestone.day - day));
    const key = `${milestone.title}/${bar.title}/${days}`;
    if (key === shown) return;
    shown = key;
    next!.style.setProperty("--c", bar.color);
    nextText.replaceChildren(`${texts.next_step}: `, Object.assign(document.createElement("em"), { textContent: milestone.title }), ` · ${bar.title}`);
    const form = texts.in_days[plural.select(days)] ?? texts.in_days.other ?? "%{count}";
    nextDays.textContent = form.replace("%{count}", String(days));
  }

  function frame(time: number) {
    // Clamp so a background tab does not jump the board months ahead.
    if (!reduceMotion.matches) day += Math.min(time - last, 100) / DAY_MS;
    last = time;
    const todayX = innerWidth * (narrow ? 0.3 : 0.38);
    track!.style.transform = `translateX(${todayX - day * pxPerDay}px)`;
    todayLine!.style.left = `${todayX}px`;

    const rightDay = day + (innerWidth - todayX) / pxPerDay + 20;
    rows.forEach((row, i) => {
      while (row.end < rightDay) spawn(row, i);
    });
    addMonths(rightDay);
    while (months[1] && (months[1].day - day) * pxPerDay < -todayX) months.shift()!.el.remove();

    // Keep counting down to the same milestone until the today line passes it.
    if (target && (target.milestone.day < day || !bars.includes(target.bar))) target = null;
    let best: Target | null = target;
    for (let i = bars.length - 1; i >= 0; i--) {
      const bar = bars[i]!;
      if ((bar.end - day) * pxPerDay < -todayX - 20) {
        bar.el.remove();
        bars.splice(i, 1);
        continue;
      }
      bar.el.classList.toggle("past", bar.end < day);
      bar.el.classList.toggle("active", bar.start <= day && day <= bar.end);
      for (const milestone of bar.events) {
        milestone.el.classList.toggle("done", milestone.day < day);
        if (!target && milestone.day >= day && (!best || milestone.day < best.milestone.day) && visible(bar, milestone, todayX))
          best = { bar, milestone };
      }
    }
    if (best !== target) {
      target?.bar.el.classList.remove("focus");
      target?.milestone.el.classList.remove("next");
      target = best;
      target?.bar.el.classList.add("focus");
      target?.milestone.el.classList.add("next");
    }
    if (target) showNext(target);
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);
}
