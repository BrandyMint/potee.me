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
  await page.getByRole("button", { name: "New project", exact: true }).click();
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

test("a deleted project can be restored with Undo", async ({ page }) => {
  await row(page, "Learn Scala").locator(".project-title-text").click();
  await page.getByRole("button", { name: "Delete" }).click();
  await expect(row(page, "Learn Scala")).toHaveCount(0);
  await page.getByRole("button", { name: "Undo" }).click();
  expect(await rowTitles(page)).toEqual(["Learn Scala", "Make my wife happy", "Start my own business"]);

  await page.waitForTimeout(5500);
  await page.reload();
  expect(await rowTitles(page)).toEqual(["Learn Scala", "Make my wife happy", "Start my own business"]);
});

test("an empty board explains how to start", async ({ page }) => {
  for (const title of ["Learn Scala", "Make my wife happy", "Start my own business"]) {
    await row(page, title).locator(".project-title-text").click();
    await page.getByRole("button", { name: "Delete" }).click();
  }
  await expect(page.getByRole("heading", { name: "Your board is empty" })).toBeVisible();
  await page.locator(".empty-state").getByRole("button", { name: "New project" }).click();
  await expect(page.getByLabel("Project title")).toBeFocused();
  await expect(page.locator(".empty-state")).toHaveCount(0);
});

test("the help popover lists gestures and shortcuts", async ({ page }) => {
  await page.getByRole("button", { name: "Help" }).click();
  await expect(page.getByRole("dialog", { name: "How to use Potee" })).toContainText("Double-click a project");
  await page.keyboard.press("Escape");
  await expect(page.getByRole("dialog")).toHaveCount(0);
});

test("rows are centred vertically when they fit", async ({ page }) => {
  const viewport = (await page.getByTestId("viewport").boundingBox())!;
  const first = (await row(page, "Learn Scala").boundingBox())!;
  const last = (await row(page, "Start my own business").boundingBox())!;
  const middle = (first.y + last.y + last.height) / 2;
  expect(Math.abs(middle - (viewport.y + 56 + (viewport.height - 56) / 2))).toBeLessThan(40);
});

test.describe("in Russian", () => {
  test.use({ locale: "ru-RU" });

  test("the board, dates and samples are in Russian", async ({ page }) => {
    await expect(page.getByRole("button", { name: "Дни" })).toHaveClass(/active/);
    await expect(page.getByTestId("project-Запуск сайта")).toBeVisible();
    await expect(page.locator(".header-cell.current .header-subtitle")).toHaveText(/^(пн|вт|ср|чт|пт|сб|вс)$/);
  });
});

test.describe("on a phone", () => {
  test.use({ viewport: { width: 390, height: 844 }, hasTouch: true, isMobile: true });

  test("the header fits without overlaps and the panel opens at the bottom", async ({ page }) => {
    const header = (await page.locator(".board-header").boundingBox())!;
    const children = await page.locator(".board-header > *:visible").all();
    const boxes = (await Promise.all(children.map((child) => child.boundingBox()))).filter((box) => box && box.width > 0);
    for (const box of boxes) expect(box!.x + box!.width).toBeLessThanOrEqual(header.x + header.width + 1);
    for (let i = 1; i < boxes.length; i++) expect(boxes[i]!.x).toBeGreaterThanOrEqual(boxes[i - 1]!.x + boxes[i - 1]!.width - 1);

    await row(page, "Learn Scala").locator(".project-title-text").click();
    const panel = (await page.locator(".project-panel").boundingBox())!;
    expect(panel.y + panel.height).toBeGreaterThan(800);
  });
});

test("the logo fits every project on one screen", async ({ page }) => {
  await page.getByRole("button", { name: "weeks" }).click();
  await page.getByRole("button", { name: "Show all projects" }).click();
  await expect(async () => {
    const viewport = (await page.getByTestId("viewport").boundingBox())!;
    for (const title of ["Learn Scala", "Make my wife happy", "Start my own business"]) {
      const box = (await bar(page, title).boundingBox())!;
      expect(box.x).toBeGreaterThanOrEqual(viewport.x);
      expect(box.x + box.width).toBeLessThanOrEqual(viewport.x + viewport.width);
      expect(box.y + box.height).toBeLessThanOrEqual(viewport.y + viewport.height);
    }
  }).toPass();
  // The largest zoom that fits: days mode for a two-week board.
  await expect(page.getByRole("button", { name: "days" })).toHaveClass(/active/);
});

test("labels of close events go to separate tiers instead of overlapping", async ({ page }) => {
  const scala = row(page, "Learn Scala");
  const heightBefore = (await scala.boundingBox())!.height;
  const tick = (await scala.locator(".event", { hasText: "Buy a book" }).locator(".event-bar").boundingBox())!;
  const created = apiCall(page, "POST", /^\/api\/projects\/\d+\/events$/);
  await page.mouse.dblclick(tick.x + 25, tick.y + tick.height / 2);
  await created;

  const labels = scala.locator(".event-title");
  await expect(labels).toHaveCount(4);
  const boxes = (await Promise.all((await labels.all()).map((label) => label.boundingBox()))).map((box) => box!);
  for (let i = 0; i < boxes.length; i++) {
    for (let j = i + 1; j < boxes.length; j++) {
      const [a, b] = [boxes[i]!, boxes[j]!];
      const overlap = a.x < b.x + b.width && b.x < a.x + a.width && a.y < b.y + b.height && b.y < a.y + a.height;
      expect(overlap).toBe(false);
    }
  }
  expect((await scala.boundingBox())!.height).toBeGreaterThan(heightBefore);
  await expect(scala.locator(".event-connector")).toHaveCount(1);
});

test("project titles sit exactly on their bars and stick to the left edge", async ({ page }) => {
  const title = row(page, "Start my own business").locator(".project-title");
  const barBox = (await bar(page, "Start my own business").boundingBox())!;
  const titleBox = (await title.boundingBox())!;
  expect(Math.abs(titleBox.y - barBox.y)).toBeLessThan(0.5);
  expect(Math.abs(titleBox.y + titleBox.height - (barBox.y + barBox.height))).toBeLessThan(0.5);

  // Scroll so the project starts off screen: the title stays at the viewport's left edge.
  const viewport = page.getByTestId("viewport");
  await viewport.evaluate((element, shift) => element.scrollBy(shift, 0), barBox.x + 400);
  await expect(async () => {
    const box = (await title.boundingBox())!;
    const viewportBox = (await viewport.boundingBox())!;
    expect(Math.abs(box.x - viewportBox.x)).toBeLessThan(2);
  }).toPass();
});
