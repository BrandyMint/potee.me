// Board UI strings. The language comes from the server (Accept-Language,
// Russian by default) via the initial board payload.
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
  newProject: "New project",
  newProjectHint: "New project (Enter)",
  signUp: "Sign up to save your projects",
  signUpShort: "Sign up",
  logIn: "Log in",
  logOut: "Log out",
  changeColour: "Change colour",
  selectedTitle: "Selected project title",
  entire: "Entire",
  entireHint: "Fit the whole project on screen",
  share: "Share",
  shareHint: "Copy the share link",
  linkCopied: "Link copied",
  copyLink: "Copy this link",
  delete: "Delete",
  close: "Close",
  undo: "Undo",
  projectDeleted: (title: string) => `“${title}” deleted`,
  eventDeleted: (title: string) => `“${title}” deleted`,
  projectTitle: "Project title",
  projectPlaceholder: "Your project name",
  defaultProjectTitle: "Your project name",
  defaultEventTitle: "Some event",
  eventTitle: "Event title",
  save: "Save",
  reorderHint: "Drag up or down to reorder",
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
    ["Drag an event", "move it in time; click its title to rename"],
    ["Drag empty space", "scroll the board"],
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
  newProject: "Новый проект",
  newProjectHint: "Новый проект (Enter)",
  signUp: "Зарегистрируйтесь, чтобы сохранить доску",
  signUpShort: "Регистрация",
  logIn: "Войти",
  logOut: "Выйти",
  changeColour: "Сменить цвет",
  selectedTitle: "Название выбранного проекта",
  entire: "Целиком",
  entireHint: "Показать проект целиком",
  share: "Поделиться",
  shareHint: "Скопировать ссылку на проект",
  linkCopied: "Ссылка скопирована",
  copyLink: "Скопируйте ссылку",
  delete: "Удалить",
  close: "Закрыть",
  undo: "Отменить",
  projectDeleted: (title) => `«${title}» удалён`,
  eventDeleted: (title) => `«${title}» удалено`,
  projectTitle: "Название проекта",
  projectPlaceholder: "Название проекта",
  defaultProjectTitle: "Новый проект",
  defaultEventTitle: "Событие",
  eventTitle: "Название события",
  save: "Сохранить",
  reorderHint: "Перетащите вверх или вниз, чтобы изменить порядок",
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
    ["Тянуть событие", "перенести во времени; клик по названию — переименовать"],
    ["Тянуть пустое место", "прокрутить доску"],
    ["Пробел", "к сегодняшнему дню"],
    ["Enter", "новый проект"],
    ["+ / − / 0", "крупнее / мельче / дни ↔ месяцы"],
    ["Ctrl или ⌘ + колесо", "масштаб вокруг курсора"],
    ["Esc", "отменить / снять выделение"],
  ],
};

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
