---
title: "UC-010: Присоединение к проекту по ссылке"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: присоединение к проекту по ссылке."
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

# UC-010: Присоединение к проекту по ссылке

## Goal

Получатель ссылки видит общий проект у себя на доске.

## Primary Actor

Получатель ссылки (анонимный или зарегистрированный).

## Trigger

Переход по ссылке `/share/<key>`.

## Preconditions

- Ссылка действительна (проект существует).

## Main Flow

1. Получатель открывает ссылку.
2. Проект добавляется на его доску первой строкой со свободным цветом.
3. Открывается доска: проект выделен и показан целиком (`Entire`).

## Alternate Flows / Exceptions

- `ALT-01` У получателя ещё нет доски — сначала создаётся анонимная доска с примерами.
- `ALT-02` Проект уже на доске — повторно не добавляется, просто показывается.
- `EX-01` Проект удалён или ключ неверен — страница 404.

## Postconditions

- Получатель — участник проекта: видит общие изменения, может удалить проект только со своей доски.

## Business Rules

- `BR-01` Присоединение идемпотентно.
- `BR-02` Общий проект перестаёт считаться демо.

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
| Main flow, `BR-01` | `spec/requests/shares_spec.rb`; `e2e/board.spec.ts` › a share link adds the project… |
