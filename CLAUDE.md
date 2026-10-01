# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Potee — visual project planner: projects are horizontal bars on a zoomable, scrollable timeline, with events (milestones) on them. Rails 8.1 / Ruby 3.4 backend serving a JSON API and one page that hosts a React 19 + TypeScript board built by Vite (`vite_rails`). PostgreSQL 17. This is a rewrite of the 2012 Rails 3.2 + Backbone app (still on the `develop` branch history); behaviour was ported from it, including the keyboard shortcuts in `Keystrokes.md`.

## Commands

Ports are allocated per checkout with `port-selector` (`db`, `web`, `vite`), so worktrees don't collide. `.envrc` exports them; without direnv prefix commands with `DB_PORT="$(port-selector --name db)"`.

```sh
bin/dev                                   # Postgres in Docker (compose), db:prepare, Vite dev server + Rails
bundle exec rspec                         # request/model specs (needs the db container)
bundle exec rspec spec/requests/api/projects_spec.rb:12
npm run typecheck                         # tsc (TypeScript 7)
npm test                                  # Vitest: app/frontend/**/*.test.ts (pure timeline math)
BASE_URL="http://127.0.0.1:$(port-selector --name web)" npm run e2e   # Playwright against a running bin/dev
bin/rubocop && bin/brakeman -q
```

E2E tests share the dev database; each test gets a fresh browser context, which is a new anonymous user, so they don't interfere. Date logic is local-time based: run Vitest also with a DST timezone (`TZ=Europe/Berlin npm test`) when touching `timeline.ts`.

## Architecture

### Backend

- **No sign-up required.** `CurrentUser` (controller concern) creates an anonymous `User` on the first visit to the board or the API, fills it with `DemoBoard` sample projects and keeps the id in the session. The landing page (`/`) does not create users.
- **Project vs. ProjectConnection** is the key concept. `Project` holds shared data (title, `started_on`/`finished_on`, owner, events). `ProjectConnection` is one user's row on their board: `position`, `color_index` (10 colours) and `share_key`. The API addresses board rows by **connection id**, not project id — `ProjectConnection#as_card_json` is the row shape the frontend receives.
- Sharing: `/share/:share_key` adds the project to the visitor's board (idempotent) and redirects to `/projects?focus=<connection id>`. Deleting the owner's row deletes the project; other users only lose their row.
- `Dashboard` stores per-user view state: `pixels_per_day` (zoom, 4–200), `current_date` (moment in the middle of the screen), `scroll_top`.
- `BoardsController#show` renders the initial board JSON into the page (`#board-data`), so the board starts without an API round trip. API: `app/controllers/api/*` under `/api`, JSON only, errors as `{errors}` (422) / 404 for foreign records.

### Frontend (`app/frontend/board/`)

- `timeline.ts` — all geometry as pure functions: zoom modes (`days` > 30 px/day ≥ `weeks` > 15 ≥ `months`), date ↔ x conversion by calendar days (DST-safe), the visible range (`buildTimeline`: projects + today + a screen of padding, aligned to columns) and header columns. Keep DOM out of it; it is what the Vitest suite covers.
- `store.ts` — Zustand store. Every change is applied optimistically, then sent to the API; on failure the board is reloaded from `/api/board` and an error toast is shown. Unsaved rows/events have negative ids (`isSaved`). Dashboard view state is saved debounced (1 s) and flushed on `pagehide`.
- `App.tsx` — the board: one scroll container (`.viewport`) for both axes with a sticky date header. It keeps `currentDate` in the middle of the screen whenever zoom, timeline origin or width change (layout effect), pans on drag, zooms on ctrl/⌘+wheel around the pointer, creates a project on double click, and owns keyboard shortcuts. `ProjectRow` (bar, sticky title, edge resize, reorder by dragging the title, off-screen edge labels), `EventMarker` (drag in time, inline edit), `Header` (zoom buttons, today link, selected-project panel).
- Pointer interactions go through `drag.ts#startDrag`, which also swallows the click that follows a drag.
- Row heights per zoom live both in `board.css` and `ROW_HEIGHT` in `App.tsx`; change them together.

### Deployment

https://potee.pismenny.ru runs in the `goga-office` cluster; deployment config lives in `~/code/brandymint/infra` (`STAGE=goga-infra APP=potee`). Images are never built locally: `docker buildx build --platform linux/amd64 --push -t registry.brandymint.ru/dapi/potee:$(git rev-parse HEAD) .` goes to the machine's builder (`BUILDX_BUILDER`, see `~/dotfiles`), then in infra `direnv exec . make app-update STAGE=goga-infra APP=potee TAG=<sha>`. `.dockerignore` is a whitelist because the build context may leave the machine.
