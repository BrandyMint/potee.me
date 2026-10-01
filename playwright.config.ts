import { defineConfig, devices } from "@playwright/test";

// Runs against an already started app (bin/dev):
//   BASE_URL="http://127.0.0.1:$(port-selector --name web)" npm run e2e
// Every test gets a fresh browser context, i.e. a new anonymous user.
export default defineConfig({
  testDir: "e2e",
  fullyParallel: true,
  reporter: "list",
  use: {
    baseURL: process.env.BASE_URL ?? "http://127.0.0.1:3000",
    viewport: { width: 1400, height: 800 },
    trace: "retain-on-failure",
  },
  projects: [{ name: "chromium", use: { ...devices["Desktop Chrome"], viewport: { width: 1400, height: 800 } } }],
});
