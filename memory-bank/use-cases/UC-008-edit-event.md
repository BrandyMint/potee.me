---
title: "UC-008: Редактирование вехи"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует переименование, перенос, время, порядок и удаление вех."
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

# UC-008: Редактирование вехи

## Goal

Пользователь переименовывает, переносит, уточняет время или удаляет веху.

## Primary Actor

Посетитель или пользователь.

## Trigger

Изменилась дата или смысл вехи.

## Preconditions

- Веха сохранена.

## Main Flow

1. Перенос: пользователь тянет веху вдоль полосы и отпускает — новый момент сохраняется.
2. Правка на месте: клик по названию — название редактируется в пунктирной рамке, все остальные вехи доски гаснут и не мешают; над названием — время или «+ время» (подставляет момент, где стоит веха, с точностью до 15 минут).
3. Enter или ✓ сохраняют, Esc отменяет; корзина удаляет веху, 5 секунд можно нажать «Отменить».
4. Веха со временем в масштабе «дни» показывает его маленькой строкой над названием.

## Alternate Flows / Exceptions

- `ALT-01` В окне «Подробнее» ([`UC-005`](UC-005-manage-project.md)) список вех: веху можно перенести на другой день, удалить при наведении или перетащить, чтобы поменять порядок шагов — даты при этом остаются на местах.
- `ALT-02` Клик по названию вехи в списке закрывает окно, переносит ленту к вехе и открывает правку на месте.
- `ALT-03` Время можно убрать — веха снова «на весь день».
- `EX-01` Неверное время — подсказка с примером, веха не сохраняется.
- `EX-02` Ошибка сохранения — сообщение и откат.

## Postconditions

- Изменения видны всем участникам проекта.

## Business Rules

- `BR-01` Веха всегда внутри сроков проекта; метку нельзя вытащить за его края.
- `BR-02` Пустое название не сохраняется — остаётся прежнее.
- `BR-03` Время показывается в формате аккаунта: 24 или 12 часов ([`UC-016`](UC-016-account-settings.md)).

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
| Main flow 1 | `e2e/board.spec.ts` › dragging an event moves it in time |  |
| Main flow 2–4, `ALT-03` | `e2e/board.spec.ts` › editing a milestone fades the milestones of every project; › an event with a time shows it in the days zoom |  |
| `ALT-01` | `e2e/board.spec.ts` › milestones in the panel move to another day and are deleted on hover; › dragging a milestone in the panel changes the order of steps, dates stay |  |
| `BR-01` | `spec/requests/api/events_spec.rb` |  |
| `BR-03` | `spec/requests/settings_spec.rb` › takes the clock from the account… |  |
