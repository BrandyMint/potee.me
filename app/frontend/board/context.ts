import { createContext, useContext } from "react";
import { useStore } from "zustand";
import type { BoardState, BoardStore } from "./store";
import type { Timeline } from "./timeline";

export const StoreContext = createContext<BoardStore | null>(null);

export function useBoardStore(): BoardStore {
  const store = useContext(StoreContext);
  if (!store) throw new Error("Board store is not provided");
  return store;
}

export function useBoard<T>(selector: (state: BoardState) => T): T {
  return useStore(useBoardStore(), selector);
}

/** Geometry and navigation shared by the board's components. */
export interface BoardView {
  timeline: Timeline;
  today: Date;
  viewportWidth: number;
  scrollLeft: number;
  /** Converts a pointer's clientX into the timeline x coordinate. */
  timelineX: (clientX: number) => number;
  goToDate: (date: Date) => void;
  /** Scrolls to today, dropping empty past on its left (see viewCenter). */
  goToToday: () => void;
  showProject: (id: number) => void;
  /** Row index a pointer at clientY points to (rows may differ in height). */
  rowIndexAt: (clientY: number, excludeId?: number) => number;
  /** Zooms and scrolls so these date ranges fit the screen. */
  fitRanges: (ranges: { started_on: string; finished_on: string }[]) => void;
}

export const ViewContext = createContext<BoardView | null>(null);

export function useBoardView(): BoardView {
  const view = useContext(ViewContext);
  if (!view) throw new Error("Board view is not provided");
  return view;
}
