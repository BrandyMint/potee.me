// Board state. Changes are applied locally first and then sent to the API; if
// a request fails the board is reloaded from the server to get back in sync.
// Deletions wait UNDO_DELAY before reaching the server so they can be undone.
import { addDays, parseISO } from "date-fns";
import { create } from "zustand";
import { api, type EventAttributes, type ProjectAttributes } from "./api";
import { t } from "./i18n";
import { clampScale, formatDay, nextColorIndex } from "./timeline";
import type { BoardData, BoardEvent, Card, PlanProject } from "./types";

const DASHBOARD_SAVE_DELAY = 1000;
const UNDO_DELAY = 5000;
const ERROR_TOAST_DELAY = 6000;
let temporaryId = 0;
/** Ids of rows and events not saved yet are negative. */
const nextTemporaryId = () => --temporaryId;
export const isSaved = (id: number) => id > 0;

export interface Toast {
  id: number;
  kind: "error" | "info";
  message: string;
  undo?: () => void;
}

export interface BoardState {
  projects: Card[];
  pixelsPerDay: number;
  /** Moment in the middle of the screen. */
  currentDate: Date;
  /** The view was never saved (a new visitor): the board opens with the whole plan. */
  freshView: boolean;
  scrollTop: number;
  selectedId: number | null;
  /** A new project row waiting for its title. */
  draftId: number | null;
  editingEventId: number | null;
  /** Project whose title is being edited right in its bar. */
  renamingId: number | null;
  /** The selected project's panel is open (a second click on the project). */
  panelOpen: boolean;
  toast: Toast | null;
  user: BoardData["user"];
  features: BoardData["features"];
  calendar: BoardData["calendar"];
  /** "Plan from text" panel and its preview shown on the board (FT-001). */
  planOpen: boolean;
  planPreview: { projects: PlanProject[]; selected: string[] } | null;

  setScale: (pixelsPerDay: number, currentDate?: Date) => void;
  setView: (view: { currentDate?: Date; scrollTop?: number }) => void;
  select: (id: number | null) => void;
  startDraft: (start: Date, index: number) => void;
  commitDraft: (title: string) => Promise<void>;
  cancelDraft: () => void;
  updateProject: (id: number, attributes: ProjectAttributes) => Promise<void>;
  deleteProject: (id: number) => void;
  moveProject: (id: number, toIndex: number) => Promise<void>;
  addEvent: (projectId: number, at: Date) => Promise<void>;
  updateEvent: (projectId: number, eventId: number, attributes: EventAttributes) => Promise<void>;
  deleteEvent: (projectId: number, eventId: number) => void;
  editEvent: (eventId: number | null) => void;
  renameProject: (id: number | null) => void;
  openPanel: (open: boolean) => void;
  dismissToast: () => void;
  setPlanOpen: (open: boolean) => void;
  setPlanPreview: (preview: BoardState["planPreview"]) => void;
  /** Appends projects created on the server (plan applied). */
  appendProjects: (cards: Card[]) => void;
  /** Sends everything still waiting (view state, pending deletions) right away. */
  flush: () => void;
}

export function createBoardStore(initial: BoardData) {
  let dashboardTimer: ReturnType<typeof setTimeout> | undefined;
  let toastTimer: ReturnType<typeof setTimeout> | undefined;
  let toastId = 0;
  /** Deletions waiting for their undo window to pass. */
  const pendingDeletions = new Map<string, { timer: ReturnType<typeof setTimeout>; send: (keepalive: boolean) => void }>();

  return create<BoardState>()((set, get) => {
    const replaceProject = (id: number, update: (card: Card) => Card) =>
      set((state) => ({ projects: state.projects.map((card) => (card.id === id ? update(card) : card)) }));

    const showToast = (toast: Omit<Toast, "id">, delay: number) => {
      clearTimeout(toastTimer);
      const id = ++toastId;
      set({ toast: { ...toast, id } });
      toastTimer = setTimeout(() => {
        if (get().toast?.id === id) set({ toast: null });
      }, delay);
    };

    const fail = async (error: unknown) => {
      console.error(error);
      showToast({ kind: "error", message: t().saveFailed }, ERROR_TOAST_DELAY);
      try {
        const board = await api.board();
        set({ projects: board.projects, draftId: null, editingEventId: null });
      } catch (reloadError) {
        console.error(reloadError);
      }
    };

    /** Removes something locally now and on the server after the undo window. */
    const deleteWithUndo = (key: string, message: string, request: ((keepalive: boolean) => Promise<void>) | null, restore: () => void) => {
      const send = (keepalive: boolean) => {
        pendingDeletions.delete(key);
        request?.(keepalive).catch((error: unknown) => void fail(error));
      };
      pendingDeletions.set(key, { timer: setTimeout(() => send(false), UNDO_DELAY), send });
      showToast(
        {
          kind: "info",
          message,
          undo: () => {
            const pending = pendingDeletions.get(key);
            if (pending) clearTimeout(pending.timer);
            pendingDeletions.delete(key);
            restore();
            set({ toast: null });
          },
        },
        UNDO_DELAY,
      );
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
      freshView: !initial.dashboard.current_date,
      scrollTop: initial.dashboard.scroll_top,
      selectedId: null,
      draftId: null,
      editingEventId: null,
      renamingId: null,
      panelOpen: false,
      toast: null,
      user: initial.user,
      features: initial.features,
      calendar: initial.calendar,
      planOpen: false,
      planPreview: null,

      setPlanOpen: (open) => set(open ? { planOpen: true, selectedId: null } : { planOpen: false, planPreview: null }),
      setPlanPreview: (planPreview) => set({ planPreview }),
      appendProjects: (cards) => set((state) => ({ projects: [...state.projects, ...cards] })),

      setScale: (pixelsPerDay, currentDate) => {
        set({ pixelsPerDay: clampScale(pixelsPerDay), ...(currentDate ? { currentDate } : {}) });
        scheduleDashboardSave();
      },

      setView: (view) => {
        set(view);
        scheduleDashboardSave();
      },

      flush: () => {
        if (dashboardTimer !== undefined) {
          clearTimeout(dashboardTimer);
          dashboardTimer = undefined;
          api.updateDashboard(dashboardPayload(), { keepalive: true }).catch(() => undefined);
        }
        for (const pending of [...pendingDeletions.values()]) {
          clearTimeout(pending.timer);
          pending.send(true);
        }
      },

      select: (id) => set((state) => (state.selectedId === id ? {} : { selectedId: id, renamingId: null, panelOpen: false })),
      renameProject: (id) => set({ renamingId: id }),
      openPanel: (open) => set({ panelOpen: open }),

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
          return { projects, draftId: draft.id, selectedId: null, editingEventId: null };
        });
      },

      commitDraft: async (title) => {
        const draft = get().projects.find((card) => card.id === get().draftId);
        if (!draft) return;
        const finalTitle = title.trim() || t().defaultProjectTitle;
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
          await persistOrder();
        } catch (error) {
          await fail(error);
        }
      },

      cancelDraft: () => {
        const { draftId } = get();
        if (draftId === null) return;
        set((state) => ({ projects: state.projects.filter((card) => card.id !== draftId), draftId: null }));
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

      deleteProject: (id) => {
        const index = get().projects.findIndex((card) => card.id === id);
        const card = get().projects[index];
        if (!card) return;
        set((state) => ({
          projects: state.projects.filter((project) => project.id !== id),
          selectedId: state.selectedId === id ? null : state.selectedId,
          draftId: state.draftId === id ? null : state.draftId,
        }));
        if (!isSaved(id)) return;
        deleteWithUndo(
          `project-${id}`,
          t().projectDeleted(card.title),
          (keepalive) => api.deleteProject(id, { keepalive }),
          () =>
            set((state) => {
              const projects = [...state.projects];
              projects.splice(Math.min(index, projects.length), 0, card);
              return { projects };
            }),
        );
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
        const temporary: BoardEvent = { id: nextTemporaryId(), title: t().defaultEventTitle, at: at.toISOString(), timed: false };
        replaceProject(projectId, (card) => ({ ...card, events: [...card.events, temporary] }));
        try {
          const saved = await api.createEvent(projectId, { title: temporary.title, at: temporary.at });
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

      deleteEvent: (projectId, eventId) => {
        const event = get().projects.find((card) => card.id === projectId)?.events.find((item) => item.id === eventId);
        if (!event) return;
        replaceProject(projectId, (card) => ({ ...card, events: card.events.filter((item) => item.id !== eventId) }));
        set((state) => ({ editingEventId: state.editingEventId === eventId ? null : state.editingEventId }));
        if (!isSaved(eventId)) return;
        deleteWithUndo(
          `event-${eventId}`,
          t().eventDeleted(event.title),
          (keepalive) => api.deleteEvent(eventId, { keepalive }),
          () => replaceProject(projectId, (card) => ({ ...card, events: [...card.events, event] })),
        );
      },

      editEvent: (eventId) => set({ editingEventId: eventId }),

      dismissToast: () => {
        clearTimeout(toastTimer);
        set({ toast: null });
      },
    };
  });
}

export type BoardStore = ReturnType<typeof createBoardStore>;
