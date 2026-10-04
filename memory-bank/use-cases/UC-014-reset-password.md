---
title: "UC-014: Восстановление пароля"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует сброс забытого пароля по письму."
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

# UC-014: Восстановление пароля

## Goal

Пользователь, забывший пароль, задаёт новый и попадает на свою доску.

## Primary Actor

Пользователь.

## Trigger

Клик «Забыли пароль?» на странице входа.

## Preconditions

- Настроена отправка писем (SMTP).

## Main Flow

1. Пользователь вводит email на `/passwords/new`.
2. Видит сообщение, что ссылка отправлена, если email зарегистрирован.
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
- `BR-03` Страницы со ссылкой сброса не передают адрес в веб-аналитику.

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
| Main flow, `BR-02` | `spec/requests/auth_spec.rb` › emails a link that sets a new password |  |
| `EX-02`, `BR-01` | `spec/requests/auth_spec.rb` › does not reveal whether an email is registered |  |
| `BR-03` | `spec/requests/metrika_spec.rb` › stays off pages whose URL carries a password reset token |  |
