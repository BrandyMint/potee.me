---
title: "UC-007: Добавление события"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: добавление события."
derived_from:
  - ../product/context.md
status: draft
audience: humans_and_agents
must_not_define:
  - implementation_sequence
  - architecture_decision
  - feature_level_test_matrix
  - bdd_example_inventory
---

# UC-007: Добавление события

## Goal

Пользователь отмечает веху в проекте точно в нужный момент.

## Primary Actor

Посетитель или пользователь.

## Trigger

Появилась важная дата внутри проекта.

## Preconditions

- Проект сохранён.

## Main Flow

1. Пользователь делает двойной клик по полосе проекта в нужном месте.
2. На полосе появляется метка «Some event» в этот момент (с точностью до минуты).
3. Пользователь кликает по названию метки, чтобы переименовать (`UC-008`).

## Alternate Flows / Exceptions

- `ALT-01` В масштабе недель и месяцев названия событий скрыты; видны при наведении, в неделях — у ближайшего к сегодня события.
- `EX-01` Ошибка сохранения — сообщение и откат.

## Postconditions

- Событие сохранено и видно всем участникам проекта; прошедшие события приглушены.

## Business Rules

- `BR-01` Событие создаётся только внутри сроков проекта.

## Traceability

| Upstream / Downstream | References |
| --- | --- |
| PRD | `none` |
| Features | `none` |
| ADR | `none` |
| Runbooks / Ops | `none` |

## Downstream Behavior Coverage

| UC element | Downstream examples / checks |
| --- | --- |
| Main flow | `e2e/board.spec.ts` › double click on a project adds an event…; `spec/requests/api/events_spec.rb` |
