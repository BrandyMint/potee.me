---
title: "UC-004: Изменение сроков проекта"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: изменение сроков проекта."
derived_from:
  - ../product/context.md
  - ../prd/PRD-001-potee.md
status: draft
audience: humans_and_agents
must_not_define:
  - implementation_sequence
  - architecture_decision
  - feature_level_test_matrix
  - bdd_example_inventory
---

# UC-004: Изменение сроков проекта

## Goal

Пользователь переносит начало или окончание проекта, не открывая форм.

## Primary Actor

Посетитель или пользователь с проектом на доске.

## Trigger

Сроки проекта сдвинулись.

## Preconditions

- Проект сохранён.

## Main Flow

1. Пользователь наводит на левый или правый край полосы — курсор меняется на ↔.
2. Тянет край; полоса меняется с шагом в один день.
3. Отпускает — новые даты сохраняются.

## Alternate Flows / Exceptions

- `ALT-01` Край нельзя сдвинуть внутрь дальше первого/последнего события — полоса останавливается.
- `EX-01` Ошибка сохранения — сообщение и откат к данным сервера.

## Postconditions

- Даты проекта изменены для всех, у кого он на доске.

## Business Rules

- `BR-01` События всегда внутри сроков проекта.
- `BR-02` Шаг изменения — один календарный день.

## Traceability

| Upstream / Downstream | References |
| --- | --- |
| PRD | [`PRD-001`](../prd/PRD-001-potee.md) |
| Features | `none` |
| ADR | `none` |
| Runbooks / Ops | `none` |

## Downstream Behavior Coverage

| UC element | Downstream examples / checks |
| --- | --- |
| Main flow | `e2e/board.spec.ts` › resizing a project changes its dates |
