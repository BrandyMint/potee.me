import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    include: ["app/frontend/**/*.test.ts"],
    environment: "node",
  },
});
