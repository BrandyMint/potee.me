---
title: "UC-003: Создание проекта"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует создание проекта прямо на ленте."
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

# UC-003: Создание проекта

## Goal

Пользователь добавляет проект с названием и сроками на нужное место доски.

## Primary Actor

Посетитель или пользователь.

## Trigger

Появился новый проект, который нужно запланировать.

## Preconditions

- Открыта доска, ни один проект не выделен (иначе в шапке инструменты проекта, [`UC-005`](UC-005-manage-project.md)).

## Main Flow

1. Пользователь нажимает «Новый проект» или Enter — черновик появляется первой строкой с даты в центре экрана; либо делает двойной клик по пустому месту — черновик появляется в этой строке с этого дня.
2. Черновик длится 7 дней, получает свободный цвет и пунктирную обводку; название набирается прямо на полосе, под ней подсказка «Enter — сохранить · Esc — отмена». Шапка на это время гаснет, кроме логотипа.
3. Пользователь вводит название и нажимает Enter.
4. Проект сохраняется на этой строке.

## Alternate Flows / Exceptions

- `ALT-01` Пустое название — проект сохраняется с названием по умолчанию «Новый проект».
- `ALT-02` Esc или новый черновик отменяют текущий черновик без сохранения.
- `ALT-03` Проекты из текста — [`UC-019`](UC-019-plan-from-text.md); от агента — [`UC-018`](UC-018-agent-manages-board.md).
- `EX-01` Сервер не сохранил проект: сообщение об ошибке, доска перезагружается с сервера, черновик пропадает.

## Postconditions

- Проект есть на доске пользователя в выбранной позиции; порядок строк сохранён.

## Business Rules

- `BR-01` Окончание проекта не раньше начала; даты включительные.
- `BR-02` Новый проект принадлежит создателю; удаление его строки удаляет проект.
- `BR-03` Цвет — первый не занятый на доске из 10, иначе по кругу.
- `BR-04` Любой свой проект делает доску «изменённой»: появляется призыв «Сохранить доску» ([`UC-011`](UC-011-sign-up.md)).

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
| Main flow | `e2e/board.spec.ts` › creates a project from the header button; › double click on empty space starts a project there, Escape cancels it |  |
| `ALT-02` | `e2e/board.spec.ts` › double click on empty space… Escape cancels it |  |
| `BR-01`, `BR-02` | `spec/requests/api/projects_spec.rb` |  |
| `BR-04` | `spec/requests/board_spec.rb` › marks the board edited… |  |
