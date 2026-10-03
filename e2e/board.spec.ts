import { expect, test, type Page } from "@playwright/test";

const row = (page: Page, title: string) => page.getByTestId(`project-${title}`);
const projectPanel = (page: Page) => page.getByRole("region", { name: "Project panel" });

/** First click selects a project, the second opens its panel (not a double click: that renames). */
async function openProject(page: Page, title: string) {
  const name = row(page, title).locator(".project-title-text");
  await name.click();
  await page.waitForTimeout(600);
  await name.click();
  await expect(projectPanel(page)).toBeVisible();
}

/** Selects a project and opens the details of its panel (dates, milestones). */
async function openDetails(page: Page, title: string) {
  await openProject(page, title);
  const panel = projectPanel(page);
  await panel.getByRole("button", { name: "Details: dates and milestones" }).click();
  return panel;
}
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

// A new visitor opens on the whole plan; these tests start from a saved view
// in the days zoom with today in the middle, like a returning visitor.
test.beforeEach(async ({ page, locale }) => {
  // Through the API, before the board first opens in the browser: otherwise
  // the whole-plan view of a new visitor would be saved over it on reload.
  const language = { "Accept-Language": locale ?? "en-US" };
  const html = await (await page.request.get("/projects", { headers: language })).text();
  const csrf = html.match(/name="csrf-token" content="([^"]+)"/)![1]!;
  const saved = await page.request.patch("/api/dashboard", {
    headers: { ...language, "X-CSRF-Token": csrf },
    data: { dashboard: { pixels_per_day: 150, current_date: new Date().toISOString(), scroll_top: 0 } },
  });
  expect(saved.ok()).toBe(true);
  await page.goto("/projects");
  await expect(page.locator(".project")).toHaveCount(3);
});

test("a new visitor opens on the whole plan", async ({ browser }) => {
  const visitor = await browser.newContext({ locale: "en-US" });
  const page = await visitor.newPage();
  await page.goto("/projects");
  await expect(page.locator(".project")).toHaveCount(3);
  const viewport = (await page.getByTestId("viewport").boundingBox())!;
  for (const title of ["Learn Scala", "Make my wife happy", "Start my own business"]) {
    const box = (await bar(page, title).boundingBox())!;
    expect(box.x).toBeGreaterThanOrEqual(viewport.x);
    expect(box.x + box.width).toBeLessThanOrEqual(viewport.x + viewport.width);
  }
  await visitor.close();
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

test("selecting a project opens its panel: rename in the bar and recolour", async ({ page }) => {
  await openProject(page, "Learn Scala");
  await expect(projectPanel(page).getByRole("toolbar", { name: "Learn Scala" })).toBeVisible();
  await projectPanel(page).getByRole("button", { name: "Rename" }).click();
  const title = row(page, "Learn Scala").getByLabel("Project title");
  await expect(title).toBeFocused();
  await expect(title).toHaveValue("Learn Scala");
  await expect(row(page, "Make my wife happy")).toHaveClass(/inactive/);

  await title.fill("Learn Rust");
  const renamed = apiCall(page, "PATCH", /^\/api\/projects\/\d+$/);
  await title.press("Enter");
  await renamed;
  await expect(row(page, "Learn Rust")).toHaveClass(/project-color-1/);

  const recoloured = apiCall(page, "PATCH", /^\/api\/projects\/\d+$/);
  await projectPanel(page).getByRole("button", { name: "Details: dates and milestones" }).click();
  await page.getByRole("button", { name: "Colour 3" }).click();
  await recoloured;
  await expect(row(page, "Learn Rust")).toHaveClass(/project-color-2/);

  await page.reload();
  await expect(row(page, "Learn Rust")).toHaveClass(/project-color-2/);
});

test("clicks on a project: select, open the panel, rename; a double click on the title renames", async ({ page }) => {
  const title = row(page, "Learn Scala").locator(".project-title-text");
  await title.click();
  await expect(row(page, "Learn Scala")).not.toHaveClass(/inactive/);
  await expect(projectPanel(page)).toHaveCount(0);
  await page.waitForTimeout(600);
  await title.click();
  await expect(projectPanel(page)).toBeVisible();
  await page.waitForTimeout(600);
  await title.click();
  await expect(row(page, "Learn Scala").getByLabel("Project title")).toBeFocused();
  await page.keyboard.press("Escape");
  await expect(row(page, "Learn Scala").locator(".project-title-text")).toBeVisible();

  const events = await row(page, "Make my wife happy").locator(".event").count();
  await row(page, "Make my wife happy").locator(".project-title-text").dblclick();
  await expect(row(page, "Make my wife happy").getByLabel("Project title")).toBeFocused();
  await expect(row(page, "Make my wife happy").locator(".event")).toHaveCount(events);
});


test("a double click adds a milestone even on the active project and opens no panel", async ({ page }) => {
  const events = row(page, "Learn Scala").locator(".event");
  const count = await events.count();
  await row(page, "Learn Scala").locator(".project-title-text").click();
  await page.waitForTimeout(600);
  const { box } = await center(bar(page, "Learn Scala"));
  await page.mouse.dblclick(box.x + 140, box.y + box.height / 2);
  await expect(events).toHaveCount(count + 1);
  await page.waitForTimeout(600);
  await expect(projectPanel(page)).toHaveCount(0);
});

test("renaming in the bar looks like a new project", async ({ page }) => {
  const scala = row(page, "Learn Scala");
  const events = await scala.locator(".event").count();
  await openProject(page, "Learn Scala");
  await page.waitForTimeout(600);
  await scala.locator(".project-title-text").click();

  await expect(scala.getByLabel("Project title")).toBeFocused();
  await expect(scala).toHaveClass(/renaming/);
  await expect(scala.locator(".draft-hint")).toBeVisible();
  await expect(scala.locator(".event").first()).toBeHidden();
  await expect(projectPanel(page)).toHaveCount(0);
  await page.keyboard.press("Escape");
  await expect(scala.locator(".event")).toHaveCount(events);
  await expect(projectPanel(page)).toBeVisible();
});


test("an expanded panel never covers its bar", async ({ page }) => {
  await page.setViewportSize({ width: 1280, height: 520 });
  const panel = await openDetails(page, "Learn Scala");
  for (let i = 0; i < 6; i++) await panel.getByRole("button", { name: /add/ }).click();
  await expect(async () => {
    const barBox = (await bar(page, "Learn Scala").boundingBox())!;
    const panelBox = (await panel.boundingBox())!;
    const overlaps = panelBox.y < barBox.y + barBox.height && panelBox.y + panelBox.height > barBox.y;
    expect(overlaps).toBe(false);
  }).toPass();
});

test("the project panel sits under the selected bar", async ({ page }) => {
  await openProject(page, "Learn Scala");
  const panel = projectPanel(page);
  await expect(panel).toBeVisible();
  await expect(async () => {
    const barBox = (await bar(page, "Learn Scala").boundingBox())!;
    const panelBox = (await panel.boundingBox())!;
    expect(panelBox.y).toBeGreaterThan(barBox.y + barBox.height);
    expect(panelBox.y).toBeLessThan(barBox.y + barBox.height + 40);
  }).toPass();
  await expect(page.locator(".board-header").getByRole("button", { name: "Entire" })).toHaveCount(0);
});

test("the expanded panel lists milestones, adds one and changes dates", async ({ page }) => {
  const card = await openDetails(page, "Learn Scala");
  await expect(card.getByRole("listitem")).toHaveCount(3);

  const created = apiCall(page, "POST", /^\/api\/projects\/\d+\/events$/);
  await card.getByRole("button", { name: "+ add" }).click();
  expect((await created).status()).toBe(201);
  await expect(card.getByRole("listitem")).toHaveCount(4);
  await expect(row(page, "Learn Scala").locator(".event")).toHaveCount(4);

  const finish = card.getByLabel("Finish date");
  const next = await finish.inputValue().then((day) => {
    const date = new Date(`${day}T00:00:00`);
    date.setDate(date.getDate() + 7);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
  });
  const moved = apiCall(page, "PATCH", /^\/api\/projects\/\d+$/);
  await finish.fill(next);
  await moved;
  await page.reload();
  await openProject(page, "Learn Scala");
  // The panel remembers that it was expanded.
  await expect(projectPanel(page).getByLabel("Finish date")).toHaveValue(next);
});

test("milestones in the panel move to another day and are deleted on hover", async ({ page }) => {
  const card = await openDetails(page, "Learn Scala");
  const first = card.getByRole("listitem").first();
  const title = await first.locator(".milestone-title").innerText();

  const day = await first.getByLabel("Milestone date").inputValue();
  const date = new Date(`${day}T00:00:00`);
  date.setDate(date.getDate() + 1);
  const next = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
  const moved = apiCall(page, "PATCH", /^\/api\/events\/\d+$/);
  await first.getByLabel("Milestone date").fill(next);
  await moved;
  await expect(card.getByRole("listitem").filter({ hasText: title }).getByLabel("Milestone date")).toHaveValue(next);

  const item = card.getByRole("listitem").filter({ hasText: title });
  await item.hover();
  await item.getByRole("button", { name: `Delete “${title}”` }).click();
  await expect(card.getByRole("listitem")).toHaveCount(2);
  await page.getByRole("button", { name: "Undo" }).click();
  await expect(card.getByRole("listitem")).toHaveCount(3);
});

test("dragging a milestone in the panel changes the order of steps, dates stay", async ({ page }) => {
  const card = await openDetails(page, "Learn Scala");
  const items = card.getByRole("listitem");
  const titles = () => items.locator(".milestone-title").allInnerTexts();
  const dates = () => items.locator(".milestone-date").allInnerTexts();
  const [before, days] = [await titles(), await dates()];

  const last = items.last();
  await last.hover();
  const handle = (await last.locator(".milestone-handle").boundingBox())!;
  const top = (await items.first().boundingBox())!;
  const saved = apiCall(page, "PATCH", /^\/api\/events\/\d+$/);
  await page.mouse.move(handle.x + handle.width / 2, handle.y + handle.height / 2);
  await page.mouse.down();
  await page.mouse.move(handle.x + handle.width / 2, top.y + 4, { steps: 8 });
  await page.mouse.up();
  await saved;

  await expect.poll(titles).toEqual([before[2], before[0], before[1]]);
  expect(await dates()).toEqual(days);
  await page.reload();
  await openProject(page, "Learn Scala");
  await expect.poll(titles).toEqual([before[2], before[0], before[1]]);
});

test("the panel copies the share link", async ({ page, context }) => {
  await context.grantPermissions(["clipboard-read", "clipboard-write"]);
  await openProject(page, "Learn Scala");
  const card = projectPanel(page);
  await card.getByRole("button", { name: "Share" }).click();
  await expect(card.getByRole("button", { name: "✓ Link copied" })).toBeVisible();
  expect(await page.evaluate(() => navigator.clipboard.readText())).toMatch(/\/share\/\w+$/);
});

test("double click on a project adds an event, which can be renamed", async ({ page }) => {
  const events = row(page, "Learn Scala").locator(".event");
  await expect(events).toHaveCount(3);
  const { box } = await center(bar(page, "Learn Scala"));
  const created = apiCall(page, "POST", /^\/api\/projects\/\d+\/events$/);
  // Past the title: a double click on the title renames the project instead.
  await page.mouse.dblclick(box.x + 140, box.y + box.height / 2);
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
  await openProject(page, "Make my wife happy");
  const deleted = apiCall(page, "DELETE", /^\/api\/projects\/\d+$/);
  await page.getByRole("button", { name: "Delete", exact: true }).click();
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
  await openProject(page, "Start my own business");
  await projectPanel(page).getByRole("button", { name: "Details: dates and milestones" }).click();
  await page.getByRole("button", { name: "Entire" }).click();
  await expect(page.getByRole("button", { name: "days" })).toHaveClass(/active/);
  await expect(async () => {
    const viewport = (await page.getByTestId("viewport").boundingBox())!;
    const box = (await bar(page, "Start my own business").boundingBox())!;
    expect(box.x).toBeGreaterThanOrEqual(viewport.x);
    expect(box.x + box.width).toBeLessThanOrEqual(viewport.x + viewport.width);
    expect(box.width).toBeGreaterThan(viewport.width * 0.75);
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
  // The shared project is selected; the visitor's own sample with the same title is not.
  await expect(visitorPage.locator('[data-testid="project-Learn Scala"]:not(.inactive)')).toHaveCount(1);
  await expect(row(visitorPage, "Make my wife happy")).toHaveClass(/inactive/);
  await visitor.close();
});

test("a deleted project can be restored with Undo", async ({ page }) => {
  await openProject(page, "Learn Scala");
  await page.getByRole("button", { name: "Delete", exact: true }).click();
  await expect(row(page, "Learn Scala")).toHaveCount(0);
  await page.getByRole("button", { name: "Undo" }).click();
  expect(await rowTitles(page)).toEqual(["Learn Scala", "Make my wife happy", "Start my own business"]);

  await page.waitForTimeout(5500);
  await page.reload();
  expect(await rowTitles(page)).toEqual(["Learn Scala", "Make my wife happy", "Start my own business"]);
});

test("an empty board explains how to start", async ({ page }) => {
  for (const title of ["Learn Scala", "Make my wife happy", "Start my own business"]) {
    await openProject(page, title);
    await page.getByRole("button", { name: "Delete", exact: true }).click();
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

test("rows start right under the date header", async ({ page }) => {
  const viewport = (await page.getByTestId("viewport").boundingBox())!;
  const first = (await row(page, "Learn Scala").boundingBox())!;
  expect(first.y - (viewport.y + 56)).toBeLessThan(80);
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

  test("the header fits without overlaps and the project panel opens at the bottom", async ({ page }) => {
    const header = (await page.locator(".board-header").boundingBox())!;
    const children = await page.locator(".board-header > *:visible").all();
    const boxes = (await Promise.all(children.map((child) => child.boundingBox()))).filter((box) => box && box.width > 0);
    for (const box of boxes) expect(box!.x + box!.width).toBeLessThanOrEqual(header.x + header.width + 1);
    for (let i = 1; i < boxes.length; i++) expect(boxes[i]!.x).toBeGreaterThanOrEqual(boxes[i - 1]!.x + boxes[i - 1]!.width - 1);

    await openProject(page, "Learn Scala");
    const card = (await projectPanel(page).boundingBox())!;
    expect(card.y + card.height).toBeGreaterThan(800);
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

test("event titles stay visible when zooming out", async ({ page }) => {
  for (const zoom of ["weeks", "months"]) {
    await page.getByRole("button", { name: zoom }).click();
    await expect(row(page, "Learn Scala").locator(".event-title", { hasText: "Buy a book" })).toBeVisible();
  }
});

test("an event with a time shows it in the days zoom", async ({ page }) => {
  const event = row(page, "Learn Scala").locator(".event", { hasText: "Buy a book" });
  await expect(event.locator(".event-title")).toHaveText("Buy a book");

  await event.locator(".event-title").click();
  // No time field until asked for; English accounts read 12 hours by default.
  await expect(page.getByLabel("Event time")).toHaveCount(0);
  await page.getByRole("button", { name: "+ time" }).click();
  await page.getByLabel("Event time").fill("19:30");
  const saved = apiCall(page, "PATCH", /^\/api\/events\/\d+$/);
  await page.getByLabel("Event time").press("Enter");
  const body = (await saved).request().postDataJSON() as { event: { timed: boolean; at: string } };
  expect(body.event.timed).toBe(true);
  await expect(event.locator(".event-time")).toHaveText("7:30 PM");
  await expect(event.locator(".event-title")).toHaveText("7:30 PMBuy a book");

  await page.reload();
  const reloaded = row(page, "Learn Scala").locator(".event", { hasText: "Buy a book" });
  await expect(reloaded.locator(".event-time")).toHaveText("7:30 PM");

  // The time chip of the edit form removes the time.
  await reloaded.locator(".event-title").click();
  await page.getByRole("button", { name: "Remove the time" }).click();
  const cleared = apiCall(page, "PATCH", /^\/api\/events\/\d+$/);
  await page.getByRole("button", { name: "Save" }).click();
  expect(((await cleared).request().postDataJSON() as { event: { timed: boolean } }).event.timed).toBe(false);
  await expect(reloaded.locator(".event-time")).toHaveCount(0);
  await page.reload();
  await page.getByRole("button", { name: "weeks" }).click();
  await expect(reloaded.locator(".event-time")).toHaveCount(0);
  await expect(reloaded.locator(".event-title")).toHaveText("Buy a book");
});
