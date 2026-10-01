import type { BoardData, BoardEvent, Card, DashboardState } from "./types";

export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly body: unknown,
  ) {
    super(`API request failed with status ${status}`);
  }
}

/** The board state Rails renders into the page (see boards/show.html.erb). */
export function readInitialBoard(): BoardData {
  const element = document.getElementById("board-data");
  if (!element?.textContent) throw new Error("Missing #board-data");
  return JSON.parse(element.textContent) as BoardData;
}

function csrfToken(): string {
  return document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')?.content ?? "";
}

async function request<T>(method: string, path: string, body?: unknown, options: { keepalive?: boolean } = {}): Promise<T> {
  const response = await fetch(path, {
    method,
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken(),
    },
    body: body === undefined ? undefined : JSON.stringify(body),
    credentials: "same-origin",
    keepalive: options.keepalive,
  });
  if (!response.ok) {
    const payload: unknown = await response.json().catch(() => null);
    throw new ApiError(response.status, payload);
  }
  if (response.status === 204) return undefined as T;
  return (await response.json()) as T;
}

export type ProjectAttributes = Partial<Pick<Card, "title" | "started_on" | "finished_on" | "color_index" | "position">>;
export type EventAttributes = Partial<Pick<BoardEvent, "title" | "at">>;

export const api = {
  board: () => request<BoardData>("GET", "/api/board"),
  updateDashboard: (dashboard: Partial<DashboardState>, options?: { keepalive?: boolean }) =>
    request<DashboardState>("PATCH", "/api/dashboard", { dashboard }, options),
  createProject: (project: ProjectAttributes) => request<Card>("POST", "/api/projects", { project }),
  updateProject: (id: number, project: ProjectAttributes) => request<Card>("PATCH", `/api/projects/${id}`, { project }),
  deleteProject: (id: number, options?: { keepalive?: boolean }) =>
    request<void>("DELETE", `/api/projects/${id}`, undefined, options),
  reorderProjects: (ids: number[]) => request<void>("PATCH", "/api/projects/reorder", { ids }),
  createEvent: (projectId: number, event: EventAttributes) =>
    request<BoardEvent>("POST", `/api/projects/${projectId}/events`, { event }),
  updateEvent: (id: number, event: EventAttributes) => request<BoardEvent>("PATCH", `/api/events/${id}`, { event }),
  deleteEvent: (id: number, options?: { keepalive?: boolean }) =>
    request<void>("DELETE", `/api/events/${id}`, undefined, options),
};
