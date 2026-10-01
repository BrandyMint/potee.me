---
title: "UC-011: Регистрация и сохранение доски"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: регистрация и сохранение доски."
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

# UC-011: Регистрация и сохранение доски

## Goal

Посетитель сохраняет свою доску в аккаунт, чтобы не потерять её и открыть с другого устройства.

## Primary Actor

Посетитель.

## Trigger

Клик «Sign up to save your projects».

## Preconditions

- Email ещё не зарегистрирован.

## Main Flow

1. Посетитель открывает `/signup`, вводит email и пароль (от 8 символов).
2. Нажимает «Sign up».
3. Анонимная доска становится доской аккаунта; открывается доска с приветствием, в шапке — email и «Log out».

## Alternate Flows / Exceptions

- `ALT-01` Регистрация без доски (прямо на `/signup`) — создаётся аккаунт с доской-примером.
- `EX-01` Email уже зарегистрирован — сообщение «Log in instead».
- `EX-02` Пароль короче 8 символов или неверный email — сообщение, введённый email сохраняется в форме.
- `EX-03` Больше 10 попыток за 3 минуты — сообщение «Try again later».

## Postconditions

- Пользователь вошёл; все проекты и вид доски сохранены.

## Business Rules

- `BR-01` Email нечувствителен к регистру и пробелам.
- `BR-02` Пароль 8–72 символа.

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
| Main flow, `EX-01`, `EX-02` | `spec/requests/auth_spec.rb` › sign up; `e2e/auth.spec.ts` |
