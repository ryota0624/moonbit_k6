import { defineConfig } from "vite";
import moonbit from "vite-plugin-moonbit";

export default defineConfig({
  plugins: [
    moonbit({
      target: "js",
      buildMode: "release",
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
      external: ["k6", "k6/execution"],
      output: {
        exports: "named",
      },
    },
  },
});
