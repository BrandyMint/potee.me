// Shapes of the JSON the Rails API returns (see ProjectConnection#as_card_json).

export interface BoardEvent {
  id: number;
  title: string;
  /** ISO 8601 timestamp */
  at: string;
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
  user: { name: string; anonymous: boolean };
}
