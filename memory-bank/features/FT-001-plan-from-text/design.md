---
title: "FT-001: План из текста — design"
doc_kind: feature
doc_function: canonical
purpose: "Фиксирует выбранное решение фичи «План из текста»: модель, поток данных, контракт, промпт, отказы и выкладку."
derived_from:
  - brief.md
status: draft
audience: humans_and_agents
---

# FT-001: Design

## Context

Модель отвечает за 2–3 секунды, но при сбоях основной модели и fallback ответ
может занять до минуты, а его нужно проверить и показать до записи на доску.
Значит, нужен асинхронный жизненный цикл запроса, хранение черновика,
строгая схема ответа и нормализация — те же правила, что у MCP-инструментов
(`Mcp::Tools`), чтобы не завести два разных набора проверок.

## Model Selection

Две пробы 2026-10-02 с одним промптом и планом «курс к 1 декабря» (`SC-01`):
через private LiteLLM из пода `potee` и напрямую через OpenRouter (по два
запуска). «Даты» — сколько из 5 ключевых вех поставлено верно.

| Модель | Маршрут | Время | Полосы | Даты | ~Цена плана | Решение |
| --- | --- | --- | --- | --- | --- | --- |
| Claude Haiku 4.5 | OpenRouter (платный API) | 3 с | 4 | 5/5, 5/5 | $0,0027 | **основная** (`SOL-01`) |
| GPT-5.4 mini | OpenRouter (платный API) | 2,3 с | 3 | 5/5, 5/5 | $0,0011 | **резервная** (`SOL-01`) |
| Gemini 3.5 Flash Lite | OpenRouter | 2 с | 3 | 5/5, 4/5 | $0,0013 | нестабильные даты |
| Gemini 3.8 Flash | OpenRouter | 7 с / таймаут | 4 | 4/5 | $0,0049 | медленно, нестабильно |
| DeepSeek v4 Flash / Pro | OpenRouter, DeepSeek API | 20–60 с | 3–4 | 5/5 | < $0,001 | слишком медленно |
| Claude Haiku (подписка) | LiteLLM `claude-haiku-subscription` | 3,6 с | 1 | 5/5 | — | отклонена: `CON-02` |
| Qwen 3.8 | LiteLLM `neuraldeep-qwen3.8` | 58 с | 4 | 5/5 | — | слишком медленно |

- `SOL-01` Приложение вызывает алиас LiteLLM `potee-plan` (переменная
  `PLAN_MODEL`) → `openrouter/anthropic/claude-haiku-4.5`; при ошибке LiteLLM
  сам переключается на `potee-plan-fallback` → `openrouter/openai/gpt-5.4-mini`
  (`router_settings.fallbacks`). Алиасы добавлены в
  `infra/charts/litellm/templates/configmap.yaml` 2026-10-02. `temperature: 0.2`.
- `TRD-01` Цена (~$3 за тысячу планов) против скорости 3 с вместо 24–60 с:
  при синхронном ощущении ответа асинхронность остаётся только страховкой.

## Solution

### Data

- `SD-01` Таблица `plan_requests`:

| Column | Type | Meaning |
| --- | --- | --- |
| `user_id` | FK | Автор (только зарегистрированный) |
| `prompt` | text ≤ 2000 | Текст пользователя |
| `timezone` | string | IANA, из браузера; по умолчанию `Europe/Moscow` |
| `status` | enum | `pending` → `ready` / `failed` → `applied` / `discarded` |
| `model` | string | Алиас, которым выполнен запрос |
| `draft` | jsonb | Нормализованный план (`CTR-03`) |
| `raw_response` | text | Ответ модели как есть, для разбора качества |
| `error` | string | Код ошибки (`FM-*`) |
| `completed_at`, `applied_at` | datetime | Для `MET-01`, `MET-04` |

- `SD-02` Записи старше 30 дней удаляются задачей `rake potee:purge_plan_requests`
  (запуск вручную или будущим cron, `REQ-09`).

### Components

- `SOL-02` `PlanGenerator` (сервис): строит промпт, вызывает LiteLLM
  (OpenAI-compatible `POST /v1/chat/completions`), извлекает JSON, передаёт в
  нормализатор. Сетевой клиент — `Net::HTTP`, без новых гемов.
- `SOL-03` `PlanNormalizer` (чистый Ruby, unit-тесты): приводит ответ к схеме
  `CTR-03` по правилам `INV-01`–`INV-05`.
- `SOL-04` `GeneratePlanJob` (Active Job, адаптер `:async` в процессе Puma):
  `pending` → вызов → `ready`/`failed`. Фронтенд опрашивает статус через
  0,5 с, затем каждые 1,5 с. `ASM-02`: объёмы малые; при росте —
  Solid Queue без изменения контракта.
- `SOL-05` `PlanApplier`: в транзакции создаёт выбранные проекты и вехи через
  ту же логику, что `Mcp::Tools#create_project` (общий метод, вынесенный в
  `BoardWriter`), в конец доски, цвета по `next_color_index`.
- `SOL-06` Frontend: кнопка «✨ План из текста» в шапке и в пустом состоянии;
  модальное окно с полем, подсказкой о стороннем провайдере (`REQ-12`),
  индикатором прогресса; предпросмотр — полосы-черновики
  на ленте (стиль черновика из UC-003: пунктирная обводка) и список с
  галочками; «Добавить на доску» / «Отмена».

### Prompt

- `SOL-07` System prompt (английский, ответ на языке пользователя):
  роль — разложить план на 1–6 параллельных или последовательных потоков
  работ (не одна полоса на всё); вехи — только значимые моменты (созвоны,
  дедлайны, запуски), 2–4 слова; сегодня `{today}`, часовой пояс `{tz}`;
  относительные даты разрешать в календарные; если дата не указана, оценить
  разумно и не выходить за год от сегодня; ответ — только JSON по схеме
  `CTR-03`, без пояснений. Текст пользователя передаётся отдельным сообщением
  `user` и оборачивается разделителями «план пользователя: …» (`REQ-11`).
- `SOL-08` Ответ запрашивается с `response_format: {"type": "json_object"}`;
  если алиас его не поддерживает — извлекается первый JSON-объект из текста.

### Invariants (normalization)

- `INV-01` Даты — `YYYY-MM-DD`, время — `HH:MM` или `null` (→ 12:00); невалидные
  вехи отбрасываются, проект без валидных дат отбрасывается.
- `INV-02` `end_date < start_date` → даты меняются местами.
- `INV-03` Веха вне сроков → сроки проекта расширяются до неё (`NEG-03`),
  флаг `adjusted: true` показывается в предпросмотре.
- `INV-04` Ограничения: ≤ 6 проектов, ≤ 12 вех на проект, названия обрезаются
  до 255 символов, пустые названия → «Проект» / «Событие».
- `INV-05` Даты дальше 2 лет от сегодня отбрасываются как ошибка модели.
- `INV-06` Модель не получает инструментов и данных доски; применение на доску
  возможно только действием пользователя в предпросмотре (`REQ-11`, `NS-05`).

## Contracts

| ID | Operation | Direction | Purpose |
| --- | --- | --- | --- |
| `CTR-01` | `POST /api/plan_requests` `{prompt, timezone}` → `202 {id, status: "pending"}` | browser → app | Создать запрос (`REQ-10`, `REQ-13`) |
| `CTR-02` | `GET /api/plan_requests/:id` → `{id, status, draft?, error?}` | browser → app | Опрос статуса |
| `CTR-03` | `draft`: `{projects: [{key, title, start_date, end_date, adjusted, events: [{title, date, time}]}]}` | app → browser | Нормализованный план |
| `CTR-04` | `POST /api/plan_requests/:id/apply` `{project_keys: [...]}` → `201 {projects: [Card]}` | browser → app | Добавить выбранное; повторный вызов → `409` (идемпотентность по статусу `applied`) |
| `CTR-05` | `POST /api/plan_requests/:id/discard` → `204` | browser → app | Отмена |
| `CTR-06` | `POST {LITELLM_URL}/v1/chat/completions` (`model`, `messages`, `temperature`, `response_format`) | app → LiteLLM | Генерация; таймаут чтения 60 с, без повторов (повтор — новым запросом пользователя) |

Ошибки `CTR-01`: `401/403` аноним (`NEG-01`), `422` длина (`NEG-07`),
`429 {error: "daily_limit" | "in_progress"}` (`NEG-05`). Все `CTR-01..05`
доступны только владельцу запроса (`404` для чужих).

## Failure Modes

| ID | Condition | Behaviour | Status / error |
| --- | --- | --- | --- |
| `FM-01` | LiteLLM недоступен / 5xx | Ошибка, предложить повторить | `failed` / `llm_unavailable` |
| `FM-02` | Таймаут 60 с | То же | `failed` / `llm_timeout` |
| `FM-03` | Невалидный JSON / пустой план после нормализации | «Не получилось разобрать план, опишите иначе» | `failed` / `unparseable` |
| `FM-04` | Процесс перезапущен во время генерации (выкладка) | Запросы `pending` старше 3 мин при опросе помечаются `failed` / `interrupted` | `failed` |
| `FM-05` | Пользователь закрыл страницу | Черновик остаётся `ready`; при следующем открытии окна предлагается последний неприменённый план | — |

## Observability

- `RB-01` Лог на каждый вызов модели: `plan_request_id`, `model`, длительность,
  статус, размер ответа — без текста пользователя.
- `RB-02` Метрики `MET-01`–`MET-04` считаются запросами к `plan_requests`;
  попадут в будущий отчёт по метрикам в админке (roadmap шаг 3). В Administrate
  — раздел `Plan Requests` (только чтение).

## Rollout

- `RB-03` Переменные: `PLAN_FROM_TEXT_ENABLED=1`, `PLAN_MODEL=potee-plan`,
  `LITELLM_URL=http://litellm.litellm.svc.cluster.local:4000` в
  `values/goga-office/potee.yaml.gotmpl`. Ключ не нужен: private LiteLLM
  принимает запросы из кластера (проверено пробой). Потребителя `potee`
  добавить в таблицу consumers в `infra/docs/runbooks/litellm.md`.
- `RB-04` Порядок: миграция и код за выключенным флагом → прогон `EVAL-01`
  против реальной модели → включение флага → наблюдение `FM-*` и `MET-04` неделю.
- `RB-05` Откат: `PLAN_FROM_TEXT_ENABLED=0` скрывает кнопку и закрывает
  `CTR-01`; уже добавленные проекты остаются обычными.

## Evaluation Set

`EVAL-01` — 10 планов в `config/evals/plan_eval.yml` (ввод + ожидаемые даты
ключевых вех): запуск курса, переезд, ремонт, отпуск с визой, найм, выпуск
релиза, свадьба, подготовка к экзамену, план на квартал, английский текст.
Скрипт `bin/plan-eval` печатает план и отклонения дат; критерий — `REQ-08`.

## Coverage

| Scenario | Logical | Process | Development | Verification |
| --- | --- | --- | --- | --- |
| `SC-01` | `REQ-01`, `REQ-05` | `CTR-01..03`, `SOL-04` | `SOL-02`, `SOL-03` | `CHK-03`, `CHK-04` |
| `SC-02` | `REQ-03`, `REQ-04` | `CTR-04` | `SOL-05`, `SOL-06` | `CHK-03`, `CHK-01` |
| `NEG-02`, `NEG-03` | `REQ-06` | `FM-03`, `INV-01..05` | `SOL-03` | `CHK-02` |
| `NEG-04` | `REQ-07` | `FM-01`, `FM-02`, `CTR-06` | `SOL-02` | `CHK-03` |
| `NEG-05` | `REQ-13` | `CTR-01` | — | `CHK-01` |
| `NEG-06` | `REQ-11` | `INV-06`, `SOL-07` | `SOL-02` | `CHK-02` |
