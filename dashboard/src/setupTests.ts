// Registers jest-dom matchers (toBeInTheDocument, ...) on vitest's expect.
// Loaded via test.setupFiles in vite.config.ts.
import "@testing-library/jest-dom/vitest";
import { afterEach } from "vitest";
import { cleanup } from "@testing-library/react";

// Testing-library only auto-registers cleanup when the runner exposes a
// global afterEach; vitest globals are off here, so register it explicitly
// or renders leak between tests.
afterEach(() => {
  cleanup();
});
