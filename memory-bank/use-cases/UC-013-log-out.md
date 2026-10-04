---
title: "UC-013: Выход из аккаунта"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует завершение сеанса."
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

# UC-013: Выход из аккаунта

## Goal

Пользователь завершает сеанс на устройстве.

## Primary Actor

Пользователь.

## Trigger

Клик «Выйти» в шапке доски.

## Preconditions

- Пользователь вошёл.

## Main Flow

1. Пользователь нажимает «Выйти».
2. Сессия сбрасывается.

## Alternate Flows / Exceptions

- `ALT-01` Следующий заход на доску создаёт новую анонимную доску.

## Postconditions

- Данные аккаунта не изменились; на устройстве нет доступа к ним.

## Business Rules

- `BR-01` Выход не удаляет и не меняет данные аккаунта.

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
| Main flow, `ALT-01` | `spec/requests/auth_spec.rb` › logs out into a new anonymous board |  |
