---
title: "UC-011: Регистрация и сохранение доски"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует превращение анонимной доски в аккаунт."
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

# UC-011: Регистрация и сохранение доски

## Goal

Посетитель сохраняет свою доску в аккаунт, чтобы не потерять её и открыть с другого устройства.

## Primary Actor

Посетитель.

## Trigger

Клик «Сохранить доску» в шапке (появляется после первого своего изменения) или переход на `/signup`.

## Preconditions

- Email ещё не зарегистрирован.

## Main Flow

1. Посетитель открывает `/signup`, вводит email и пароль.
2. Нажимает «Зарегистрироваться».
3. Анонимная доска становится доской аккаунта; язык и регион определяются по браузеру (часовой пояс, затем язык); открывается доска, в шапке — email и «Выйти».

## Alternate Flows / Exceptions

- `ALT-01` Регистрация без доски (прямо на `/signup`) — создаётся аккаунт с доской-примером.
- `ALT-02` Логотип на страницах входа ведёт обратно на доску, если она есть, иначе на лендинг.
- `ALT-03` Со страницы регистрации есть ссылка на `/privacy` — какие данные хранит Potee.
- `EX-01` Email уже зарегистрирован — сообщение с предложением войти.
- `EX-02` Короткий пароль или неверный email — сообщение, введённый email сохраняется в форме.
- `EX-03` Больше 10 попыток за 3 минуты — сообщение «Попробуйте позже».

## Postconditions

- Пользователь вошёл; все проекты и вид доски сохранены.

## Business Rules

- `BR-01` Email нечувствителен к регистру и пробелам.
- `BR-02` Пароль 8–72 символа.

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
| Main flow | `e2e/auth.spec.ts` › signing up keeps the board, logging back in restores it; `spec/requests/auth_spec.rb` › sign up |  |
| `ALT-01`, `EX-01`, `EX-02` | `spec/requests/auth_spec.rb` › sign up |  |
| `ALT-02` | `spec/requests/auth_spec.rb` › leads the logo of the auth pages back to the board… |  |
| `ALT-03` | `spec/requests/privacy_spec.rb` |  |
| Main flow 3 (регион) | `spec/requests/settings_spec.rb` › detects the region and language at sign-up… |  |
| `BR-01`, `BR-02` | `spec/models/user_spec.rb` |  |
