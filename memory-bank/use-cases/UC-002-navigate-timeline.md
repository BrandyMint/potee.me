---
title: "UC-002: Навигация по ленте времени"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует, как пользователь перемещается по ленте, меняет масштаб и возвращается к сегодня."
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

# UC-002: Навигация по ленте времени

## Goal

Пользователь находит нужный период и проект: прокручивает, меняет масштаб, возвращается к сегодня или видит весь план; вид запоминается.

## Primary Actor

Посетитель или пользователь.

## Trigger

Нужно посмотреть другой период, детальнее или обзорнее.

## Preconditions

- Открыта доска.

## Main Flow

1. Пользователь перетаскивает пустое место или полосу мышью — доска сдвигается по обеим осям (на сенсорном экране — обычная прокрутка).
2. Меняет масштаб кнопками «Дни / Недели / Месяцы», клавишами `+` `−` `0` или Ctrl/⌘ + колесо (pinch на трекпаде).
3. Шапка показывает дни, недели или месяцы; дата в центре экрана остаётся на месте (при Ctrl + колесо — дата под курсором).
4. Если сегодняшний день ушёл за экран, в шапке появляется «← к сегодня» / «к сегодня →»; клик или пробел плавно возвращают к сегодня.
5. Клик по логотипу показывает весь план: наибольший масштаб, при котором все проекты помещаются по ширине и все строки — по высоте.
6. Масштаб, дата в центре и вертикальная прокрутка сохраняются и восстанавливаются при следующем визите.

## Alternate Flows / Exceptions

- `ALT-01` Проект целиком за краем экрана: у края — метка с его названием; клик переносит к ближнему краю проекта.
- `ALT-02` Проект частично виден: его название «прилипает» к левому краю экрана.
- `ALT-03` Кнопка «?» показывает все жесты и клавиши и версию Potee.
- `ALT-04` Высота строк меняется с масштабом (ярусы подписей вех) плавно, без скачка; при «уменьшении движения» в системе — без анимации.
- `EX-01` Сохранение вида не удалось: доска продолжает работать, вид просто не восстановится.

## Postconditions

- Вид доски сохранён на сервере (с задержкой 1 с и при уходе со страницы).

## Business Rules

- `BR-01` Масштаб от 4 до 200 px/день; > 30 — дни, > 15 — недели, иначе месяцы.
- `BR-02` При смене масштаба на месте остаётся дата в центре экрана (при Ctrl + колесо — дата под курсором).
- `BR-03` Лента покрывает все проекты и сегодняшний день плюс экран пустого времени с каждой стороны.
- `BR-04` Выходные отмечены только бледными датами в шапке (дни и недели); праздники — по региону аккаунта ([`UC-016`](UC-016-account-settings.md)).
- `BR-05` В «Месяцах» год подписан только у месяца другого года, один раз.

## Traceability

| Upstream / Downstream | References |
| --- | --- |
| PRD | [`PRD-001`](../prd/PRD-001-potee.md) |
| Features | `none` |
| Related use cases | [`UC-005`](UC-005-manage-project.md) (Целиком), [`UC-016`](UC-016-account-settings.md) |
| ADR | `none` |
| Runbooks / Ops | `none` |

## Downstream Behavior Coverage

Навигация: acceptance и проверки живут в тестах и feature `brief.md`.

| UC element | Downstream examples / checks | Coverage note |
| --- | --- | --- |
| Main flow 2–3, 6 | `e2e/board.spec.ts` › keyboard zoom is remembered; › shows the demo board in days zoom |  |
| Main flow 5 | `e2e/board.spec.ts` › the logo fits every project on one screen |  |
| `ALT-02` | `e2e/board.spec.ts` › project titles sit exactly on their bars and stick to the left edge |  |
| `ALT-03` | `e2e/board.spec.ts` › the help popover lists gestures and shortcuts and the version |  |
| `BR-01` | `spec/requests/api/dashboard_spec.rb`; `app/frontend/board/timeline.test.ts` |  |
| `BR-02`, `BR-03`, `BR-05` | `app/frontend/board/timeline.test.ts` | Чистая геометрия ленты |
| `BR-04` | `spec/services/work_calendar_spec.rb`, `spec/requests/settings_spec.rb` |  |
