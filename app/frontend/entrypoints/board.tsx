import { createRoot } from "react-dom/client";
import { App } from "../board/App";
import { readInitialBoard } from "../board/api";
import "../board/board.css";

const root = document.getElementById("board-root");
if (root) {
  createRoot(root).render(<App initial={readInitialBoard()} />);
}
