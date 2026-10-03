import { memo } from "react";
import type { Column, ScaleMode } from "./timeline";

interface Props {
  columns: Column[];
  mode: ScaleMode;
  width: number;
  /** x of the current moment, drawn as a thin line. */
  todayX: number;
}

/** Column stripes behind the projects plus the sticky date header. */
export const TimelineGrid = memo(function TimelineGrid({ columns, mode, width, todayX }: Props) {
  return (
    <>
      <div className="grid" style={{ width }} aria-hidden>
        {columns.map((column) => (
          <div
            key={column.key}
            className={`grid-column${column.current ? " current" : ""}${column.weekEnd ? " week-end" : ""}${column.dayOff ? " day-off" : ""}`}
            style={{ left: column.x, width: column.width }}
          />
        ))}
        <div className="today-line" style={{ left: todayX }} />
      </div>
      <div className={`timeline-header mode-${mode}`} style={{ width }}>
        {columns.map((column) => (
          <div
            key={column.key}
            className={`header-cell${column.current ? " current" : ""}${column.weekEnd ? " week-end" : ""}${column.dayOff ? " day-off" : ""}`}
            style={{ left: column.x, width: column.width }}
            data-date={column.key}
          >
            <div className="header-title">{column.title}</div>
            <div className="header-subtitle">{column.subtitle}</div>
            {column.marker && <div className="header-marker">{column.marker}</div>}
          </div>
        ))}
      </div>
    </>
  );
});
