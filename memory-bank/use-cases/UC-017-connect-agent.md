---
title: "UC-017: Подключение AI-агента"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует выпуск токена и подключение AI-агента к доске по MCP."
derived_from:
  - ../product/context.md
  - ../prd/PRD-001-potee.md
  - UC-016-account-settings.md
status: active
audience: humans_and_agents
must_not_define:
  - implementation_sequence
  - architecture_decision
  - feature_level_test_matrix
  - bdd_example_inventory
---

# UC-017: Подключение AI-агента

## Goal

Пользователь даёт своему AI-агенту доступ к доске.

## Primary Actor

Пользователь.

## Trigger

Пользователь хочет вести план через агента.

## Preconditions

- Пользователь вошёл в аккаунт.

## Main Flow

1. Пользователь открывает `/account`, раздел про агентов: адрес MCP-сервера и ссылка на инструкцию `/mcp`.
2. Нажимает «Создать токен» — токен показывается один раз, с подсказкой для Claude Code.
3. Подключает агента по инструкции `/mcp` (в браузере это страница со способами подключения и списком инструментов).

## Alternate Flows / Exceptions

- `ALT-01` Токен уже есть — видна только отметка об этом; «Создать новый токен» выдаёт новый, старый перестаёт работать.
- `EX-01` Анонимный посетитель не может выпустить токен — его отправляют на вход.

## Postconditions

- У агента есть токен; на сервере хранится только его хеш.

## Business Rules

- `BR-01` Токен показывается один раз и не хранится в открытом виде.
- `BR-02` Токены — только у зарегистрированных пользователей; у пользователя один действующий токен.
- `BR-03` Список инструментов на странице `/mcp` совпадает с тем, что сервер отдаёт агенту.

## Traceability

| Upstream / Downstream | References |
| --- | --- |
| PRD | [`PRD-001`](../prd/PRD-001-potee.md) |
| Features | `none` |
| Related use cases | [`UC-018`](UC-018-agent-manages-board.md) |
| ADR | `none` |
| Runbooks / Ops | `skills/potee/README.md` |

## Downstream Behavior Coverage

Навигация: acceptance и проверки живут в тестах и feature `brief.md`.

| UC element | Downstream examples / checks | Coverage note |
| --- | --- | --- |
| Main flow, `ALT-01`, `BR-01`, `BR-02` | `spec/requests/mcp_spec.rb` › issues an agent token once and only to registered users |  |
| Main flow 3, `BR-03` | `spec/requests/mcp_spec.rb` › shows a browser how to connect and every tool the server lists |  |
