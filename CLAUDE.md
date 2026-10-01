# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Potee (potee.me / potee.ru) — visual project planner: projects are horizontal bars on a zoomable, scrollable timeline, with events (milestones) inside them. It is a legacy **Rails 3.2 / Ruby 2.0.0-p353** app with a **Backbone + Marionette single-page UI written in CoffeeScript**, served through the Rails asset pipeline. Comments and commit messages are often in Russian.

## Setup and commands

### Docker (the working way on Apple Silicon)

Ruby 2.0 cannot be built natively on modern macOS, so development runs in Docker: `Dockerfile` compiles Ruby 2.0.0-p648 on Debian jessie (amd64), `docker-compose.yml` adds Postgres 17 (same major as the shared production server).

Images are never built locally. `docker buildx build` goes to the machine's builder chosen via `BUILDX_BUILDER` (`~/dotfiles`: `make docker-remote-builder` / `make docker-builder-status`; currently `office`, native amd64) and is published with `--push` — no `--load`, no `docker compose build`. Compose only pulls `registry.brandymint.ru/dapi/potee:dev`. Running the amd64 containers locally still needs emulation; under plain qemu old jessie binaries can segfault, so use a Rosetta-enabled colima profile:

```sh
colima start potee --vm-type vz --vz-rosetta --cpu 4 --memory 4   # docker context: colima-potee
cp config/database.yml.example config/database.yml                # reads DB_HOST/DB_PORT/DB_USER/DB_PASSWORD from env
cp config/settings/development.yml.example config/settings/development.yml
npx bower install                                                  # on the host, into vendor/assets/components
# only when the dev stage of Dockerfile changes:
docker buildx build --platform linux/amd64 --target dev --push -t registry.brandymint.ru/dapi/potee:dev .
docker compose pull web
docker compose run --rm web bundle install
docker compose run --rm web sh -c 'rake db:create db:schema:load && RAILS_ENV=test rake db:create db:schema:load'
docker compose up -d                                               # http://localhost:3007
```

Use `rake db:create`, not `db:create:all` — the latter refuses to touch the non-local `db` host. Run commands inside the container with `docker compose run --rm web bundle exec …` (add `-e RAILS_ENV=test` for tests).

Test status: `rspec spec/models spec/controllers` passes. The Test::Unit functional tests are stale (fixtures predate the `user` → `owner` rename) and error out. `spec/acceptance` needs Xvfb and real browsers (the `headless` gem) and does not run in the container.

### Original setup (from README)

1. `cp config/database.yml.example config/database.yml` (PostgreSQL; the example uses port 5433)
2. `cp config/settings/development.yml.example config/settings/development.yml` (OAuth keys for Facebook/Twitter/Google)
3. `bundle`
4. `bower install` — frontend libraries (jQuery, Backbone, Marionette, moment, mousetrap, …) are installed by Bower into `vendor/assets/components` (see `.bowerrc`, `bower.json`) and required from `app/assets/javascripts/application.js.coffee`. They are not committed; the app will not compile assets without this step.
5. `script/s` — runs `bundle exec rails server -p 3007`

Tests:

- RSpec (`spec/`, mocks via `rr`, acceptance specs with Capybara + Poltergeist): `bundle exec rspec`, single file `bundle exec rspec spec/models/project_connection_spec.rb`, single example append `:LINE`.
- Legacy Test::Unit (`test/`): `bundle exec rake test`, single file `bundle exec ruby -Itest test/unit/project_test.rb`.
- Jasmine JS specs in `spec/javascripts` (CoffeeScript, run via jasminerice / guard-jasmine; config in `spec/javascripts/support/jasmine.yml`).
- `bundle exec guard` watches both rspec and jasmine (`Guardfile`).
- CI (`.travis.yml`) only runs `rake db:migrate` against `config/database_test.yml`.

Deploy (current): https://potee.pismenny.ru runs in the `goga-office` cluster, configured in `~/code/brandymint/infra` (`STAGE=goga-infra APP=potee`, values in `values/goga-office/potee.yaml.gotmpl`, DB `potee_production` on the shared `postgres.goga.home.arpa`). Release = commit, then from this repo `docker buildx build --platform linux/amd64 --target production --push -t registry.brandymint.ru/dapi/potee:$(git rev-parse HEAD) .`, then in infra `direnv exec . make app-update STAGE=goga-infra APP=potee TAG=<sha>`. The init container runs `rake db:ensure` (schema load on an empty DB, otherwise migrate). The pod runs as uid 1000 with a read-only root filesystem; `script/docker-entrypoint` gives Ruby a private `TMPDIR`.


Legacy release/deploy (Capistrano, pre-Kubernetes): `script/release` bumps the patch version in `.semver` (with git SHA as metadata), tags, commits and pushes; `script/release_and_deploy` also runs `bundle exec cap production deploy` (Capistrano 2 multistage, `config/deploy.rb`, stages `production`/`staging`; deploy runs `bower install` and symlinks shared configs). 
## Architecture

### Server (thin JSON backend)

- **No login required.** `ApplicationController#current_user` silently creates an `Incognito` `User` and stores its id in the session on first visit. OAuth (`SessionsController`, `Authentication.authenticate_or_create`) later attaches providers to that user. `User.destroy_orphans` removes old users without authentications.
- `DummyProjectsObserver` seeds three demo projects with events for every newly created user; `User` `after_create` also creates its `Dashboard`.
- **Project vs. ProjectConnection** is the key concept: `Project` holds shared data (title, dates, owner, events); `ProjectConnection` is a user's membership in a project with per-user `position`, `color_index` and a `share_key`. Users see projects *through* connections (`current_user_projects`). Sharing = visiting `/project_connections/:share_key`, which renders the dashboard with `@shared_project`; the client then creates a connection by POSTing a project with `share_key`. Destroying the owner's connection destroys the project.
- The JSON the client calls a "project" is actually a serialized `ProjectConnection` (`ProjectPresentation` in `app/models/project_presentation.rb` merges project fields + events). Hence `ProjectsController#update` looks up by `params[:project][:project_id]`, and `EventsController` translates the incoming connection id into a real `project_id`.
- `Dashboard` persists per-user view state: `pixels_per_day` (zoom), `current_date`, `scroll_top` (`/dashboard/read`, `/dashboard/update`).
- `Settings` comes from `rails_config` (`config/settings.yml` + `config/settings/*.yml`); `redirect_domains` 301-redirects any host not listed in `Settings.application.hosts` — add your dev host there if requests keep redirecting.
- ActiveAdmin lives under `/admin` (`app/admin/`). The root-level `routes` file is a stale `rake routes` dump, not config.

### Client (`app/assets/javascripts/potee/`, also symlinked as `./potee`)

- `potee/app.js.coffee` defines the `Potee` namespace (`Models`, `Collections`, `Views`, `Controllers`, `Observers`, `Mediators`, …) and `PoteeApp` (a `Marionette.Application`). `app/views/projects/index.html.haml` boots it with `PoteeApp.start(projects:, dashboard:)` using server-rendered JSON.
- The single initializer in `app.js.coffee` wires everything manually and stores most singletons on `window` (`window.projects`, `window.dashboard`, `window.timeline_view`, `window.projects_view`, `window.dashboard_view`, …). **Initialization order matters** (some controllers must exist before views, noted inline); new components are usually added there.
- "Controllers" are plain classes that each own one behaviour (zoom via `Scaller`, `DragScroller`, `GotoDate`, `EntireProject`, `DashboardPersistenter` which debounces dashboard saves and saves project order, etc.). Views render the timeline (`views/timeline/{days,weeks,months}_view`) and project rows.
- Cross-component communication uses three buses: `Backbone.pEvent` (= `App.vent`), `PoteeApp.commands` (e.g. `gotoToday`, `add_shared_project`), and `PoteeApp.seb` — a stateful event broadcaster (`lib/seb.js.coffee`) built on a Backbone.Model, so subscribers react to `change:<path>` (e.g. `project:current`).
- `Potee.Models.Project` keeps its events in `project.projectEvents` (a collection), because `events` is reserved by Backbone; the raw `events` attribute is unset after init.
- Routing (`routers/projects_router.js.coffee`) uses hash fragments: `#today`, `#home`, `#scale/:pixels`, `#entire/:project_id`.
- Templates: mostly `.jst.ejs`, plus `haml_coffee_assets` (`.hamlc`). Styles are Sass with bootstrap-sass and Compass.
- Keyboard/mouse shortcuts are documented in `Keystrokes.md` (`mediators/keystrokes.js.coffee`, via mousetrap).
