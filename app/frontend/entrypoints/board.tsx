import { createRoot } from "react-dom/client";
import { App } from "../board/App";
import { readInitialBoard } from "../board/api";
import { setLocale } from "../board/i18n";
import "../board/board.css";

const root = document.getElementById("board-root");
if (root) {
  const initial = readInitialBoard();
  setLocale(initial.locale);
  createRoot(root).render(<App initial={initial} />);
}
