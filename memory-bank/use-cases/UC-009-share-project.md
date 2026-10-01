---
title: "UC-009: Приглашение в проект по ссылке"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: приглашение в проект по ссылке."
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

# UC-009: Приглашение в проект по ссылке

## Goal

Пользователь даёт другому человеку доступ к проекту одной ссылкой.

## Primary Actor

Посетитель или пользователь — участник проекта.

## Trigger

Нужно показать проект коллеге или близкому.

## Preconditions

- Проект сохранён и выделен.

## Main Flow

1. Пользователь нажимает «Share» в панели проекта.
2. Ссылка копируется в буфер, кнопка на 2 секунды меняется на «Ссылка скопирована».
3. Пользователь отправляет ссылку любым способом.

## Alternate Flows / Exceptions

- `EX-01` Буфер обмена недоступен — показывается поле со ссылкой, выделенной для ручного копирования.

## Postconditions

- У пользователя в буфере ссылка `/share/<key>`.

## Business Rules

- `BR-01` Ссылка у каждого участника своя, но ведёт к одному проекту.
- `BR-02` Ссылку может открыть кто угодно, у кого она есть.

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
| Main flow | проверено вручную (UX walkthrough 2026-10-01) |
