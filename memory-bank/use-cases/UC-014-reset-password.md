---
title: "UC-014: Восстановление пароля"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: восстановление пароля."
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

# UC-014: Восстановление пароля

## Goal

Пользователь, забывший пароль, задаёт новый и попадает на свою доску.

## Primary Actor

Пользователь.

## Trigger

Клик «Forgot password?» на странице входа.

## Preconditions

- Настроена отправка писем (SMTP).

## Main Flow

1. Пользователь вводит email на `/passwords/new`.
2. Видит «If this email is registered, a reset link is on its way.»
3. Получает письмо со ссылкой (действует 15 минут), открывает её, вводит новый пароль.
4. Входит автоматически, открывается доска.

## Alternate Flows / Exceptions

- `EX-01` Ссылка устарела, уже использована или неверна — сообщение и форма запроса новой ссылки.
- `EX-02` Email не зарегистрирован — то же сообщение, письмо не отправляется.

## Postconditions

- Старый пароль и ранее выданные ссылки недействительны.

## Business Rules

- `BR-01` Ответ не раскрывает, зарегистрирован ли email.
- `BR-02` Ссылка одноразовая и живёт 15 минут.

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
| Main flow, `EX-01`, `EX-02` | `spec/requests/auth_spec.rb` › password reset |
