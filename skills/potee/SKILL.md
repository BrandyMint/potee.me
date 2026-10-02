---
name: potee
description: Read and change the user's Potee board (potee.pismenny.ru) — projects as bars on a timeline with milestones. Use when the user asks to put a plan, launch, course, roadmap or schedule on Potee, to show what is on the board, or to move, add, rename or delete projects and milestones there.
---

# Potee board

Potee is a visual planner: each **project** is a bar on a timeline from
`start_date` to `end_date` (inclusive), each **milestone** (event) is a mark on
a bar at a date and time. The user sees the result at
<https://potee.pismenny.ru/projects>.

## How to call it

Run the bundled CLI `scripts/potee-mcp` (Python 3, no dependencies). It lives
next to this `SKILL.md`, so call it by the full path from this skill's
directory, e.g. `~/.claude/skills/potee/scripts/potee-mcp` or
`~/.codex/skills/potee/scripts/potee-mcp`:

```sh
POTEE=<skill dir>/scripts/potee-mcp
$POTEE tools                                   # tools and arguments
$POTEE call list_projects
$POTEE call create_project '{"title": "...", "start_date": "2026-10-01", "end_date": "2026-10-28",
  "events": [{"title": "...", "date": "2026-10-14", "time": "19:00"}]}'
```

The token comes from the `POTEE_TOKEN` environment variable. If it is missing,
ask the user to create one at <https://potee.pismenny.ru/account> and export it
as `POTEE_TOKEN` (see `README.md`) — never print it.

If the agent has the MCP server connected directly
(`https://potee.pismenny.ru/mcp`, `Authorization: Bearer <token>`), call the
same tools natively instead of the CLI.

## Tools

| Tool | Arguments |
| --- | --- |
| `list_projects` | `timezone?` |
| `create_project` | `title`, `start_date`, `end_date`, `color?` (0–9), `events?` [`{title, date, time?}`], `timezone?` |
| `update_project` | `project_id`, `title?`, `start_date?`, `end_date?`, `color?`, `timezone?` |
| `delete_project` | `project_id` |
| `add_event` | `project_id`, `title`, `date`, `time?`, `timezone?` |
| `update_event` | `event_id`, `title?`, `date?`, `time?`, `timezone?` |
| `delete_event` | `event_id` |

Dates are `YYYY-MM-DD`, timezone `Europe/Moscow` unless given. Pass `time`
(`HH:MM`) only when a milestone happens at a specific time (a call, a meeting):
such milestones show their start time on the board; without `time` a milestone
is just a day. Milestones must lie within their project's
dates: extend the project first, or the call fails with an explanation.

## Working rules

1. **Look before writing.** Start with `list_projects`; update existing projects
   instead of creating duplicates. Match by title, then confirm ids.
2. **One bar per stream or phase.** Split a plan into parallel or consecutive
   streams (e.g. «Подготовка», «Продажи», «Модуль 1») rather than one long bar.
   Prefix related bars with a short common name so they read as a group.
3. **Milestones are moments that matter:** calls, deadlines, launches,
   decisions — not every task. Keep titles short (2–4 words).
4. **Take dates from the source of truth** (project docs, the user's message);
   don't invent dates. Mark guesses in your reply, not on the board.
5. **Deleting is irreversible through the API** (the web UI offers undo, the
   API does not) and deleting an owned project removes it for everyone it is
   shared with — ask before deleting anything you did not create in this task.
6. Finish with a short summary of what changed and the board link.
