---
title: "UC-016: Настройки аккаунта"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует, как пользователь настраивает язык, календарь и формат времени."
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

# UC-016: Настройки аккаунта

## Goal

Пользователь видит доску на своём языке, со своими выходными и в привычном формате времени.

## Primary Actor

Пользователь.

## Trigger

Переход на `/account` (ссылка с email в шапке доски).

## Preconditions

- Пользователь вошёл в аккаунт; анонимного посетителя `/account` отправляет на вход.

## Main Flow

1. Пользователь открывает `/account`: email, ссылка на доску, настройки.
2. Выбирает язык, регион, формат времени (24 или 12 часов) и включает или выключает отметку выходных.
3. Сохраняет — интерфейс сразу переключается на выбранный язык, доска показывает выходные, праздники и время по новым настройкам.

## Alternate Flows / Exceptions

- `ALT-01` Без выбранного региона отмечаются только субботы и воскресенья.
- `ALT-02` Без выбранного формата время показывается по языку (английский — 12 часов, русский — 24).
- `ALT-03` Там же пользователь подключает AI-агента — [`UC-017`](UC-017-connect-agent.md).
- `EX-01` Неизвестный регион — сообщение об ошибке, настройки не меняются.

## Postconditions

- Настройки сохранены в аккаунте и действуют на всех устройствах.

## Business Rules

- `BR-01` Регион по умолчанию определяется при регистрации по часовому поясу браузера, затем по языку; анонимной доске — по языку браузера.
- `BR-02` Для России, Беларуси, Казахстана и Узбекистана — производственный календарь с переносами и рабочими субботами; для других стран — государственные праздники.
- `BR-03` Язык аккаунта важнее языка браузера.

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
| Main flow, `EX-01` | `spec/requests/settings_spec.rb` › changes the settings on the account page…; › rejects an unknown region |  |
| `ALT-02` | `spec/requests/settings_spec.rb` › takes the clock from the account, otherwise from the language |  |
| `ALT-01`, `BR-02` | `spec/services/work_calendar_spec.rb` |  |
| `BR-01` | `spec/requests/settings_spec.rb` › detects the region…; › guesses the region of an anonymous board… |  |
