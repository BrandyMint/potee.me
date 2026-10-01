---
title: "UC-005: Управление проектом: название, цвет, обзор, удаление"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует устойчивый пользовательский сценарий Potee: управление проектом: название, цвет, обзор, удаление."
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

# UC-005: Управление проектом: название, цвет, обзор, удаление

## Goal

Пользователь меняет свойства проекта и быстро видит его целиком.

## Primary Actor

Посетитель или пользователь.

## Trigger

Клик по полосе или названию проекта.

## Preconditions

- Проект сохранён.

## Main Flow

1. Пользователь кликает по проекту — он выделяется, остальные приглушаются; в шапке открывается панель проекта.
2. Меняет название в поле панели (Enter или уход из поля сохраняют, Esc отменяет).
3. Кликает по цветному кружку — цвет меняется на следующий.
4. «Entire» — масштаб и прокрутка подбираются так, чтобы проект целиком поместился на экране.
5. «×», Esc или клик по пустому месту снимают выделение.

## Alternate Flows / Exceptions

- `ALT-01` «Удалить» — проект сразу исчезает с доски, 5 секунд можно нажать «Отменить»; потом удаление сохраняется (у владельца — для всех, у получателя ссылки — только с его доски).
- `ALT-02` На узком экране панель проекта открывается внизу экрана.
- `EX-01` Ошибка сохранения — сообщение и откат к данным сервера.

## Postconditions

- Изменения названия и сроков видны всем участникам; цвет и позиция — только у этого пользователя.

## Business Rules

- `BR-01` Название — общее для проекта, цвет — свой у каждого участника.
- `BR-02` Удаление строки владельцем удаляет проект целиком, остальные участники теряют только свою строку.

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
| Main flow | `e2e/board.spec.ts` › selecting a project opens its panel; › Entire fits…; › deletes a project |
| `ALT-01` | `e2e/board.spec.ts` › a deleted project can be restored with Undo |
| `ALT-02` | `e2e/board.spec.ts` › on a phone › …the panel opens at the bottom |
| `BR-01`, `BR-02` | `spec/requests/api/projects_spec.rb`, `spec/requests/shares_spec.rb` |
