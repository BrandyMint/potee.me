---
title: "UC-007: Добавление вехи"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует добавление вехи на полосу проекта."
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

# UC-007: Добавление вехи

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
2. Проект выделяется, на полосе появляется веха «Событие» в этот момент.
3. Пользователь кликает по названию вехи, чтобы переименовать её и задать время ([`UC-008`](UC-008-edit-event.md)).

## Alternate Flows / Exceptions

- `ALT-01` Веху можно добавить в окне «Подробнее» кнопкой «добавить» ([`UC-005`](UC-005-manage-project.md)).
- `ALT-02` Подпись, которая налезла бы на соседнюю, поднимается на ярус выше с линией к своей вехе; строка становится выше.
- `ALT-03` В мелких масштабах подписи меньше и ярусов меньше; не поместившиеся показываются при наведении.
- `ALT-04` Наведение на веху после короткой паузы приглушает все остальные вехи доски, чтобы подпись читалась.
- `EX-01` Ошибка сохранения — сообщение и откат.

## Postconditions

- Веха сохранена и видна всем участникам проекта; прошедшие вехи приглушены.

## Business Rules

- `BR-01` Веха создаётся только внутри сроков проекта.

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
| Main flow | `e2e/board.spec.ts` › double click on a project adds an event, which can be renamed |  |
| `ALT-01` | `e2e/board.spec.ts` › the expanded panel lists milestones, adds one and changes dates |  |
| `ALT-02`, `ALT-03` | `e2e/board.spec.ts` › labels of close events go to separate tiers…; › event titles stay visible when zooming out |  |
| `BR-01` | `spec/requests/api/events_spec.rb` |  |
