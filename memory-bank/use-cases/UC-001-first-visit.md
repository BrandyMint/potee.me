---
title: "UC-001: Первое знакомство с доской"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: первое знакомство с доской."
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

# UC-001: Первое знакомство с доской

## Goal

Посетитель за секунды видит, как выглядит планирование в Potee, на живой доске с примерами — без регистрации.

## Primary Actor

Посетитель.

## Trigger

Переход на `/` и клик «Get started» или прямой заход на `/projects`.

## Preconditions

- У посетителя нет сессии Potee (или она истекла).

## Main Flow

1. Посетитель открывает лендинг: логотип, слоган, «Get started», «Log in».
2. Нажимает «Get started».
3. Система создаёт анонимного пользователя и доску с тремя проектами-примерами и событиями.
4. Доска открывается в масштабе «дни», сегодняшний день в центре и подсвечен.

## Alternate Flows / Exceptions

- `ALT-01` Посетитель с действующей сессией сразу видит свою доску в сохранённом виде.
- `ALT-02` Переход по ссылке на чужой проект — см. `UC-010`.
- `EX-01` Браузер без cookie: каждый визит создаёт новую доску; данные не сохраняются между визитами.

## Postconditions

- У посетителя есть анонимная доска, привязанная к cookie на 1 год.

## Business Rules

- `BR-04` Язык интерфейса и примеров — русский по умолчанию, английский, если браузер предпочитает английский.
- `BR-01` Лендинг и страницы входа не создают пользователей.
- `BR-02` Новая доска всегда содержит одни и те же примеры, помеченные как демо.
- `BR-03` Демо-проекты, которые посетитель не трогал, не переносятся при входе в аккаунт (`UC-012`).

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
| `BR-01` | `spec/requests/board_spec.rb` (landing does not create users) |
| Main flow | `e2e/board.spec.ts` › shows the demo board in days zoom |
