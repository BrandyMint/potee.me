import { expect, test, type Page } from "@playwright/test";

// Runs against bin/dev started with PLAN_FROM_TEXT_ENABLED=1 LITELLM_URL=fake:
// the fake model always returns two projects, «Подготовка» and «Запуск».

async function signUp(page: Page) {
  await page.goto("/signup");
  await page.getByLabel("Email").fill(`plan-${Date.now()}-${Math.floor(Math.random() * 1e6)}@example.com`);
  await page.getByLabel(/Password/).fill("secret-password");
  await page.getByRole("button", { name: "Sign up" }).click();
  await expect(page).toHaveURL(/\/projects$/);
  await expect(page.locator(".project")).toHaveCount(3); // demo board
}

test("a registered user turns text into projects after a preview", async ({ page }) => {
  await signUp(page);
  const before = await page.locator(".project").count();

  await page.getByRole("button", { name: "Plan from text" }).click();
  const panel = page.getByRole("dialog", { name: "Plan from text" });
  await panel.getByRole("textbox").fill("Launching a course by December 1, webinars in November");
  await panel.getByRole("button", { name: "Make a plan" }).click();

  await expect(page.getByTestId("preview-Подготовка")).toBeVisible();
  await expect(page.getByTestId("preview-Запуск")).toBeVisible();
  await expect(page.locator(".project:not(.preview)")).toHaveCount(before);

  await panel.getByRole("checkbox").first().uncheck();
  await expect(page.getByTestId("preview-Подготовка")).toHaveClass(/excluded/);
  await panel.getByRole("button", { name: "Add 1 project" }).click();

  await expect(panel).toHaveCount(0);
  await expect(page.getByTestId("project-Запуск")).toBeVisible();
  await expect(page.getByTestId("project-Подготовка")).toHaveCount(0);

  await page.reload();
  await expect(page.getByTestId("project-Запуск")).toBeVisible();
  await expect(page.getByTestId("project-Запуск").locator(".event-title")).toHaveText(["19:00 Старт", "Итоги"]);
});

test("rewriting discards the preview and leaves the board unchanged", async ({ page }) => {
  await signUp(page);
  const before = await page.locator(".project").count();
  await page.getByRole("button", { name: "Plan from text" }).click();
  const panel = page.getByRole("dialog", { name: "Plan from text" });
  await panel.getByRole("textbox").fill("Some plan");
  await panel.getByRole("button", { name: "Make a plan" }).click();
  await expect(page.getByTestId("preview-Запуск")).toBeVisible();

  await panel.getByRole("button", { name: "Rewrite" }).click();
  await expect(page.locator(".project.preview")).toHaveCount(0);
  await expect(panel.getByRole("textbox")).toBeVisible();
  await page.keyboard.press("Escape");
  await expect(panel).toHaveCount(0);
  await expect(page.locator(".project")).toHaveCount(before);
});

test("an anonymous visitor is invited to sign up", async ({ page }) => {
  await page.goto("/projects");
  await page.getByRole("button", { name: "Plan from text" }).click();
  const panel = page.getByRole("dialog", { name: "Plan from text" });
  await expect(panel).toContainText("available after sign-up");
  await expect(panel.getByRole("link", { name: "Sign up" })).toHaveAttribute("href", "/signup");
});

test("a model error offers a retry", async ({ page }) => {
  await signUp(page);
  await page.route("**/api/plan_requests/*", (route) =>
    route.fulfill({ json: { id: 1, status: "failed", error: "llm_timeout" } }),
  );
  await page.getByRole("button", { name: "Plan from text" }).click();
  const panel = page.getByRole("dialog", { name: "Plan from text" });
  await panel.getByRole("textbox").fill("Some plan");
  await panel.getByRole("button", { name: "Make a plan" }).click();
  await expect(panel.getByRole("alert")).toHaveText("The model took too long. Try again.");
  await panel.getByRole("button", { name: "Try again" }).click();
  await expect(panel.getByRole("textbox")).toHaveValue("Some plan");
});
