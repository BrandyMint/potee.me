import { afterEach, describe, expect, it } from "vitest";
import { formatTime, parseTime, setTimeFormat } from "./i18n";

describe("time format", () => {
  afterEach(() => setTimeFormat("24h"));

  it("reads the usual ways to type a time", () => {
    expect(parseTime("19:00")).toEqual({ hours: 19, minutes: 0 });
    expect(parseTime("1930")).toEqual({ hours: 19, minutes: 30 });
    expect(parseTime("9.05")).toEqual({ hours: 9, minutes: 5 });
    expect(parseTime("7")).toEqual({ hours: 7, minutes: 0 });
    expect(parseTime("7:30 PM")).toEqual({ hours: 19, minutes: 30 });
    expect(parseTime("12am")).toEqual({ hours: 0, minutes: 0 });
    expect(parseTime("12 pm")).toEqual({ hours: 12, minutes: 0 });
  });

  it("rejects what is not a time", () => {
    for (const text of ["25:00", "19:60", "13pm", "noon", ""]) expect(parseTime(text)).toBeNull();
  });

  it("shows 24 or 12 hours by the account setting", () => {
    const at = new Date(2026, 9, 14, 19, 5);
    setTimeFormat("24h");
    expect(formatTime(at)).toBe("19:05");
    setTimeFormat("12h");
    expect(formatTime(at)).toBe("7:05 PM");
  });
});
