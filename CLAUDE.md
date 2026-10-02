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

- **No sign-up required.** `CurrentUser` (controller concern) creates an anonymous `User` (no email) on the first visit to the board or the API, fills it with `DemoBoard` sample projects and keeps the id in the session cookie (1 year). The landing page and auth pages only read `session_user` and never create users; the landing page sends a logged-in account straight to `/projects`.
- **Accounts are email + password** (`has_secure_password`, Rails reset tokens; no OAuth yet). Sign-up (`RegistrationsController`) turns the current anonymous user into the account, so the board is kept. Log-in from an anonymous board runs `BoardMerge`: the visitor's projects move into the account, except untouched samples (`projects.demo`, cleared by `Project#edited!` on any API change or when someone joins by link), then the anonymous user is deleted. Password reset letters go through `PasswordsMailer` (dev: written to `tmp/mails`; production: SMTP from `SMTP_*` env, not sent without `SMTP_ADDRESS`).
- `rake potee:cleanup_anonymous [DAYS=30]` deletes anonymous users not seen for that long.
- **AI agents (MCP)**: `POST /mcp` (`McpController`, JSON-RPC, Streamable HTTP without SSE) exposes the board as tools from `Mcp::Tools` (`list_projects`, `create_project` with milestones, `update_project`, `delete_project`, `add_event`, `update_event`, `delete_event`). Auth: `Authorization: Bearer <token>`; registered users create the token at `/account`, only its SHA-256 is stored (`users.api_token_digest`). Projects are addressed by board row (connection) id; dates `YYYY-MM-DD`, times `HH:MM` in `Europe/Moscow` by default; milestones must stay within project dates. The agent skill lives in `skills/potee/` (`SKILL.md` + `scripts/potee-mcp`, token from `POTEE_TOKEN`; install and setup in `skills/potee/README.md`).
- **Plan from text (FT-001, `memory-bank/features/FT-001-plan-from-text/`)**: registered users describe a plan in text; `Api::PlanRequestsController` stores a `PlanRequest`, `GeneratePlanJob` (Active Job `:async`) calls `PlanGenerator` → LiteLLM alias `PLAN_MODEL` (default `potee-plan`, Claude Haiku 4.5 via OpenRouter with a GPT mini fallback) at `LITELLM_URL`, `PlanNormalizer` makes the draft valid, the board previews it (`PlanPanel`) and `BoardWriter` adds the chosen projects. Feature flag `PLAN_FROM_TEXT_ENABLED`. Locally run `bin/dev` with `LITELLM_URL=fake` (canned plan). `bin/plan-eval` runs the 10 reference plans (`config/evals/plan_eval.yml`) against the real model; run it in the pod before enabling or switching models.
- **Days off**: weekends and holidays are dimmed on bars and in the days header (days and weeks zoom). `WorkCalendar` gives the board (`calendar` in the payload) the region's weekend, holidays and working weekend days for last/this/next year: RU/BY/KZ/UZ from production calendars in `config/calendars/*.yml` (refresh yearly with `rake potee:calendars YEARS=…`, source xmlcalendar.ru), other countries from the `holidays` gem. `users.region` is detected at sign-up from the browser time zone (hidden field), then the language; anonymous boards guess it from `Accept-Language`. `users.dim_days_off` turns it off; both are set at `/account`.
- **Admin**: Administrate at `/admin` (`app/dashboards`, `app/controllers/admin`). Access only for logged-in users whose email is in `ADMIN_EMAILS` (comma separated); everyone else gets 404.
- **Project vs. ProjectConnection** is the key concept. `Project` holds shared data (title, `started_on`/`finished_on`, owner, events). `ProjectConnection` is one user's row on their board: `position`, `color_index` (10 colours) and `share_key`. The API addresses board rows by **connection id**, not project id — `ProjectConnection#as_card_json` is the row shape the frontend receives.
- Sharing: `/share/:share_key` adds the project to the visitor's board (idempotent) and redirects to `/projects?focus=<connection id>`. Deleting the owner's row deletes the project; other users only lose their row.
- `Dashboard` stores per-user view state: `pixels_per_day` (zoom, 4–200), `current_date` (moment in the middle of the screen), `scroll_top`.
- **Language**: the account's `users.locale` (ru/en, set at sign-up from the browser, changed at `/account`); otherwise Russian by default, English when `Accept-Language` prefers it (`ApplicationController#preferred_locale`). Server texts live in `config/locales/{ru,en}.yml` (incl. demo board texts), the board UI in `app/frontend/board/i18n.ts`; date names use date-fns locales. Playwright runs with `en-US`, so e2e selectors are English; the `in Russian` block covers `ru`.
- `BoardsController#show` renders the initial board JSON into the page (`#board-data`), so the board starts without an API round trip. API: `app/controllers/api/*` under `/api`, JSON only, errors as `{errors}` (422) / 404 for foreign records.

### Frontend (`app/frontend/board/`)

- `timeline.ts` — all geometry as pure functions: zoom modes (`days` > 30 px/day ≥ `weeks` > 15 ≥ `months`), date ↔ x conversion by calendar days (DST-safe), the visible range (`buildTimeline`: projects + today + a screen of padding, aligned to columns) and header columns. Keep DOM out of it; it is what the Vitest suite covers.
- `store.ts` — Zustand store. Every change is applied optimistically, then sent to the API; on failure the board is reloaded from `/api/board` and an error toast is shown (auto-hides). Deleting a project or event removes it at once and sends the DELETE only after a 5 s undo window (toast with Undo). Unsaved rows/events have negative ids (`isSaved`). Dashboard state (debounced 1 s) and pending deletions are flushed on `pagehide`.
- `App.tsx` — the board: one scroll container (`.viewport`) for both axes with a sticky date header. It keeps `currentDate` in the middle of the screen whenever zoom, timeline origin or width change (layout effect), pans on drag, zooms on ctrl/⌘+wheel around the pointer, creates a project on double click, and owns keyboard shortcuts. `ProjectRow` (bar, sticky title, edge resize, reorder by dragging the title, off-screen edge labels), `EventMarker` (drag in time, inline edit), `Header` (zoom buttons, today link, selected-project panel).
- Pointer interactions go through `drag.ts#startDrag`, which also swallows the click that follows a drag.
- Row heights per zoom live both in `board.css` and `ROW_HEIGHT` in `timeline.ts`; change them together. Event titles show at every zoom; close ones are lifted onto tiers (`labelTiers`, measured with canvas, `labelStyle` gives font size, tier height and max tiers per zoom; labels beyond max tiers show on hover); each extra tier adds height to the row via `--tiers-extra`, so rows differ in height and row positions come from the DOM (`rowIndexAt`). The logo runs `fitAll` (largest zoom at which every project fits the width and every row fits the height). Rows are centred vertically (flex) — double-click row index is measured from the first row.
- Narrow screens (≤760 px): short labels (`.label-short`), project panel becomes a bottom sheet; touch scrolls natively (custom panning is mouse-only).
- Use cases and UX review live in `memory-bank/` (`use-cases/UC-*.md`, `reviews/`).

### Deployment

https://potee.pismenny.ru runs in the `goga-office` cluster; deployment config lives in `~/code/brandymint/infra` (`STAGE=goga-infra APP=potee`). Images are never built locally: `docker buildx build --platform linux/amd64 --push -t registry.brandymint.ru/dapi/potee:$(git rev-parse HEAD) .` goes to the machine's builder (`BUILDX_BUILDER`, see `~/dotfiles`), then in infra `direnv exec . make app-update STAGE=goga-infra APP=potee TAG=<sha>`. `.dockerignore` is a whitelist because the build context may leave the machine.
