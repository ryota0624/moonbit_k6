import { defineConfig } from "vite";
import moonbit from "vite-plugin-moonbit";

export default defineConfig({
  plugins: [
    moonbit({
      target: "js",
      entry: "src/script.mbt",
    }),
  ],
  build: {
    outDir: "dist",
    lib: {
      entry: "src/script.mbt",
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
