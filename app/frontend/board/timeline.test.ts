import { describe, expect, it } from "vitest";
import {
  buildTimeline,
  clampScale,
  dateAt,
  dayOffChecker,
  dayOffset,
  eventTime,
  fitAll,
  labelStyle,
  labelTiers,
  rowHeight,
  eventBounds,
  fitScale,
  nextColorIndex,
  projectDays,
  scaleMode,
  stepScale,
  timelineColumns,
  toggleScale,
  xOf,
  SCALE,
  type Timeline,
  viewCenter,
} from "./timeline";

const day = (y: number, m: number, d: number, h = 0, min = 0) => new Date(y, m - 1, d, h, min);
const today = day(2026, 10, 1);

describe("zoom", () => {
  it("switches header mode by pixels per day", () => {
    expect(scaleMode(150)).toBe("days");
    expect(scaleMode(31)).toBe("days");
    expect(scaleMode(30)).toBe("weeks");
    expect(scaleMode(16)).toBe("weeks");
    expect(scaleMode(15)).toBe("months");
    expect(scaleMode(4)).toBe("months");
  });

  it("clamps and steps the zoom", () => {
    expect(clampScale(1000)).toBe(SCALE.MAX);
    expect(clampScale(1)).toBe(SCALE.MIN);
    expect(stepScale(150, 1)).toBe(155);
    expect(stepScale(60, -1)).toBe(57);
    expect(stepScale(20, 1)).toBe(21);
    expect(stepScale(SCALE.MAX, 1)).toBe(SCALE.MAX);
  });

  it("toggles between days and months", () => {
    expect(toggleScale(SCALE.DAYS)).toBe(SCALE.MONTHS);
    expect(toggleScale(42)).toBe(SCALE.DAYS);
  });

  it("fits a project into the viewport", () => {
    expect(fitScale({ started_on: "2026-10-01", finished_on: "2026-10-10" }, 1100)).toBe(100);
    expect(fitScale({ started_on: "2026-01-01", finished_on: "2027-12-31" }, 1100)).toBe(SCALE.MIN);
  });
});

describe("coordinates", () => {
  const timeline: Timeline = { origin: day(2026, 9, 1), days: 60, pixelsPerDay: 100, mode: "days" };

  it("maps dates to pixels and back to the minute", () => {
    expect(xOf(timeline, day(2026, 9, 1))).toBe(0);
    expect(xOf(timeline, day(2026, 9, 3, 12))).toBe(250);
    expect(dateAt(timeline, 250)).toEqual(day(2026, 9, 3, 12));
    const moment = day(2026, 10, 14, 17, 43);
    expect(dateAt(timeline, xOf(timeline, moment))).toEqual(moment);
  });

  it("counts calendar days, not 24h periods, across DST changes", () => {
    const winter: Timeline = { origin: day(2026, 10, 20), days: 30, pixelsPerDay: 10, mode: "days" };
    expect(dayOffset(winter, day(2026, 11, 2))).toBe(13);
  });

  it("counts inclusive project days", () => {
    expect(projectDays({ started_on: "2026-10-01", finished_on: "2026-10-01" })).toBe(1);
    expect(projectDays({ started_on: "2026-10-01", finished_on: "2026-10-07" })).toBe(7);
  });
});

describe("buildTimeline", () => {
  const projects = [
    { started_on: "2026-09-20", finished_on: "2026-10-10" },
    { started_on: "2026-10-05", finished_on: "2026-12-01" },
  ];

  it("covers every project and today with a screen of padding on both sides", () => {
    const timeline = buildTimeline({ projects, today, pixelsPerDay: 100, viewportWidth: 1000 });
    expect(timeline.mode).toBe("days");
    expect(timeline.origin).toEqual(day(2026, 9, 5)); // 15 days of padding
    expect(xOf(timeline, day(2026, 12, 1))).toBeLessThan(xOf(timeline, day(2026, 12, 16)));
    expect(timeline.days).toBe(103);
  });

  it("aligns weeks to Mondays and months to the 1st", () => {
    const weeks = buildTimeline({ projects, today, pixelsPerDay: 20, viewportWidth: 1000 });
    expect(weeks.origin.getDay()).toBe(1);
    expect(weeks.days % 7).toBe(0);

    const months = buildTimeline({ projects, today, pixelsPerDay: 10, viewportWidth: 1000 });
    expect(months.origin.getDate()).toBe(1);
  });

  it("works for an empty board", () => {
    const timeline = buildTimeline({ projects: [], today, pixelsPerDay: 150, viewportWidth: 1500 });
    expect(xOf(timeline, today)).toBeGreaterThan(1500);
  });
});

describe("timelineColumns", () => {
  it("builds day columns with today marked", () => {
    const timeline: Timeline = { origin: day(2026, 9, 29), days: 5, pixelsPerDay: 100, mode: "days" };
    const columns = timelineColumns(timeline, today);
    expect(columns.map((column) => column.title)).toEqual(["29", "30", "1", "2", "3"]);
    expect(columns.find((column) => column.current)?.key).toBe("2026-10-01");
    expect(columns[2]?.marker).toBe("October");
    expect(columns[0]?.marker).toBe("September");
  });

  it("builds week columns", () => {
    const timeline: Timeline = { origin: day(2026, 9, 28), days: 14, pixelsPerDay: 20, mode: "weeks" };
    const columns = timelineColumns(timeline, today);
    expect(columns).toHaveLength(2);
    expect(columns[0]).toMatchObject({ title: "September – October", subtitle: "28 – 4", width: 140, current: true });
    expect(columns[1]).toMatchObject({ title: "October", x: 140, current: false });
  });

  it("names months and weekdays in the board language", async () => {
    const { ru } = await import("date-fns/locale");
    const timeline: Timeline = { origin: day(2026, 9, 30), days: 2, pixelsPerDay: 100, mode: "days" };
    const columns = timelineColumns(timeline, today, ru);
    expect(columns.map((column) => [column.subtitle, column.marker])).toEqual([
      ["ср", "Сентябрь"],
      ["чт", "Октябрь"],
    ]);
  });

  it("builds month columns as wide as their days", () => {
    const timeline: Timeline = { origin: day(2026, 9, 1), days: 61, pixelsPerDay: 10, mode: "months" };
    const columns = timelineColumns(timeline, today);
    expect(columns.map((column) => [column.title, column.width, column.current])).toEqual([
      ["September", 300, false],
      ["October", 310, true],
    ]);
  });
});

describe("helpers", () => {
  it("picks the first free colour", () => {
    expect(nextColorIndex([])).toBe(0);
    expect(nextColorIndex([{ color_index: 0 }, { color_index: 2 }])).toBe(1);
  });

  it("finds the days of the first and last events", () => {
    const bounds = eventBounds({
      events: [
        { id: 1, title: "a", at: day(2026, 10, 5, 15).toISOString(), timed: true },
        { id: 2, title: "b", at: day(2026, 10, 2, 9).toISOString(), timed: false },
      ],
    });
    expect(bounds).toEqual({ first: day(2026, 10, 2), last: day(2026, 10, 5) });
  });
});

describe("fitAll", () => {
  const projects = [
    { started_on: "2026-10-01", finished_on: "2026-10-10" },
    { started_on: "2026-10-05", finished_on: "2026-10-20" },
  ];

  it("picks the largest zoom that fits the whole range and centres it", () => {
    const fit = fitAll({ projects, viewportWidth: 1100, rowsHeight: 600 })!;
    expect(fit.pixelsPerDay).toBe(50); // 20 days into 1000 px
    expect(fit.middle).toEqual(day(2026, 10, 11));
    expect(rowHeight(fit.pixelsPerDay)).toBe(64);
  });

  it("zooms out further when the rows do not fit the height", () => {
    const many = Array.from({ length: 10 }, () => projects[0]!);
    const fit = fitAll({ projects: many, viewportWidth: 2000, rowsHeight: 520 })!;
    expect(fit.pixelsPerDay).toBe(30); // weeks rows (50 px) fit 10 × 50 = 500
  });

  it("does nothing for an empty board", () => {
    expect(fitAll({ projects: [], viewportWidth: 1000, rowsHeight: 500 })).toBeNull();
  });
});

describe("labelTiers", () => {
  const width = ({ title }: { title: string }) => title.length * 10;

  it("keeps labels on one tier when they do not overlap", () => {
    const { tiers, count } = labelTiers(
      [
        { id: 1, x: 0, title: "aaaa" },
        { id: 2, x: 60, title: "bbbb" },
      ],
      width,
    );
    expect(count).toBe(1);
    expect([...tiers.values()]).toEqual([0, 0]);
  });

  it("lifts an overlapping label and reuses lower tiers when free again", () => {
    const { tiers, count } = labelTiers(
      [
        { id: 3, x: 300, title: "cc" },
        { id: 1, x: 0, title: "Some event" },
        { id: 2, x: 30, title: "Some event" },
      ],
      width,
    );
    expect(count).toBe(2);
    expect(tiers.get(1)).toBe(0);
    expect(tiers.get(2)).toBe(1);
    expect(tiers.get(3)).toBe(0);
  });
});

describe("label tiers limit", () => {
  const width = ({ title }: { title: string }) => title.length * 10;

  it("hides labels that need more tiers than allowed", () => {
    const events = [0, 5, 10].map((x, i) => ({ id: i + 1, x, title: "Some event" }));
    const { tiers, hidden, count } = labelTiers(events, width, 2);
    expect(count).toBe(2);
    expect([tiers.get(1), tiers.get(2)]).toEqual([0, 1]);
    expect([...hidden]).toEqual([3]);
  });

  it("uses smaller titles and fewer tiers when zoomed out", () => {
    expect(labelStyle(150)).toEqual({ fontSize: 16, tierHeight: 22, maxTiers: 3, timeSize: 12, timeHeight: 14 });
    expect(labelStyle(50)).toEqual({ fontSize: 13, tierHeight: 18, maxTiers: 2, timeSize: 11, timeHeight: 12 });
    expect(labelStyle(10)).toEqual({ fontSize: 13, tierHeight: 18, maxTiers: 2, timeSize: 11, timeHeight: 12 });
  });
});

describe("eventTime", () => {
  const event = { at: day(2026, 10, 14, 19, 0), timed: true };

  it("shows the start time of timed events in the days zoom only", () => {
    expect(eventTime(event, 150)).toBe("19:00");
    expect(eventTime(event, 40)).toBe("19:00");
    expect(eventTime(event, 20)).toBeNull();
    expect(eventTime({ ...event, timed: false }, 150)).toBeNull();
  });
});

describe("days off", () => {
  // Russia, May 2026: 1st (Fri) and 11th (Mon) are holidays; a made-up working Saturday on the 16th.
  const isDayOff = dayOffChecker({ weekend: [0, 6], holidays: ["2026-05-01", "2026-05-11"], workdays: ["2026-05-16"] });

  it("combines weekends, holidays and working weekend days", () => {
    expect(isDayOff(day(2026, 5, 1))).toBe(true);
    expect(isDayOff(day(2026, 5, 4))).toBe(false);
    expect(isDayOff(day(2026, 5, 9))).toBe(true);
    expect(isDayOff(day(2026, 5, 16))).toBe(false);
    expect(isDayOff(day(2026, 5, 17))).toBe(true);
  });

  it("marks day off columns in the days zoom", () => {
    const timeline = buildTimeline({ projects: [], today: day(2026, 5, 6), pixelsPerDay: 100, viewportWidth: 700 });
    const columns = timelineColumns(timeline, day(2026, 5, 6), undefined, isDayOff);
    expect(columns.find((column) => column.key === "2026-05-11")?.dayOff).toBe(true);
    expect(columns.find((column) => column.key === "2026-05-12")?.dayOff).toBe(false);
  });
});

describe("viewCenter", () => {
  // 1000 px at 10 px/day: the screen is 100 days, today (noon) in the middle.
  const options = { today: day(2026, 10, 2), pixelsPerDay: 10, viewportWidth: 1000 };
  const now = day(2026, 10, 2, 12);
  const shareOfToday = (center: Date) => 0.5 - (center.getTime() - now.getTime()) / 86_400_000 / 100;

  it("puts today at 30% when nothing is planned before it", () => {
    const center = viewCenter(now, { ...options, projects: [{ started_on: "2026-10-10", finished_on: "2026-11-30" }] });
    expect(shareOfToday(center)).toBeCloseTo(0.3);
  });

  it("keeps a project that started just before today on screen", () => {
    const center = viewCenter(now, { ...options, projects: [{ started_on: "2026-10-01", finished_on: "2026-10-28" }] });
    expect(shareOfToday(center)).toBeCloseTo(0.3);
  });

  it("drops only the empty part of the past", () => {
    // The project starts 30 days before today: 20 empty days are left of it, 5 stay as a margin.
    const center = viewCenter(now, { ...options, projects: [{ started_on: "2026-09-02", finished_on: "2026-10-20" }] });
    expect(shareOfToday(center)).toBeCloseTo(0.35, 1);
  });

  it("keeps the view when the past on screen is planned or today is off screen", () => {
    const busy = [{ started_on: "2026-08-01", finished_on: "2026-10-20" }];
    expect(viewCenter(now, { ...options, projects: busy })).toBe(now);
    const later = day(2027, 3, 1);
    expect(viewCenter(later, { ...options, projects: [] })).toBe(later);
  });
});
