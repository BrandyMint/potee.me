// Board UI strings. The language comes from the server (Accept-Language,
// Russian by default) via the initial board payload.
import { format } from "date-fns";
import { enUS, ru, type Locale as DateLocale } from "date-fns/locale";

export type Locale = "ru" | "en";

const en = {
  days: "Days",
  weeks: "Weeks",
  months: "Months",
  daysShort: "D",
  weeksShort: "W",
  monthsShort: "M",
  zoomHint: "Zoom: + / − keys, 0 toggles, Ctrl + wheel",
  moveToTodayLeft: "← move to today",
  moveToTodayRight: "move to today →",
  goToToday: "Go to today",
  showAll: "Show all projects",
  newProject: "New project",
  newProjectHint: "New project (Enter)",
  planFromText: "Plan from text",
  planPlaceholder: "Describe the plan in your own words, e.g.: Launching a course by December 1. Landing page by October 20, three webinars on Wednesdays in November at 7 pm, a newsletter a week before the start.",
  planProviderNote: "The text is processed by a third-party language model (via OpenRouter). Your board is not sent.",
  planGenerate: "Make a plan",
  planWorking: "Laying out the plan…",
  planReview: "Check the plan: it is shown on the board with a dashed outline. Untick what you don't need.",
  planAdjusted: "Dates stretched to cover the milestones",
  planBack: "Rewrite",
  planAdd: (count: number) => (count === 1 ? "Add 1 project" : `Add ${count} projects`),
  planRetry: "Try again",
  planSignUpOnly: "Plans from text are available after sign-up: your board will be saved too.",
  planErrors: {
    unparseable: "Could not lay out this plan. Try describing it with dates and steps.",
    llm_unavailable: "The model is unavailable right now. Try again in a minute.",
    llm_timeout: "The model took too long. Try again.",
    interrupted: "The request was interrupted. Try again.",
    daily_limit: "That's the daily limit of plans. Come back tomorrow.",
    in_progress: "A plan is already being prepared. Wait for it to finish.",
    apply_failed: "Could not add the plan to the board. Try again.",
    unknown: "Something went wrong. Try again.",
  },
  signUp: "Save your board",
  signUpShort: "Save",
  logIn: "Log in",
  logOut: "Log out",
  changeColour: "Colour",
  selectedTitle: "Selected project title",
  entire: "Entire",
  entireHint: "Fit the whole project on screen",
  share: "Share",
  shareHint: "Copy the share link",
  linkCopied: "Link copied",
  copyLink: "Copy this link",
  delete: "Delete",
  close: "Close",
  projectPanel: "Project panel",
  rename: "Rename",
  details: "Details",
  detailsHint: "Dates and milestones",
  collapse: "Collapse",
  colour: (index: number) => `Colour ${index}`,
  dates: "Dates",
  startDate: "Start date",
  finishDate: "Finish date",
  daysCount: (count: number) => (count === 1 ? "1 day" : `${count} days`),
  milestones: "Milestones",
  milestoneDate: "Milestone date",
  milestoneTime: "Milestone time",
  moveMilestone: "Move to another day",
  reorderMilestone: "Drag to change the order of steps; the dates stay in place",
  addTime: "time",
  deleteMilestone: (title: string) => `Delete “${title}”`,
  addMilestone: "add",
  noMilestones: "No milestones yet. Double-click the project bar or press “add”.",
  removeFromBoard: "Remove from board",
  undo: "Undo",
  projectDeleted: (title: string) => `“${title}” deleted`,
  eventDeleted: (title: string) => `“${title}” deleted`,
  projectTitle: "Project title",
  draftSave: "save",
  draftCancel: "cancel",
  projectPlaceholder: "Your project name",
  defaultProjectTitle: "Your project name",
  defaultEventTitle: "Some event",
  eventTitle: "Event title",
  eventTime: "Event time",
  removeTime: "Remove the time",
  save: "Save",
  invalidTime: (example: string) => `Not a time — for example, ${example}`,
  eventTimeHint: "Start time; leave empty if the event is just a day",
  reorderHint: "Drag up or down to reorder, double-click to rename",
  saveFailed: "Could not save the change. The board was reloaded from the server.",
  dismiss: "Dismiss",
  emptyTitle: "Your board is empty",
  emptyText: "Double-click anywhere on the timeline or press Enter to add a project.",
  help: "Help",
  helpTitle: "How to use Potee",
  helpItems: [
    ["Double-click the timeline", "new project on that day"],
    ["Double-click a project", "new event at that moment"],
    ["Drag a project edge", "change its start or finish"],
    ["Drag a project title", "reorder projects"],
    ["Double-click a project title", "rename it"],
    ["Drag an event", "move it in time; click its title to rename"],
    ["Drag empty space", "scroll the board"],
    ["Click the logo", "show all projects on one screen"],
    ["Space", "go to today"],
    ["Enter", "new project"],
    ["+ / − / 0", "zoom in / out / days ↔ months"],
    ["Ctrl or ⌘ + wheel", "zoom around the pointer"],
    ["Esc", "cancel / deselect"],
  ] as [string, string][],
};

type Dictionary = typeof en;

const ruDictionary: Dictionary = {
  days: "Дни",
  weeks: "Недели",
  months: "Месяцы",
  daysShort: "Д",
  weeksShort: "Н",
  monthsShort: "М",
  zoomHint: "Масштаб: клавиши + / −, 0 переключает, Ctrl + колесо",
  moveToTodayLeft: "← к сегодня",
  moveToTodayRight: "к сегодня →",
  goToToday: "К сегодняшнему дню",
  showAll: "Показать все проекты",
  newProject: "Новый проект",
  newProjectHint: "Новый проект (Enter)",
  planFromText: "План из текста",
  planPlaceholder: "Опишите план своими словами, например: Запускаю курс к 1 декабря. Лендинг до 20 октября, 3 вебинара по средам в ноябре в 19:00, рассылка за неделю до старта.",
  planProviderNote: "Текст обрабатывает языковая модель стороннего провайдера (через OpenRouter). Ваша доска не передаётся.",
  planGenerate: "Составить план",
  planWorking: "Раскладываю план…",
  planReview: "Проверьте план: он показан на доске пунктиром. Снимите галочки с лишнего.",
  planAdjusted: "Сроки расширены, чтобы вместить вехи",
  planBack: "Переписать",
  planAdd: (count: number) => `Добавить ${count} ${plural(count, "проект", "проекта", "проектов")}`,
  planRetry: "Попробовать снова",
  planSignUpOnly: "План из текста доступен после регистрации — заодно сохранится ваша доска.",
  planErrors: {
    unparseable: "Не получилось разложить план. Опишите его с датами и шагами.",
    llm_unavailable: "Модель сейчас недоступна. Попробуйте через минуту.",
    llm_timeout: "Модель отвечала слишком долго. Попробуйте ещё раз.",
    interrupted: "Запрос прервался. Попробуйте ещё раз.",
    daily_limit: "На сегодня лимит планов исчерпан. Возвращайтесь завтра.",
    in_progress: "План уже готовится. Дождитесь результата.",
    apply_failed: "Не получилось добавить план на доску. Попробуйте ещё раз.",
    unknown: "Что-то пошло не так. Попробуйте ещё раз.",
  },
  signUp: "Сохранить доску",
  signUpShort: "Сохранить",
  logIn: "Войти",
  logOut: "Выйти",
  changeColour: "Цвет",
  selectedTitle: "Название выбранного проекта",
  entire: "Целиком",
  entireHint: "Показать проект целиком",
  share: "Поделиться",
  shareHint: "Скопировать ссылку на проект",
  linkCopied: "Ссылка скопирована",
  copyLink: "Скопируйте ссылку",
  delete: "Удалить",
  close: "Закрыть",
  projectPanel: "Панель проекта",
  rename: "Переименовать",
  details: "Подробнее",
  detailsHint: "Сроки и вехи",
  collapse: "Свернуть",
  colour: (index: number) => `Цвет ${index}`,
  dates: "Сроки",
  startDate: "Дата начала",
  finishDate: "Дата окончания",
  daysCount: (count: number) => `${count} ${plural(count, "день", "дня", "дней")}`,
  milestones: "Вехи",
  milestoneDate: "Дата вехи",
  milestoneTime: "Время вехи",
  moveMilestone: "Перенести на другой день",
  reorderMilestone: "Перетащите, чтобы поменять порядок шагов; даты останутся на местах",
  addTime: "время",
  deleteMilestone: (title: string) => `Удалить «${title}»`,
  addMilestone: "добавить",
  noMilestones: "Пока нет вех. Дважды кликните по полоске проекта или нажмите «добавить».",
  removeFromBoard: "Убрать с доски",
  undo: "Отменить",
  projectDeleted: (title) => `«${title}» удалён`,
  eventDeleted: (title) => `«${title}» удалено`,
  projectTitle: "Название проекта",
  draftSave: "сохранить",
  draftCancel: "отмена",
  projectPlaceholder: "Название проекта",
  defaultProjectTitle: "Новый проект",
  defaultEventTitle: "Событие",
  eventTitle: "Название события",
  eventTime: "Время события",
  removeTime: "Убрать время",
  save: "Сохранить",
  invalidTime: (example: string) => `Это не время — например, ${example}`,
  eventTimeHint: "Время начала; оставьте пустым, если важен только день",
  reorderHint: "Перетащите вверх или вниз, чтобы изменить порядок; двойной клик — переименовать",
  saveFailed: "Не удалось сохранить изменение. Доска перезагружена с сервера.",
  dismiss: "Закрыть",
  emptyTitle: "Доска пуста",
  emptyText: "Дважды щёлкните по ленте или нажмите Enter, чтобы добавить проект.",
  help: "Подсказка",
  helpTitle: "Как пользоваться Potee",
  helpItems: [
    ["Двойной клик по ленте", "новый проект с этого дня"],
    ["Двойной клик по проекту", "событие в этот момент"],
    ["Тянуть край проекта", "изменить начало или конец"],
    ["Тянуть название проекта", "изменить порядок"],
    ["Двойной клик по названию", "переименовать проект"],
    ["Тянуть событие", "перенести во времени; клик по названию — переименовать"],
    ["Тянуть пустое место", "прокрутить доску"],
    ["Клик по логотипу", "все проекты на одном экране"],
    ["Пробел", "к сегодняшнему дню"],
    ["Enter", "новый проект"],
    ["+ / − / 0", "крупнее / мельче / дни ↔ месяцы"],
    ["Ctrl или ⌘ + колесо", "масштаб вокруг курсора"],
    ["Esc", "отменить / снять выделение"],
  ],
};

function plural(count: number, one: string, few: string, many: string): string {
  const mod10 = count % 10;
  const mod100 = count % 100;
  if (mod10 === 1 && mod100 !== 11) return one;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
  return many;
}

const dictionaries: Record<Locale, Dictionary> = { en, ru: ruDictionary };
const dateLocales: Record<Locale, DateLocale> = { en: enUS, ru };

let current: Locale = "en";

export function setLocale(locale: string | undefined): void {
  current = locale === "ru" ? "ru" : "en";
}

export function locale(): Locale {
  return current;
}

export function t(): Dictionary {
  return dictionaries[current];
}

export function dateLocale(): DateLocale {
  return dateLocales[current];
}

// Clock: 24 hours ("19:00") or 12 hours ("7:00 PM"), set from the account.
let hour12 = false;

export function setTimeFormat(timeFormat: string | undefined): void {
  hour12 = timeFormat === "12h";
}

export function formatTime(date: Date): string {
  return format(date, hour12 ? "h:mm a" : "HH:mm");
}

/** Reads "19:00", "1900", "19.00", "7", "7:30 pm", "7pm"; null when it is not a time. */
export function parseTime(input: string): { hours: number; minutes: number } | null {
  const match = input.trim().toLowerCase().replace(/\s+/g, "").match(/^(\d{1,2})(?:[:.]?(\d{2}))?(am|pm|a|p)?$/);
  if (!match) return null;
  let hours = Number(match[1]);
  const minutes = Number(match[2] ?? 0);
  const suffix = match[3];
  if (minutes > 59) return null;
  if (suffix) {
    if (hours < 1 || hours > 12) return null;
    hours = (hours % 12) + (suffix.startsWith("p") ? 12 : 0);
  } else if (hours > 23) return null;
  return { hours, minutes };
}

export function timePlaceholder(): string {
  return hour12 ? "h:mm PM" : current === "ru" ? "ЧЧ:ММ" : "HH:MM";
}

export function timeExample(): string {
  return hour12 ? "7:30 PM" : "19:30";
}
