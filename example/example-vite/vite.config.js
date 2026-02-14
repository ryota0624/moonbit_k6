import { defineConfig } from "vite";
import moonbit from "vite-plugin-moonbit";

export default defineConfig({
  plugins: [
    moonbit({
      target: "js",
      watch: true,
      showLogs: true,
    }),
  ],
  build: {
    outDir: "dist",
    lib: {
      entry: "index.js",
      name: "k6Script",
      fileName: "script",
      formats: ["es"],
    },
    rollupOptions: {
      output: {
        // Ensure k6 compatible exports
        exports: "named",
      },
    },
  },
});
