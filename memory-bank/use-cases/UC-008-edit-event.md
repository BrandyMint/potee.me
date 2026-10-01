---
title: "UC-008: Редактирование события"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: редактирование события."
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

# UC-008: Редактирование события

## Goal

Пользователь переименовывает, переносит или удаляет веху.

## Primary Actor

Посетитель или пользователь.

## Trigger

Изменилась дата или смысл вехи.

## Preconditions

- Событие сохранено.

## Main Flow

1. Перенос: пользователь тянет метку вдоль полосы и отпускает — новый момент сохраняется.
2. Переименование: клик по названию → поле ввода → Enter или уход из поля сохраняют, Esc отменяет.
3. Удаление: в режиме редактирования кнопка «remove».

## Alternate Flows / Exceptions

- `ALT-01` Метку нельзя вытащить за пределы сроков проекта.
- `EX-01` Ошибка сохранения — сообщение и откат.

## Postconditions

- Изменения видны всем участникам проекта.

## Business Rules

- `BR-01` Событие всегда внутри сроков проекта.
- `BR-02` Пустое название не сохраняется — остаётся прежнее.

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
| Main flow | `e2e/board.spec.ts` › dragging an event moves it in time; › …can be renamed |
