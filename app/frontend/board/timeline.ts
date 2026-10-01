// Pure timeline geometry: converting between dates and horizontal pixels,
// zoom levels and the header columns for each zoom level. No DOM access here.
import {
  addDays,
  addMinutes,
  addMonths,
  addWeeks,
  differenceInCalendarDays,
  format,
  getDaysInMonth,
  isSameDay,
  parseISO,
  startOfDay,
  startOfMonth,
  startOfWeek,
} from "date-fns";
import { enUS } from "date-fns/locale";
import type { Locale as DateLocale } from "date-fns";
import type { BoardEvent, Card } from "./types";

export const SCALE = {
  MIN: 4,
  MAX: 200,
  /** Default zoom of each mode, used by the days/weeks/months buttons. */
  DAYS: 150,
  WEEKS: 20,
  MONTHS: 10,
  /** Below or at this many pixels per day the header switches to weeks / months. */
  WEEKS_AT: 30,
  MONTHS_AT: 15,
  /** Day columns this narrow hide event titles until hovered. */
  COMPACT_DAYS_AT: 65,
} as const;

export const COLORS_COUNT = 10;
const WEEK_OPTIONS = { weekStartsOn: 1 } as const;
const MINUTES_PER_DAY = 24 * 60;

export type ScaleMode = "days" | "weeks" | "months";

export function scaleMode(pixelsPerDay: number): ScaleMode {
  if (pixelsPerDay <= SCALE.MONTHS_AT) return "months";
  if (pixelsPerDay <= SCALE.WEEKS_AT) return "weeks";
  return "days";
}

export function clampScale(pixelsPerDay: number): number {
  return Math.round(Math.min(SCALE.MAX, Math.max(SCALE.MIN, pixelsPerDay)));
}

/** One +/- keyboard step: finer steps when zoomed out. */
export function stepScale(pixelsPerDay: number, direction: 1 | -1): number {
  const step = pixelsPerDay < 50 ? 1 : pixelsPerDay < 100 ? 3 : 5;
  return clampScale(pixelsPerDay + direction * step);
}

/** The "0" key switches between the default days and months zoom. */
export function toggleScale(pixelsPerDay: number): number {
  return pixelsPerDay === SCALE.DAYS ? SCALE.MONTHS : SCALE.DAYS;
}

/** Calendar date (YYYY-MM-DD) as local midnight. */
export function parseDay(day: string): Date {
  return parseISO(day);
}

export function formatDay(date: Date): string {
  return format(date, "yyyy-MM-dd");
}

/** Inclusive number of days a project spans. */
export function projectDays(card: Pick<Card, "started_on" | "finished_on">): number {
  return differenceInCalendarDays(parseDay(card.finished_on), parseDay(card.started_on)) + 1;
}

export function projectMiddle(card: Pick<Card, "started_on" | "finished_on">): Date {
  return addMinutes(parseDay(card.started_on), (projectDays(card) * MINUTES_PER_DAY) / 2);
}

/** Zoom that fits the whole project into the viewport with margins. */
export function fitScale(card: Pick<Card, "started_on" | "finished_on">, viewportWidth: number, margin = 50): number {
  return clampScale((viewportWidth - margin * 2) / projectDays(card));
}

export interface Timeline {
  /** Local midnight at x = 0. */
  origin: Date;
  /** Total length in days. */
  days: number;
  pixelsPerDay: number;
  mode: ScaleMode;
}

/** Position of a moment in days from the timeline origin (fractional). */
export function dayOffset(timeline: Timeline, date: Date): number {
  const minutes = date.getHours() * 60 + date.getMinutes();
  return differenceInCalendarDays(date, timeline.origin) + minutes / MINUTES_PER_DAY;
}

export function xOf(timeline: Timeline, date: Date): number {
  return dayOffset(timeline, date) * timeline.pixelsPerDay;
}

/** The moment at a horizontal pixel, to the minute. */
export function dateAt(timeline: Timeline, x: number): Date {
  const days = x / timeline.pixelsPerDay;
  const whole = Math.floor(days);
  return addMinutes(addDays(timeline.origin, whole), Math.round((days - whole) * MINUTES_PER_DAY));
}

export function timelineWidth(timeline: Timeline): number {
  return timeline.days * timeline.pixelsPerDay;
}

/**
 * The visible range covers every project and today, plus a screen's worth of
 * empty days on each side, aligned to whole columns of the current mode.
 */
export function buildTimeline(options: {
  projects: Pick<Card, "started_on" | "finished_on">[];
  today: Date;
  pixelsPerDay: number;
  viewportWidth: number;
}): Timeline {
  const { projects, today, pixelsPerDay, viewportWidth } = options;
  const mode = scaleMode(pixelsPerDay);
  let first = startOfDay(today);
  let last = startOfDay(today);
  for (const project of projects) {
    const start = parseDay(project.started_on);
    const finish = parseDay(project.finished_on);
    if (start < first) first = start;
    if (finish > last) last = finish;
  }
  const padding = Math.ceil(viewportWidth / pixelsPerDay) + 5;
  const rawStart = addDays(first, -padding);
  const rawEnd = addDays(last, padding);

  let origin: Date;
  let end: Date;
  if (mode === "months") {
    origin = startOfMonth(rawStart);
    end = startOfMonth(addMonths(rawEnd, 1));
  } else if (mode === "weeks") {
    origin = startOfWeek(rawStart, WEEK_OPTIONS);
    end = addWeeks(startOfWeek(rawEnd, WEEK_OPTIONS), 1);
  } else {
    origin = startOfDay(rawStart);
    end = addDays(startOfDay(rawEnd), 1);
  }
  return { origin, days: differenceInCalendarDays(end, origin), pixelsPerDay, mode };
}

export interface Column {
  key: string;
  x: number;
  width: number;
  /** Big label: day number, week months or month name. */
  title: string;
  /** Small label: weekday, week days range or year. */
  subtitle: string;
  /** Month name shown along the first day of a month (days mode only). */
  marker?: string;
  current: boolean;
  /** Last day of the week gets a stronger border (days mode). */
  weekEnd?: boolean;
}

/** Standalone month name, capitalised ("October", "Октябрь"). */
function monthName(date: Date, locale: DateLocale): string {
  const name = format(date, "LLLL", { locale });
  return name.charAt(0).toUpperCase() + name.slice(1);
}

export function timelineColumns(timeline: Timeline, today: Date, locale: DateLocale = enUS): Column[] {
  const { origin, days, pixelsPerDay, mode } = timeline;
  const columns: Column[] = [];

  if (mode === "days") {
    for (let i = 0; i < days; i++) {
      const date = addDays(origin, i);
      columns.push({
        key: formatDay(date),
        x: i * pixelsPerDay,
        width: pixelsPerDay,
        title: format(date, "d"),
        subtitle: format(date, locale.code?.startsWith("ru") ? "EEEEEE" : "EEE", { locale }),
        marker: date.getDate() === 1 || i === 0 ? monthName(date, locale) : undefined,
        current: isSameDay(date, today),
        weekEnd: date.getDay() === 0,
      });
    }
    return columns;
  }

  if (mode === "weeks") {
    for (let i = 0; i * 7 < days; i++) {
      const start = addDays(origin, i * 7);
      const finish = addDays(start, 6);
      const startMonth = monthName(start, locale);
      const finishMonth = monthName(finish, locale);
      columns.push({
        key: formatDay(start),
        x: i * 7 * pixelsPerDay,
        width: 7 * pixelsPerDay,
        title: startMonth === finishMonth ? startMonth : `${startMonth} – ${finishMonth}`,
        subtitle: `${format(start, "d")} – ${format(finish, "d")}`,
        current: today >= start && today < addDays(start, 7),
      });
    }
    return columns;
  }

  let offset = 0;
  let month = origin;
  while (offset < days) {
    const length = getDaysInMonth(month);
    columns.push({
      key: formatDay(month),
      x: offset * pixelsPerDay,
      width: length * pixelsPerDay,
      title: monthName(month, locale),
      subtitle: format(month, "yyyy"),
      current: month.getFullYear() === today.getFullYear() && month.getMonth() === today.getMonth(),
    });
    offset += length;
    month = addMonths(month, 1);
  }
  return columns;
}

/** The event nearest to now; in the weeks zoom only its title stays visible. */
export function closestEventId(events: BoardEvent[], now: Date): number | undefined {
  let best: BoardEvent | undefined;
  let bestDistance = Infinity;
  for (const event of events) {
    const distance = Math.abs(parseISO(event.at).getTime() - now.getTime());
    if (distance < bestDistance) {
      best = event;
      bestDistance = distance;
    }
  }
  return best?.id;
}

/** First colour not used on the board yet, otherwise cycle. */
export function nextColorIndex(cards: Pick<Card, "color_index">[]): number {
  const used = new Set(cards.map((card) => card.color_index));
  for (let i = 0; i < COLORS_COUNT; i++) if (!used.has(i)) return i;
  return cards.length % COLORS_COUNT;
}

/** Events must stay inside the project: its days can't shrink past them. */
export function eventBounds(card: Pick<Card, "events">): { first?: Date; last?: Date } {
  let first: Date | undefined;
  let last: Date | undefined;
  for (const event of card.events) {
    const at = startOfDay(parseISO(event.at));
    if (!first || at < first) first = at;
    if (!last || at > last) last = at;
  }
  return { first, last };
}
