import { expect, test } from "@playwright/test";

const uniqueEmail = () => `e2e-${Date.now()}-${Math.floor(Math.random() * 1e6)}@example.com`;

test("signing up keeps the board, logging back in restores it", async ({ page, browser }) => {
  await page.goto("/projects");
  await page.getByRole("button", { name: "New project", exact: true }).click();
  await page.getByLabel("Project title").fill("Before sign up");
  await page.getByLabel("Project title").press("Enter");
  await expect(page.getByTestId("project-Before sign up")).toBeVisible();

  await page.getByRole("link", { name: "Save your board" }).click();
  const email = uniqueEmail();
  await page.getByLabel("Email").fill(email);
  await page.getByLabel(/Password/).fill("secret-password");
  await page.getByRole("button", { name: "Sign up" }).click();

  await expect(page).toHaveURL(/\/projects$/);
  await expect(page.locator(".account-email")).toHaveText(email);
  await expect(page.getByRole("status")).toContainText("Your board is saved");
  await expect(page.getByTestId("project-Before sign up")).toBeVisible();

  await page.getByRole("button", { name: "Log out" }).click();
  await expect(page).toHaveURL(/\/$/);

  // Another browser: an anonymous board with an own project gets merged on login.
  const other = await browser.newContext();
  const otherPage = await other.newPage();
  await otherPage.goto("/projects");
  await otherPage.getByRole("button", { name: "New project", exact: true }).click();
  await otherPage.getByLabel("Project title").fill("From another device");
  await otherPage.getByLabel("Project title").press("Enter");
  await expect(otherPage.getByTestId("project-From another device")).toBeVisible();

  await otherPage.getByRole("link", { name: "Log in" }).click();
  await otherPage.getByLabel("Email").fill(email);
  await otherPage.getByLabel("Password").fill("secret-password");
  await otherPage.getByRole("button", { name: "Log in" }).click();

  await expect(otherPage).toHaveURL(/\/projects$/);
  await expect(otherPage.getByTestId("project-Before sign up")).toBeVisible();
  await expect(otherPage.getByTestId("project-From another device")).toBeVisible();
  // Untouched samples are not duplicated.
  await expect(otherPage.getByTestId("project-Learn Scala")).toHaveCount(1);
  await other.close();
});

test("wrong password shows an error", async ({ page }) => {
  await page.goto("/login");
  await page.getByLabel("Email").fill("nobody@example.com");
  await page.getByLabel("Password").fill("whatever-password");
  await page.getByRole("button", { name: "Log in" }).click();
  await expect(page.getByRole("alert")).toHaveText("Wrong email or password.");
});
