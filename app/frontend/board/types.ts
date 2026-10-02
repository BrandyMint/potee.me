// Shapes of the JSON the Rails API returns (see ProjectConnection#as_card_json).

export interface BoardEvent {
  id: number;
  title: string;
  /** ISO 8601 timestamp */
  at: string;
  /** Happens at a specific time (a call at 19:00), not just on a day. */
  timed: boolean;
}

/** One row of the board: the current user's connection to a project. */
export interface Card {
  /** Connection id; the API addresses board rows by it. */
  id: number;
  project_id: number;
  title: string;
  /** YYYY-MM-DD, inclusive */
  started_on: string;
  /** YYYY-MM-DD, inclusive */
  finished_on: string;
  color_index: number;
  position: number;
  owner: boolean;
  share_url: string;
  events: BoardEvent[];
}

export interface DashboardState {
  pixels_per_day: number;
  /** ISO 8601 timestamp of the moment in the middle of the screen; null = today */
  current_date: string | null;
  scroll_top: number;
}

export interface BoardData {
  projects: Card[];
  dashboard: DashboardState;
  user: { email: string | null; anonymous: boolean };
  locale: "ru" | "en";
  features: { plan_from_text: boolean };
}

/** A project proposed by "plan from text" (FT-001), not yet on the board. */
export interface PlanProject {
  key: string;
  title: string;
  start_date: string;
  end_date: string;
  /** Dates were stretched to cover the milestones. */
  adjusted: boolean;
  /** time is HH:MM, or null when the milestone is just a day. */
  events: { title: string; date: string; time: string | null }[];
}

export type PlanStatus = "pending" | "ready" | "failed" | "applied" | "discarded";

export interface PlanRequestState {
  id: number;
  status: PlanStatus;
  draft?: { projects: PlanProject[] };
  error?: string;
}
