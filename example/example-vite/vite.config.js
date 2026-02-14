import { defineConfig } from "vite";
import moonbit from "vite-plugin-moonbit";

export default defineConfig({
  plugins: [
    moonbit({
      target: "js",
      buildMode: "release",
      watch: false,
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
        exports: "named",
      },
    },
  },
});
