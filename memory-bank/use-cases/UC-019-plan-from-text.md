---
title: "UC-019: План из текста"
doc_kind: use_case
doc_function: canonical
purpose: "Фиксирует создание проектов с вехами из описания плана обычным текстом."
derived_from:
  - ../product/context.md
  - ../prd/PRD-001-potee.md
  - ../features/FT-001-plan-from-text/brief.md
status: active
audience: humans_and_agents
must_not_define:
  - implementation_sequence
  - architecture_decision
  - feature_level_test_matrix
  - bdd_example_inventory
---

# UC-019: План из текста

## Goal

Пользователь без своего агента получает проекты с вехами из описания плана обычными словами.

## Primary Actor

Пользователь.

## Trigger

Клик «План из текста» в шапке.

## Preconditions

- Функция включена.
- Пользователь зарегистрирован.

## Main Flow

1. Пользователь нажимает «План из текста» — окно по центру поверх размытой доски, с пометкой, что текст обрабатывает сторонняя языковая модель, а доска не передаётся.
2. Описывает план и нажимает «Составить план» — сразу виден прогресс.
3. Предпросмотр: проекты нарисованы на ленте с пунктирной обводкой, сбоку — список с датами и галочками; расширенные до вех сроки помечены.
4. Пользователь снимает лишние галочки и нажимает «Добавить N проектов» — проекты встают в конец доски, доска показывает их целиком.

## Alternate Flows / Exceptions

- `ALT-01` «Переписать» — предпросмотр отбрасывается, доска не меняется.
- `ALT-02` Анонимный посетитель видит приглашение зарегистрироваться; запрос не отправляется.
- `EX-01` Модель недоступна, ответ не разобран или не уложился в 60 с — сообщение и «Попробовать снова»; ничего не добавлено.
- `EX-02` Дневной лимит или уже идущий запрос — понятное сообщение, запрос не отправляется.
- `EX-03` Пустой текст или длиннее 2000 символов — запрос не отправляется.

## Postconditions

- Добавленные проекты — обычные проекты пользователя; запрос и итог хранятся для разбора качества.

## Business Rules

- `BR-01` Только для зарегистрированных; 20 запросов в сутки и один одновременно.
- `BR-02` Текст передаётся модели только как данные; модель не может изменить доску напрямую.
- `BR-03` Черновик проходит те же проверки, что MCP: даты корректны, вехи внутри сроков (сроки расширяются до вех), негодное отбрасывается.

## Traceability

| Upstream / Downstream | References |
| --- | --- |
| PRD | [`PRD-001`](../prd/PRD-001-potee.md) |
| Features | [`FT-001`](../features/FT-001-plan-from-text/README.md) |
| Related use cases | [`UC-003`](UC-003-create-project.md), [`UC-018`](UC-018-agent-manages-board.md) |
| ADR | `none` |
| Runbooks / Ops | `none` |

## Downstream Behavior Coverage

Навигация: acceptance и проверки живут в тестах и feature `brief.md`.

| UC element | Downstream examples / checks | Coverage note |
| --- | --- | --- |
| Main flow | `FT-001/SC-01`, `FT-001/SC-02`; `e2e/plan.spec.ts` › a registered user turns text into projects after a preview |  |
| `ALT-01` | `FT-001/SC-03`; `e2e/plan.spec.ts` › rewriting discards the preview… |  |
| `ALT-02` | `FT-001/NEG-01`; `e2e/plan.spec.ts` › an anonymous visitor is invited to sign up |  |
| `EX-01` | `FT-001/NEG-02`, `FT-001/NEG-04`; `e2e/plan.spec.ts` › a model error offers a retry |  |
| `EX-02`, `EX-03`, `BR-01` | `FT-001/NEG-05`, `FT-001/NEG-07`; `spec/requests/api/plan_requests_spec.rb` |  |
| `BR-02`, `BR-03` | `FT-001/NEG-03`, `FT-001/NEG-06`; `spec/services/plan_normalizer_spec.rb`, `spec/services/plan_generator_spec.rb` |  |
