---
title: "UC-012: Вход в аккаунт"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: вход в аккаунт."
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

# UC-012: Вход в аккаунт

## Goal

Пользователь открывает свою доску на любом устройстве, не теряя сделанное до входа.

## Primary Actor

Пользователь.

## Trigger

Клик «Log in» на лендинге или в шапке доски.

## Preconditions

- Аккаунт существует.

## Main Flow

1. Пользователь вводит email и пароль на `/login`.
2. Если до входа была анонимная доска, её проекты, созданные или изменённые посетителем, переносятся в конец доски аккаунта.
3. Открывается доска аккаунта.

## Alternate Flows / Exceptions

- `ALT-01` Анонимная доска содержала только нетронутые примеры — ничего не переносится.
- `EX-01` Неверный email или пароль — общее сообщение «Wrong email or password.».
- `EX-02` Забыт пароль — `UC-014`.

## Postconditions

- Анонимный пользователь удалён; сессия принадлежит аккаунту.

## Business Rules

- `BR-01` Ошибка входа не раскрывает, существует ли email.
- `BR-02` Нетронутые демо-проекты не дублируются при слиянии.

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
| Main flow, `BR-02` | `spec/requests/auth_spec.rb` › merges…; `e2e/auth.spec.ts` |
| `EX-01` | `e2e/auth.spec.ts` › wrong password shows an error |
