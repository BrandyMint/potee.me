---
title: "UC-010: Присоединение к проекту по ссылке"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует, как получатель ссылки получает общий проект на свою доску."
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
3. Открывается доска: проект выделен и показан целиком.

## Alternate Flows / Exceptions

- `ALT-01` У получателя ещё нет доски — сначала создаётся анонимная доска с примерами.
- `ALT-02` Проект уже на доске — повторно не добавляется, просто показывается.
- `EX-01` Проект удалён или ключ неверен — страница 404.

## Postconditions

- Получатель — участник проекта: видит общие изменения, может убрать проект только со своей доски.

## Business Rules

- `BR-01` Присоединение идемпотентно.
- `BR-02` Общий проект перестаёт считаться демо.
- `BR-03` Визит по ссылке учитывается как источник `potee` / `share`.

## Traceability

| Upstream / Downstream | References |
| --- | --- |
| PRD | [`PRD-001`](../prd/PRD-001-potee.md) |
| Features | `none` |
| Related use cases | [`UC-009`](UC-009-share-project.md) |
| ADR | `none` |
| Runbooks / Ops | `none` |

## Downstream Behavior Coverage

Навигация: acceptance и проверки живут в тестах и feature `brief.md`.

| UC element | Downstream examples / checks | Coverage note |
| --- | --- | --- |
| Main flow, `ALT-01` | `e2e/board.spec.ts` › a share link adds the project to another visitor's board |  |
| `BR-01`, `EX-01` | `spec/requests/shares_spec.rb` |  |
| `BR-03` | `spec/requests/sources_spec.rb` › marks boards that start from a share link |  |
