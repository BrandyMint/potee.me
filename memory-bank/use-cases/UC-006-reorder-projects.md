---
title: "UC-006: Изменение порядка проектов"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: изменение порядка проектов."
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

# UC-006: Изменение порядка проектов

## Goal

Пользователь расставляет проекты по важности.

## Primary Actor

Посетитель или пользователь.

## Trigger

Нужно поднять или опустить проект.

## Preconditions

- На доске больше одного проекта.

## Main Flow

1. Пользователь берёт проект за название (курсор «рука») и тянет вверх или вниз.
2. Строка следует за курсором.
3. Отпускает — проект встаёт в новую позицию, порядок сохраняется.

## Alternate Flows / Exceptions

- `ALT-01` Короткий клик по названию без перетаскивания выделяет проект (`UC-005`).
- `EX-01` Ошибка сохранения — сообщение и откат.

## Postconditions

- Порядок строк сохранён только для этого пользователя.

## Business Rules

- `BR-01` Порядок — личный для каждого пользователя.

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
| Main flow | `e2e/board.spec.ts` › dragging a title reorders the projects; `spec/requests/api/projects_spec.rb` › reorders |
