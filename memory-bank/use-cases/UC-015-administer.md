---
title: "UC-015: Администрирование"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: администрирование."
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

# UC-015: Администрирование

## Goal

Администратор видит пользователей, проекты и события и может исправить или удалить данные.

## Primary Actor

Администратор.

## Trigger

Переход на `/admin`.

## Preconditions

- Администратор вошёл в аккаунт с email из `ADMIN_EMAILS`.

## Main Flow

1. Администратор открывает `/admin` — список пользователей, новые сверху.
2. Переключается между разделами Users, Projects, Events, Project Connections; ищет и фильтрует (`registered:`, `anonymous:`, `demo:`, `real:`).
3. Открывает запись, при необходимости редактирует безопасные поля или удаляет.

## Alternate Flows / Exceptions

- `EX-01` Не администратор или не вошёл — страница 404 (раздел не обнаруживается).

## Postconditions

- Изменения сразу видны пользователям.

## Business Rules

- `BR-01` Пароли и их хеши не показываются и не редактируются.
- `BR-02` Список администраторов задаётся только конфигурацией.

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
| Main flow, `EX-01`, `BR-01` | `spec/requests/admin_spec.rb` |
