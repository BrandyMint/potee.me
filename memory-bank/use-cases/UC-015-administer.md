---
title: "UC-015: Администрирование и отчёт по источникам"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует работу администратора с данными и отчётом по источникам."
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

# UC-015: Администрирование и отчёт по источникам

## Goal

Администратор видит пользователей, проекты, вехи и запросы планов, может исправить или удалить данные и оценить источники.

## Primary Actor

Администратор.

## Trigger

Переход на `/admin`.

## Preconditions

- Администратор вошёл в аккаунт с email из `ADMIN_EMAILS`.

## Main Flow

1. Администратор открывает `/admin` — список пользователей, новые сверху.
2. Переключается между разделами пользователей, проектов, вех, строк досок и запросов «План из текста»; ищет и фильтрует.
3. Открывает запись, при необходимости редактирует безопасные поля или удаляет.

## Alternate Flows / Exceptions

- `ALT-01` Раздел «Источники»: новые доски по первому UTM-источнику (или medium / campaign) и неделе с воронкой до регистрации.
- `EX-01` Не администратор или не вошёл — страница 404 (раздел не обнаруживается).

## Postconditions

- Изменения сразу видны пользователям.

## Business Rules

- `BR-01` Пароли, их хеши и токены агентов не показываются и не редактируются.
- `BR-02` Список администраторов задаётся только конфигурацией.
- `BR-03` Источник визита определяется только UTM-метками первой страницы, внешним referrer или ссылкой-приглашением; `?ref=` не учитывается.

## Traceability

| Upstream / Downstream | References |
| --- | --- |
| PRD | [`PRD-001`](../prd/PRD-001-potee.md) |
| Features | `none` |
| Related use cases | [`UC-001`](UC-001-first-visit.md) |
| ADR | `none` |
| Runbooks / Ops | `none` |

## Downstream Behavior Coverage

Навигация: acceptance и проверки живут в тестах и feature `brief.md`.

| UC element | Downstream examples / checks | Coverage note |
| --- | --- | --- |
| Main flow, `EX-01` | `spec/requests/admin_spec.rb` |  |
| `ALT-01`, `BR-03` | `spec/requests/sources_spec.rb` |  |
