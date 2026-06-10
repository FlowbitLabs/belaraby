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
    rollupOptions: {
      output: {
        // Split the vendor bundle into framework groups so no chunk
        // crosses Vite's 500 kB warning threshold and browsers can cache
        // each group independently.
        manualChunks(id: string) {
          if (!id.includes("node_modules")) {
            return undefined;
          }
          // react-admin's MUI component layer is large enough to warrant
          // its own chunk.
          if (id.includes("ra-ui-materialui")) {
            return "vendor-ra-ui";
          }
          if (id.includes("react-admin") || id.includes("/ra-")) {
            return "vendor-react-admin";
          }
          // react-admin's heavyweight utility deps — split out so the
          // vendor-react-admin chunk stays under the warning threshold.
          if (
            id.includes("@tanstack") ||
            id.includes("react-hook-form") ||
            id.includes("lodash") ||
            id.includes("date-fns") ||
            id.includes("jsonexport") ||
            id.includes("inflection") ||
            id.includes("node-polyglot")
          ) {
            return "vendor-utils";
          }
          if (id.includes("@mui") || id.includes("@emotion")) {
            return "vendor-mui";
          }
          if (id.includes("@supabase")) {
            return "vendor-supabase";
          }
          if (
            id.includes("react-router") ||
            id.includes("/react/") ||
            id.includes("/react-dom/") ||
            id.includes("/scheduler/")
          ) {
            return "vendor-react";
          }
          return undefined;
        },
      },
    },
  },
  base: "./",
}));
