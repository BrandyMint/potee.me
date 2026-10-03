import { createRoot } from "react-dom/client";
import { App } from "../board/App";
import { readInitialBoard } from "../board/api";
import { setLocale, setTimeFormat } from "../board/i18n";
import "../board/board.css";

const root = document.getElementById("board-root");
if (root) {
  const initial = readInitialBoard();
  setLocale(initial.locale);
  setTimeFormat(initial.time_format);
  createRoot(root).render(<App initial={initial} />);
}
