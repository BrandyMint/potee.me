import { expect, test, type Page } from "@playwright/test";

const row = (page: Page, title: string) => page.getByTestId(`project-${title}`);
const bar = (page: Page, title: string) => row(page, title).locator(".project-bar");

const apiCall = (page: Page, method: string, path: string | RegExp) =>
  page.waitForResponse(
    (response) =>
      response.request().method() === method &&
      (typeof path === "string" ? new URL(response.url()).pathname === path : path.test(new URL(response.url()).pathname)),
  );

async function rowTitles(page: Page): Promise<string[]> {
  return page.locator(".project .project-title-text").allTextContents();
}

/** Drags with real mouse moves so pointer events fire step by step. */
async function drag(page: Page, from: { x: number; y: number }, by: { x: number; y: number }) {
  await page.mouse.move(from.x, from.y);
  await page.mouse.down();
  await page.mouse.move(from.x + by.x / 2, from.y + by.y / 2, { steps: 5 });
  await page.mouse.move(from.x + by.x, from.y + by.y, { steps: 5 });
  await page.mouse.up();
}

async function center(selector: ReturnType<Page["locator"]>) {
  const box = await selector.boundingBox();
  if (!box) throw new Error("Element is not visible");
  return { x: box.x + box.width / 2, y: box.y + box.height / 2, box };
}

test.beforeEach(async ({ page }) => {
  await page.goto("/projects");
  await expect(page.locator(".project")).toHaveCount(3);
});

test("shows the demo board in days zoom", async ({ page }) => {
  expect(await rowTitles(page)).toEqual(["Learn Scala", "Make my wife happy", "Start my own business"]);
  await expect(page.getByRole("button", { name: "days" })).toHaveClass(/active/);
  await expect(page.locator(".header-cell.current")).toBeInViewport();
});

test("creates a project from the header button", async ({ page }) => {
  await page.getByRole("button", { name: "+ New project" }).click();
  await page.getByLabel("Project title").fill("Write tests");
  const created = apiCall(page, "POST", "/api/projects");
  await page.getByLabel("Project title").press("Enter");
  expect((await created).status()).toBe(201);
  await apiCall(page, "PATCH", "/api/projects/reorder");

  await page.reload();
  expect(await rowTitles(page)).toEqual(["Write tests", "Learn Scala", "Make my wife happy", "Start my own business"]);
});

test("double click on empty space starts a project there, Escape cancels it", async ({ page }) => {
  const viewport = page.getByTestId("viewport");
  const box = await viewport.boundingBox();
  if (!box) throw new Error("no viewport");
  await page.mouse.dblclick(box.x + 300, box.y + box.height - 60);
  await expect(page.getByLabel("Project title")).toBeFocused();
  await expect(page.locator(".project")).toHaveCount(4);

  await page.keyboard.press("Escape");
  await expect(page.locator(".project")).toHaveCount(3);
});

test("selecting a project opens its panel: rename and recolour", async ({ page }) => {
  await row(page, "Learn Scala").locator(".project-title-text").click();
  const title = page.getByLabel("Selected project title");
  await expect(title).toHaveValue("Learn Scala");
  await expect(row(page, "Make my wife happy")).toHaveClass(/inactive/);

  await title.fill("Learn Rust");
  const renamed = apiCall(page, "PATCH", /^\/api\/projects\/\d+$/);
  await title.press("Enter");
  await renamed;
  await expect(row(page, "Learn Rust")).toHaveClass(/project-color-1/);

  const recoloured = apiCall(page, "PATCH", /^\/api\/projects\/\d+$/);
  await page.getByRole("button", { name: "Change colour" }).click();
  await recoloured;
  await expect(row(page, "Learn Rust")).toHaveClass(/project-color-2/);

  await page.reload();
  await expect(row(page, "Learn Rust")).toHaveClass(/project-color-2/);
});

test("double click on a project adds an event, which can be renamed", async ({ page }) => {
  const events = row(page, "Learn Scala").locator(".event");
  await expect(events).toHaveCount(3);
  const { box } = await center(bar(page, "Learn Scala"));
  const created = apiCall(page, "POST", /^\/api\/projects\/\d+\/events$/);
  await page.mouse.dblclick(box.x + 60, box.y + box.height / 2);
  expect((await created).status()).toBe(201);
  await expect(events).toHaveCount(4);

  const added = row(page, "Learn Scala").locator(".event-title", { hasText: "Some event" });
  await added.click();
  const input = page.getByLabel("Event title");
  await input.fill("Kick-off");
  const renamed = apiCall(page, "PATCH", /^\/api\/events\/\d+$/);
  await input.press("Enter");
  await renamed;

  await page.reload();
  await expect(row(page, "Learn Scala").locator(".event-title", { hasText: "Kick-off" })).toHaveCount(1);
});

test("dragging an event moves it in time", async ({ page }) => {
  const marker = row(page, "Make my wife happy").locator(".event", { hasText: "Buy a present" });
  const before = await marker.evaluate((element) => parseFloat((element as HTMLElement).style.left));
  const point = await center(marker.locator(".event-bar"));
  const saved = apiCall(page, "PATCH", /^\/api\/events\/\d+$/);
  await drag(page, point, { x: 150, y: 0 });
  const body = (await saved).request().postDataJSON() as { event: { at: string } };
  expect(body.event.at).toBeTruthy();

  await page.reload();
  const after = await row(page, "Make my wife happy")
    .locator(".event", { hasText: "Buy a present" })
    .evaluate((element) => parseFloat((element as HTMLElement).style.left));
  expect(Math.round(after - before)).toBe(150);
});

test("resizing a project changes its dates", async ({ page }) => {
  await page.getByRole("button", { name: "weeks" }).click();
  const handle = row(page, "Make my wife happy").locator(".resize-handle.start");
  const before = (await bar(page, "Make my wife happy").boundingBox())!;
  const saved = apiCall(page, "PATCH", /^\/api\/projects\/\d+$/);
  await drag(page, await center(handle), { x: -40, y: 0 });
  const body = (await saved).request().postDataJSON() as { project: { started_on: string } };
  expect(body.project.started_on).toMatch(/^\d{4}-\d{2}-\d{2}$/);
  const after = (await bar(page, "Make my wife happy").boundingBox())!;
  expect(Math.round(after.width - before.width)).toBe(40);
});

test("dragging a title reorders the projects", async ({ page }) => {
  const title = row(page, "Start my own business").locator(".project-title-text");
  const saved = apiCall(page, "PATCH", "/api/projects/reorder");
  await drag(page, await center(title), { x: 0, y: -160 });
  await saved;
  expect(await rowTitles(page)).toEqual(["Start my own business", "Learn Scala", "Make my wife happy"]);

  await page.reload();
  expect(await rowTitles(page)).toEqual(["Start my own business", "Learn Scala", "Make my wife happy"]);
});

test("deletes a project", async ({ page }) => {
  await row(page, "Make my wife happy").locator(".project-title-text").click();
  page.once("dialog", (dialog) => void dialog.accept());
  const deleted = apiCall(page, "DELETE", /^\/api\/projects\/\d+$/);
  await page.getByRole("button", { name: "Delete" }).click();
  expect((await deleted).status()).toBe(204);
  await page.reload();
  expect(await rowTitles(page)).toEqual(["Learn Scala", "Start my own business"]);
});

test("keyboard zoom is remembered", async ({ page }) => {
  const saved = apiCall(page, "PATCH", "/api/dashboard");
  await page.keyboard.press("0");
  await expect(page.getByRole("button", { name: "months" })).toHaveClass(/active/);
  await saved;
  await page.reload();
  await expect(page.getByRole("button", { name: "months" })).toHaveClass(/active/);
});

test("Entire fits the selected project into the screen", async ({ page }) => {
  await row(page, "Start my own business").locator(".project-title-text").click();
  await page.getByRole("button", { name: "Entire" }).click();
  await expect(page.getByRole("button", { name: "days" })).toHaveClass(/active/);
  await expect(async () => {
    const box = (await bar(page, "Start my own business").boundingBox())!;
    expect(box.x).toBeGreaterThanOrEqual(0);
    expect(box.x + box.width).toBeLessThanOrEqual(1400);
    expect(box.width).toBeGreaterThan(1100);
  }).toPass();
});

test("a share link adds the project to another visitor's board", async ({ page, browser }) => {
  const board = (await (await page.request.get("/api/board")).json()) as { projects: { title: string; share_url: string }[] };
  const shareUrl = board.projects.find((project) => project.title === "Learn Scala")!.share_url;

  const visitor = await browser.newContext();
  const visitorPage = await visitor.newPage();
  await visitorPage.goto(new URL(shareUrl).pathname);
  await expect(visitorPage).toHaveURL(/\/projects$/);
  await expect(visitorPage.locator(".project")).toHaveCount(4);
  await expect(visitorPage.getByLabel("Selected project title")).toHaveValue("Learn Scala");
  await visitor.close();
});
