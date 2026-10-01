import type { PointerEvent as ReactPointerEvent } from "react";

export interface DragHandlers {
  /** Called on every move once the pointer has travelled past the threshold. */
  onMove?: (dx: number, dy: number, event: PointerEvent) => void;
  /** `moved` is false for a plain click. */
  onEnd?: (dx: number, dy: number, moved: boolean, event: PointerEvent) => void;
}

/**
 * Tracks a pointer drag started by `start` until the button is released.
 * Movements shorter than `threshold` pixels count as a click.
 */
export function startDrag(start: ReactPointerEvent, handlers: DragHandlers, threshold = 3): void {
  if (start.button !== 0) return;
  const startX = start.clientX;
  const startY = start.clientY;
  let moved = false;

  const move = (event: PointerEvent) => {
    const dx = event.clientX - startX;
    const dy = event.clientY - startY;
    if (!moved && Math.hypot(dx, dy) < threshold) return;
    moved = true;
    handlers.onMove?.(dx, dy, event);
  };
  const end = (event: PointerEvent) => {
    window.removeEventListener("pointermove", move);
    window.removeEventListener("pointerup", end);
    window.removeEventListener("pointercancel", end);
    handlers.onEnd?.(event.clientX - startX, event.clientY - startY, moved, event);
    if (moved) suppressNextClick();
  };

  window.addEventListener("pointermove", move);
  window.addEventListener("pointerup", end);
  window.addEventListener("pointercancel", end);
}

/** A drag ends with a click on the element under the pointer; swallow it. */
function suppressNextClick(): void {
  const swallow = (event: MouseEvent) => {
    event.stopPropagation();
    event.preventDefault();
  };
  window.addEventListener("click", swallow, { capture: true, once: true });
  setTimeout(() => window.removeEventListener("click", swallow, { capture: true }), 0);
}

/** Pointer interactions should not start on form controls. */
export function isFormControl(target: EventTarget | null): boolean {
  return target instanceof HTMLElement && target.closest("input, textarea, button, select, a, [contenteditable]") !== null;
}
