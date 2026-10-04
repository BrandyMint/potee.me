---
title: "UC-001: Первое знакомство с доской"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует, как новый посетитель без регистрации получает живую доску с примерами."
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

# UC-001: Первое знакомство с доской

## Goal

Посетитель за секунды видит, как выглядит планирование в Potee, на живой доске с примерами — без регистрации.

## Primary Actor

Посетитель.

## Trigger

Клик «Начать» на лендинге `/` или прямой заход на `/projects`.

## Preconditions

- У посетителя нет сессии Potee (или она истекла).

## Main Flow

1. Посетитель открывает лендинг: живая лента с проектами, слоган, «Начать», «Войти», ссылка на `/privacy`.
2. Нажимает «Начать».
3. Система создаёт анонимного пользователя и доску с проектами-примерами и вехами на языке посетителя.
4. Доска открывается сразу на весь план: масштаб подобран так, чтобы все проекты поместились по ширине и высоте; строки — сразу под шапкой дат; «сейчас» — тонкая линия, которая сама сдвигается каждую минуту.

## Alternate Flows / Exceptions

- `ALT-01` Посетитель с действующей сессией видит свою доску в сохранённом виде (масштаб, дата в центре, прокрутка).
- `ALT-02` Пользователь, вошедший в аккаунт, с лендинга сразу перенаправляется на доску.
- `ALT-03` Переход по ссылке на чужой проект — см. [`UC-010`](UC-010-join-shared-project.md).
- `ALT-04` Пустая доска (все проекты удалены) показывает по центру подсказку: двойной клик по ленте или Enter создают проект.
- `EX-01` Браузер без cookie: каждый визит создаёт новую доску; между визитами ничего не сохраняется.

## Postconditions

- У посетителя есть анонимная доска, привязанная к cookie сессии на 1 год.
- Источник визита (UTM-метки первой страницы, внешний referrer или ссылка-приглашение) сохранён в пользователе для отчёта [`UC-015`](UC-015-administer.md).

## Business Rules

- `BR-01` Лендинг, страницы входа и `/privacy` не создают пользователей.
- `BR-02` Новая доска всегда содержит одни и те же примеры, помеченные как демо, пока посетитель их не изменил.
- `BR-03` Нетронутые демо-проекты не переносятся при входе в аккаунт ([`UC-012`](UC-012-log-in.md)).
- `BR-04` Язык интерфейса и примеров — русский по умолчанию, английский, если браузер предпочитает английский.
- `BR-05` Пока посетитель ничего не изменил, призыв «Сохранить доску» не показывается.

## Traceability

| Upstream / Downstream | References |
| --- | --- |
| PRD | [`PRD-001`](../prd/PRD-001-potee.md) |
| Features | `none` |
| Related use cases | [`UC-010`](UC-010-join-shared-project.md), [`UC-011`](UC-011-sign-up.md), [`UC-012`](UC-012-log-in.md) |
| ADR | `none` |
| Runbooks / Ops | `none` |

## Downstream Behavior Coverage

Навигация: acceptance и проверки живут в тестах и feature `brief.md`.

| UC element | Downstream examples / checks | Coverage note |
| --- | --- | --- |
| Main flow | `e2e/board.spec.ts` › a new visitor opens on the whole plan; › rows start right under the date header | Весь план на экране, строки под шапкой |
| `ALT-01`, `ALT-02`, `BR-01` | `spec/requests/board_spec.rb` | Сессия, редирект аккаунта, лендинг без пользователей |
| `ALT-04` | `e2e/board.spec.ts` › an empty board explains how to start |  |
| `BR-02`, `BR-05` | `spec/requests/board_spec.rb` › marks the board edited… |  |
| `BR-04` | `spec/requests/board_spec.rb` (Language); `e2e/board.spec.ts` › in Russian |  |
| Postconditions (источник) | `spec/requests/sources_spec.rb` |  |
