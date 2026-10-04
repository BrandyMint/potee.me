---
title: "UC-004: Изменение сроков проекта"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует перенос начала и окончания проекта."
derived_from:
  - ../product/context.md
  - ../prd/PRD-001-potee.md
status: active
audience: humans_and_agents
must_not_define:
  - implementation_sequence
  - architecture_decision
  - feature_level_test_matrix
  - bdd_example_inventory
---

# UC-004: Изменение сроков проекта

## Goal

Пользователь переносит начало или окончание проекта без форм, прямо на ленте.

## Primary Actor

Посетитель или пользователь с проектом на доске.

## Trigger

Сроки проекта сдвинулись.

## Preconditions

- Проект сохранён.

## Main Flow

1. Пользователь наводит на левый или правый край полосы — курсор ↔.
2. Тянет край; полоса меняется с шагом в один день.
3. Отпускает — новые даты сохраняются.

## Alternate Flows / Exceptions

- `ALT-01` Край нельзя сдвинуть внутрь дальше первой/последней вехи или за противоположный край — полоса останавливается.
- `ALT-02` Даты можно ввести в окне «Подробнее» ([`UC-005`](UC-005-manage-project.md)); рядом показано число дней.
- `EX-01` Ошибка сохранения — сообщение и откат к данным сервера.

## Postconditions

- Даты проекта изменены для всех, у кого он на доске.

## Business Rules

- `BR-01` Вехи всегда внутри сроков проекта.
- `BR-02` Шаг изменения — один календарный день; окончание не раньше начала.

## Traceability

| Upstream / Downstream | References |
| --- | --- |
| PRD | [`PRD-001`](../prd/PRD-001-potee.md) |
| Features | `none` |
| Related use cases | `none` |
| ADR | `none` |
| Runbooks / Ops | `none` |

## Downstream Behavior Coverage

Навигация: acceptance и проверки живут в тестах и feature `brief.md`.

| UC element | Downstream examples / checks | Coverage note |
| --- | --- | --- |
| Main flow | `e2e/board.spec.ts` › resizing a project changes its dates |  |
| `ALT-02` | `e2e/board.spec.ts` › the expanded panel lists milestones, adds one and changes dates |  |
| `BR-01`, `BR-02` | `spec/requests/api/projects_spec.rb` › rejects a finish before the start |  |
