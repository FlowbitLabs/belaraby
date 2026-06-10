// vitest/config re-exports Vite's defineConfig with the `test` key typed.
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => ({
  plugins: [react()],
  server: {
    host: true,
  },
  test: {
    environment: "jsdom",
    setupFiles: ["./src/setupTests.ts"],
  },
  build: {
    sourcemap: mode === "development",
    // Do NOT split vendors with manualChunks: react-admin, ra-ui-materialui,
    // @mui and @emotion are circularly interdependent, and forcing them into
    // separate chunks breaks chunk initialization order at runtime
    // ("Cannot access 'X' before initialization" with a blank page) while
    // build and tests stay green. One large vendor chunk is harmless for an
    // admin tool; the raised limit just keeps the size warning quiet.
    chunkSizeWarningLimit: 1500,
  },
  base: "./",
}));
