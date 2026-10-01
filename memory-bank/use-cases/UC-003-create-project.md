---
title: "UC-003: Создание проекта"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: создание проекта."
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

# UC-003: Создание проекта

## Goal

Пользователь добавляет проект с названием и сроками на нужное место доски.

## Primary Actor

Посетитель или пользователь.

## Trigger

Появился новый проект, который нужно запланировать.

## Preconditions

- Открыта доска.

## Main Flow

1. Пользователь нажимает «+ New project» или Enter — черновик появляется первой строкой с даты в центре экрана; либо делает двойной клик по пустому месту — черновик появляется в этой строке с этого дня.
2. Черновик длится неделю, получает свободный цвет и пунктирную обводку; название набирается прямо на полосе, под ней подсказка «Enter — сохранить · Esc — отмена».
3. Пользователь вводит название и нажимает Enter.
4. Проект сохраняется; остальные проекты не приглушаются.

## Alternate Flows / Exceptions

- `ALT-01` Пустое название — проект сохраняется как «Новый проект».
- `ALT-02` Esc или новый черновик отменяют текущий черновик без сохранения.
- `ALT-03` На пустой доске по центру — подсказка и кнопка «Новый проект».
- `EX-01` Сервер не сохранил проект: показывается сообщение об ошибке, доска перезагружается с сервера, черновик пропадает.

## Postconditions

- Проект есть на доске пользователя в выбранной позиции; порядок строк сохранён.

## Business Rules

- `BR-01` Окончание проекта не раньше начала; даты включительные.
- `BR-02` Новый проект принадлежит создателю; удаление его строки удаляет проект.
- `BR-03` Цвет — первый не занятый на доске из 10, иначе по кругу.

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
| Main flow | `e2e/board.spec.ts` › creates a project from the header button; › double click on empty space… |
| `BR-01` | `spec/requests/api/projects_spec.rb` › rejects a finish before the start |
| `EX-01` | `store.ts` fail(); проверено вручную (UX walkthrough 2026-10-01) |
