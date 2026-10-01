// Board state. Changes are applied locally first and then sent to the API; if
// a request fails the board is reloaded from the server to get back in sync.
import { addDays, parseISO } from "date-fns";
import { create } from "zustand";
import { api, type EventAttributes, type ProjectAttributes } from "./api";
import { clampScale, formatDay, nextColorIndex } from "./timeline";
import type { BoardData, BoardEvent, Card } from "./types";

const DASHBOARD_SAVE_DELAY = 1000;
let temporaryId = 0;
/** Ids of rows and events not saved yet are negative. */
const nextTemporaryId = () => --temporaryId;
export const isSaved = (id: number) => id > 0;

export interface BoardState {
  projects: Card[];
  pixelsPerDay: number;
  /** Moment in the middle of the screen. */
  currentDate: Date;
  scrollTop: number;
  selectedId: number | null;
  /** A new project row waiting for its title. */
  draftId: number | null;
  editingEventId: number | null;
  error: string | null;
  user: BoardData["user"];

  setScale: (pixelsPerDay: number, currentDate?: Date) => void;
  setView: (view: { currentDate?: Date; scrollTop?: number }) => void;
  select: (id: number | null) => void;
  startDraft: (start: Date, index: number) => void;
  commitDraft: (title: string) => Promise<void>;
  cancelDraft: () => void;
  updateProject: (id: number, attributes: ProjectAttributes) => Promise<void>;
  deleteProject: (id: number) => Promise<void>;
  moveProject: (id: number, toIndex: number) => Promise<void>;
  addEvent: (projectId: number, at: Date) => Promise<void>;
  updateEvent: (projectId: number, eventId: number, attributes: EventAttributes) => Promise<void>;
  deleteEvent: (projectId: number, eventId: number) => Promise<void>;
  editEvent: (eventId: number | null) => void;
  dismissError: () => void;
  saveDashboardNow: () => void;
}

export function createBoardStore(initial: BoardData) {
  let dashboardTimer: ReturnType<typeof setTimeout> | undefined;

  return create<BoardState>()((set, get) => {
    const replaceProject = (id: number, update: (card: Card) => Card) =>
      set((state) => ({ projects: state.projects.map((card) => (card.id === id ? update(card) : card)) }));

    const fail = async (error: unknown) => {
      console.error(error);
      set({ error: "Could not save the change. The board was reloaded from the server." });
      try {
        const board = await api.board();
        set({ projects: board.projects, draftId: null, editingEventId: null });
      } catch (reloadError) {
        console.error(reloadError);
      }
    };

    const dashboardPayload = () => {
      const { pixelsPerDay, currentDate, scrollTop } = get();
      return { pixels_per_day: pixelsPerDay, current_date: currentDate.toISOString(), scroll_top: Math.round(scrollTop) };
    };

    const scheduleDashboardSave = () => {
      clearTimeout(dashboardTimer);
      dashboardTimer = setTimeout(() => {
        dashboardTimer = undefined;
        api.updateDashboard(dashboardPayload()).catch((error: unknown) => console.error(error));
      }, DASHBOARD_SAVE_DELAY);
    };

    const persistOrder = () =>
      api.reorderProjects(get().projects.filter((card) => isSaved(card.id)).map((card) => card.id));

    return {
      projects: initial.projects,
      pixelsPerDay: clampScale(initial.dashboard.pixels_per_day),
      currentDate: initial.dashboard.current_date ? parseISO(initial.dashboard.current_date) : new Date(),
      scrollTop: initial.dashboard.scroll_top,
      selectedId: null,
      draftId: null,
      editingEventId: null,
      error: null,
      user: initial.user,

      setScale: (pixelsPerDay, currentDate) => {
        set({ pixelsPerDay: clampScale(pixelsPerDay), ...(currentDate ? { currentDate } : {}) });
        scheduleDashboardSave();
      },

      setView: (view) => {
        set(view);
        scheduleDashboardSave();
      },

      saveDashboardNow: () => {
        if (dashboardTimer === undefined) return;
        clearTimeout(dashboardTimer);
        dashboardTimer = undefined;
        api.updateDashboard(dashboardPayload(), { keepalive: true }).catch(() => undefined);
      },

      select: (id) => set({ selectedId: id }),

      startDraft: (start, index) => {
        if (get().draftId !== null) get().cancelDraft();
        const draft: Card = {
          id: nextTemporaryId(),
          project_id: 0,
          title: "",
          started_on: formatDay(start),
          finished_on: formatDay(addDays(start, 6)),
          color_index: nextColorIndex(get().projects),
          position: index,
          owner: true,
          share_url: "",
          events: [],
        };
        set((state) => {
          const projects = [...state.projects];
          projects.splice(Math.max(0, Math.min(index, projects.length)), 0, draft);
          return { projects, draftId: draft.id, selectedId: draft.id, editingEventId: null };
        });
      },

      commitDraft: async (title) => {
        const draft = get().projects.find((card) => card.id === get().draftId);
        if (!draft) return;
        const finalTitle = title.trim() || "Your project name";
        replaceProject(draft.id, (card) => ({ ...card, title: finalTitle }));
        set({ draftId: null });
        try {
          const saved = await api.createProject({
            title: finalTitle,
            started_on: draft.started_on,
            finished_on: draft.finished_on,
            color_index: draft.color_index,
            position: get().projects.findIndex((card) => card.id === draft.id),
          });
          replaceProject(draft.id, () => saved);
          if (get().selectedId === draft.id) set({ selectedId: saved.id });
          await persistOrder();
        } catch (error) {
          await fail(error);
        }
      },

      cancelDraft: () => {
        const { draftId } = get();
        if (draftId === null) return;
        set((state) => ({
          projects: state.projects.filter((card) => card.id !== draftId),
          draftId: null,
          selectedId: state.selectedId === draftId ? null : state.selectedId,
        }));
      },

      updateProject: async (id, attributes) => {
        replaceProject(id, (card) => ({ ...card, ...attributes }));
        if (!isSaved(id)) return;
        try {
          const saved = await api.updateProject(id, attributes);
          replaceProject(id, () => saved);
        } catch (error) {
          await fail(error);
        }
      },

      deleteProject: async (id) => {
        set((state) => ({
          projects: state.projects.filter((card) => card.id !== id),
          selectedId: state.selectedId === id ? null : state.selectedId,
          draftId: state.draftId === id ? null : state.draftId,
        }));
        if (!isSaved(id)) return;
        try {
          await api.deleteProject(id);
        } catch (error) {
          await fail(error);
        }
      },

      moveProject: async (id, toIndex) => {
        const projects = [...get().projects];
        const from = projects.findIndex((card) => card.id === id);
        if (from < 0 || from === toIndex) return;
        const [card] = projects.splice(from, 1);
        if (!card) return;
        projects.splice(Math.max(0, Math.min(toIndex, projects.length)), 0, card);
        set({ projects });
        try {
          await persistOrder();
        } catch (error) {
          await fail(error);
        }
      },

      addEvent: async (projectId, at) => {
        const temporary: BoardEvent = { id: nextTemporaryId(), title: "Some event", at: at.toISOString() };
        replaceProject(projectId, (card) => ({ ...card, events: [...card.events, temporary] }));
        try {
          const saved = await api.createEvent(projectId, { at: temporary.at });
          replaceProject(projectId, (card) => ({
            ...card,
            events: card.events.map((event) => (event.id === temporary.id ? saved : event)),
          }));
        } catch (error) {
          await fail(error);
        }
      },

      updateEvent: async (projectId, eventId, attributes) => {
        replaceProject(projectId, (card) => ({
          ...card,
          events: card.events.map((event) => (event.id === eventId ? { ...event, ...attributes } : event)),
        }));
        if (!isSaved(eventId)) return;
        try {
          await api.updateEvent(eventId, attributes);
        } catch (error) {
          await fail(error);
        }
      },

      deleteEvent: async (projectId, eventId) => {
        replaceProject(projectId, (card) => ({ ...card, events: card.events.filter((event) => event.id !== eventId) }));
        set((state) => ({ editingEventId: state.editingEventId === eventId ? null : state.editingEventId }));
        if (!isSaved(eventId)) return;
        try {
          await api.deleteEvent(eventId);
        } catch (error) {
          await fail(error);
        }
      },

      editEvent: (eventId) => set({ editingEventId: eventId }),

      dismissError: () => set({ error: null }),
    };
  });
}

export type BoardStore = ReturnType<typeof createBoardStore>;
