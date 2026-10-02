// Landing page background: an endless board where time runs fast. The "today"
// line passes milestones, and the card shows the next step on the board.

type Texts = {
  today: string;
  next_step: string;
  in_days: Record<string, string>;
  projects: string[][];
};

type Milestone = { day: number; title: string; el: HTMLElement };
type Bar = { el: HTMLElement; start: number; end: number; title: string; color: string; events: Milestone[] };

const COLORS = ["#5abce4", "#f57969", "#f5ab69", "#eed88b", "#ca7776", "#c1d270", "#ab88c4", "#71c3e2", "#c0b393", "#7fd9c1"];
const DAY_MS = 650; // real milliseconds per board day
const ROW_HEIGHT = 64;
const TOP = 70;
const MS_PER_DAY = 86_400_000;

const track = document.querySelector<HTMLElement>(".welcome-track");
const todayLine = document.querySelector<HTMLElement>(".welcome-today");
const next = document.querySelector<HTMLElement>(".welcome-next");
const data = document.getElementById("welcome-data");

if (track && todayLine && next && data) start(JSON.parse(data.textContent || "{}") as Texts);

function start(texts: Texts) {
  const locale = document.documentElement.lang || "ru";
  const plural = new Intl.PluralRules(locale);
  const reduceMotion = matchMedia("(prefers-reduced-motion: reduce)");
  const narrow = innerWidth <= 760;
  const pxPerDay = narrow ? 7 : 11;
  const now = new Date();
  const base = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const dateAt = (day: number) => new Date(base.getFullYear(), base.getMonth(), base.getDate() + Math.floor(day));
  const rows = Array.from({ length: Math.max(4, Math.floor((innerHeight - TOP) / ROW_HEIGHT)) }, () => ({
    end: -40 + Math.random() * 30,
  }));
  const bars: Bar[] = [];
  const months: { el: HTMLElement; day: number }[] = [];
  let projectIndex = Math.floor(Math.random() * texts.projects.length);
  let monthsUntil = -60;
  let day = 0;
  let last = performance.now();
  let shown = "";

  const todayLabel = todayLine!.querySelector("b")!;
  const nextText = next!.querySelector<HTMLElement>(".welcome-next-text")!;
  const nextDays = next!.querySelector("small")!;
  todayLine!.hidden = false;
  next!.hidden = false;

  function spawn(row: { end: number }, rowIndex: number) {
    const start = row.end + 4 + Math.random() * 14;
    const length = 18 + Math.random() * 30;
    const [title = "", ...milestones] = texts.projects[projectIndex++ % texts.projects.length] ?? [];
    const color = COLORS[Math.floor(Math.random() * COLORS.length)] ?? COLORS[0]!;
    const el = document.createElement("div");
    el.className = "welcome-bar";
    el.style.cssText = `left:${start * pxPerDay}px;top:${TOP + rowIndex * ROW_HEIGHT + 24}px;width:${length * pxPerDay}px;--c:${color}`;
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
    bars.push({ el, start, end: start + length, title, color, events });
    row.end = start + length;
  }

  function addMonths(untilDay: number) {
    while (monthsUntil < untilDay) {
      const date = dateAt(monthsUntil);
      const first = new Date(date.getFullYear(), date.getMonth() + 1, 1);
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

  function showNext(bar: Bar, milestone: Milestone) {
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
    todayLabel.textContent = `${texts.today} · ${dateAt(day).toLocaleDateString(locale, { day: "numeric", month: "long" })}`;

    const rightDay = day + (innerWidth - todayX) / pxPerDay + 20;
    rows.forEach((row, i) => {
      while (row.end < rightDay) spawn(row, i);
    });
    addMonths(rightDay);
    while (months[1] && (months[1].day - day) * pxPerDay < -todayX) months.shift()!.el.remove();

    let best: { bar: Bar; milestone: Milestone } | null = null;
    for (let i = bars.length - 1; i >= 0; i--) {
      const bar = bars[i]!;
      if ((bar.end - day) * pxPerDay < -todayX - 200) {
        bar.el.remove();
        bars.splice(i, 1);
        continue;
      }
      bar.el.classList.toggle("active", bar.start <= day && day <= bar.end);
      for (const milestone of bar.events) {
        milestone.el.classList.toggle("done", milestone.day < day);
        milestone.el.classList.remove("next");
        if (milestone.day >= day && (!best || milestone.day < best.milestone.day)) best = { bar, milestone };
      }
    }
    if (best) {
      best.milestone.el.classList.add("next");
      showNext(best.bar, best.milestone);
    }
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);
}
