---
title: "UC-018: Агент ведёт доску по MCP"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует agentic-сценарий: AI-агент читает и меняет доску пользователя через MCP."
derived_from:
  - ../product/context.md
  - ../prd/PRD-001-potee.md
  - UC-017-connect-agent.md
status: active
audience: humans_and_agents
must_not_define:
  - implementation_sequence
  - architecture_decision
  - feature_level_test_matrix
  - bdd_example_inventory
---

# UC-018: Агент ведёт доску по MCP

## Goal

Агент раскладывает план пользователя на доске и поддерживает его в актуальном виде.

## Primary Actor

AI-агент (Claude Code, Codex или другой MCP-клиент) от имени пользователя.

## Trigger

Пользователь просит агента занести или изменить план.

## Preconditions

- Агент подключён с действующим токеном ([`UC-017`](UC-017-connect-agent.md)).

## Main Flow

1. Агент выполняет рукопожатие MCP и получает список инструментов и инструкции.
2. Читает доску (`list_projects`): строки с id, сроками, вехами.
3. Создаёт проект с вехами (`create_project`), меняет его (`update_project`), добавляет, меняет и удаляет вехи (`add_event`, `update_event`, `delete_event`), удаляет проект (`delete_project`).
4. Пользователь открывает доску и видит изменения.

## Alternate Flows / Exceptions

- `EX-01` Нет токена или он неверный — отказ в доступе, доска не меняется.
- `EX-02` Неверные данные (даты, веха вне сроков, чужой или несуществующий id) — результат инструмента с ошибкой, которую агент может прочитать и исправить; доска не меняется.

## Postconditions

- Изменения агента — обычные проекты и вехи пользователя: их можно править, удалять с отменой и шарить.

## Business Rules

- `BR-01` Проекты адресуются по id строки доски пользователя; чужие проекты недоступны.
- `BR-02` Даты — `YYYY-MM-DD`, время — `HH:MM`, по умолчанию в часовом поясе `Europe/Moscow`.
- `BR-03` Вехи всегда внутри сроков проекта.

## Operational Contract

### Observable Status

- Ответы — JSON-RPC 2.0 по Streamable HTTP без SSE; версия сервера (`serverInfo.version`) — версия Potee.
- Ошибка инструмента — обычный результат с `isError: true` и текстом причины, а не сбой протокола.

### Diagnostics And Recovery

- Агент исправляет вызов по тексту ошибки и повторяет; частичных изменений при ошибке нет.

## Traceability

| Upstream / Downstream | References |
| --- | --- |
| PRD | [`PRD-001`](../prd/PRD-001-potee.md) |
| Features | `none` |
| Related use cases | [`UC-017`](UC-017-connect-agent.md), [`UC-019`](UC-019-plan-from-text.md) |
| ADR | `none` |
| Runbooks / Ops | `skills/potee/` |

## Downstream Behavior Coverage

Навигация: acceptance и проверки живут в тестах и feature `brief.md`.

| UC element | Downstream examples / checks | Coverage note |
| --- | --- | --- |
| Main flow 1 | `spec/requests/mcp_spec.rb` › speaks the MCP handshake and lists the tools |  |
| Main flow 3 | `spec/requests/mcp_spec.rb` › creates a project with milestones and changes it |  |
| `EX-01` | `spec/requests/mcp_spec.rb` › rejects requests without a valid token |  |
| `EX-02`, `BR-01`, `BR-03` | `spec/requests/mcp_spec.rb` › keeps milestones inside the project dates; › does not reach other users' projects |  |
