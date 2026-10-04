---
title: "UC-020: Очистка заброшенных анонимных досок"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует операционный сценарий удаления давно не открывавшихся анонимных досок."
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

# UC-020: Очистка заброшенных анонимных досок

## Goal

База не копит доски разовых посетителей.

## Primary Actor

Оператор Potee.

## Trigger

Плановая уборка; расписания пока нет, задача запускается вручную.

## Preconditions

- Доступ к окружению приложения.

## Main Flow

1. Оператор запускает `rake potee:cleanup_anonymous` (по умолчанию 30 дней, `DAYS=` меняет срок).
2. Удаляются анонимные пользователи, которых не видели дольше срока, вместе с их досками.
3. Задача сообщает, сколько удалено.

## Alternate Flows / Exceptions

- `ALT-01` Таких пользователей нет — удалено 0, ничего не меняется.

## Postconditions

- Заброшенных анонимных досок старше срока нет; аккаунты и их доски не тронуты.

## Business Rules

- `BR-01` Удаляются только анонимные пользователи.
- `BR-02` Проекты, которыми поделились, остаются у других участников, если удаляемый не владелец; удаление владельца удаляет его проекты.

## Operational Contract

### Observable Status

- Строка вывода «Deleted N anonymous users not seen for D days».

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
| Main flow, `BR-01` | `spec/models/user_spec.rb` › finds anonymous users that have not been seen for a while |  |
