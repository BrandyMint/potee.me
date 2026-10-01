---
title: "UC-013: Выход из аккаунта"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: выход из аккаунта."
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

# UC-013: Выход из аккаунта

## Goal

Пользователь завершает сеанс на устройстве.

## Primary Actor

Пользователь.

## Trigger

Клик «Log out» в шапке доски.

## Preconditions

- Пользователь вошёл.

## Main Flow

1. Пользователь нажимает «Log out».
2. Сессия сбрасывается, открывается лендинг.

## Alternate Flows / Exceptions

- `ALT-01` Повторный заход на доску создаёт новую анонимную доску.

## Postconditions

- Данные аккаунта не изменились; на устройстве нет доступа к ним.

## Business Rules

- `BR-01` Выход не удаляет и не меняет данные аккаунта.

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
| Main flow | `spec/requests/auth_spec.rb` › logs out into a new anonymous board |
