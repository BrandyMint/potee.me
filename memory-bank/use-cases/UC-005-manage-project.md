---
title: "UC-005: Управление проектом: инструменты и подробности"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует выделение проекта, его инструменты в шапке и окно подробностей."
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

# UC-005: Управление проектом: инструменты и подробности

## Goal

Пользователь меняет свойства проекта, видит его целиком и открывает подробности — не теряя доску из виду.

## Primary Actor

Посетитель или пользователь.

## Trigger

Клик по полосе или названию проекта.

## Preconditions

- Проект сохранён.

## Main Flow

1. Первый клик по проекту выделяет его, остальные приглушаются; в шапке вместо «Новый проект» и «План из текста» появляются инструменты проекта: переименовать, поделиться, цвет, «Целиком», удалить, «Подробнее», закрыть.
2. «Переименовать» (или двойной клик по названию) — название редактируется прямо в полосе, с пунктирной обводкой и подсказкой, как у нового проекта; вехи проекта на это время скрыты. Enter или уход из поля сохраняют, Esc отменяет.
3. Кружок цвета открывает палитру из 10 цветов; выбранный цвет применяется сразу.
4. «Целиком» подбирает масштаб и прокрутку так, чтобы проект поместился на экране с отступами.
5. «Подробнее» (или второй клик по выделенному проекту) открывает окно по центру поверх размытой доски: сроки ([`UC-004`](UC-004-change-project-dates.md)) и список вех ([`UC-008`](UC-008-edit-event.md)). Esc, × или клик по фону закрывают окно.
6. ×, Esc или клик по пустому месту снимают выделение.

## Alternate Flows / Exceptions

- `ALT-01` «Удалить» — проект сразу исчезает с доски, 5 секунд можно нажать «Отменить»; потом удаление сохраняется. У получателя ссылки кнопка называется «Убрать с доски» и убирает только его строку.
- `ALT-02` На узком экране (≤ 760 px) окно подробностей открывается снизу, а инструменты прокручиваются в шапке.
- `ALT-03` «Поделиться» — [`UC-009`](UC-009-share-project.md).
- `ALT-04` Двойной клик по полосе выделенного проекта добавляет веху, а не открывает подробности ([`UC-007`](UC-007-add-event.md)).
- `EX-01` Ошибка сохранения — сообщение и откат к данным сервера.

## Postconditions

- Название и сроки видны всем участникам; цвет и позиция — только у этого пользователя.

## Business Rules

- `BR-01` Название и сроки — общие для проекта, цвет — свой у каждого участника.
- `BR-02` Удаление строки владельцем удаляет проект целиком; остальные участники теряют только свою строку.
- `BR-03` Пустое название при переименовании не сохраняется — остаётся прежнее.
- `BR-04` Первый клик выделяет, второй открывает подробности после интервала двойного клика; двойной клик по названию переименовывает.

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
| Main flow 1–3 | `e2e/board.spec.ts` › selecting a project puts its tools in the header: rename in the bar and recolour; › renaming in the bar looks like a new project |  |
| Main flow 4 | `e2e/board.spec.ts` › Entire fits the selected project into the screen |  |
| Main flow 5, `BR-04` | `e2e/board.spec.ts` › clicks on a project: select, then the details dialog…; › details open in a dialog in the middle of the screen… |  |
| `ALT-01` | `e2e/board.spec.ts` › deletes a project; › a deleted project can be restored with Undo |  |
| `ALT-02` | `e2e/board.spec.ts` › on a phone › the header fits without overlaps and the project details open at the bottom |  |
| `ALT-04` | `e2e/board.spec.ts` › a double click adds a milestone even on the active project and opens no panel |  |
| `BR-01`, `BR-02` | `spec/requests/api/projects_spec.rb`, `spec/requests/shares_spec.rb` |  |
