import { defineConfig } from "vite";
import moonbit from "vite-plugin-moonbit";
import { execSync } from "child_process";

export default defineConfig({
  plugins: [
    moonbit({
      target: "js",
      entry: "src/script.mbt",
    }),
    // Post-build plugin to convert to k6 format
    {
      name: "k6-post-build",
      closeBundle() {
        try {
          execSync("node scripts/post-build.js", { stdio: "inherit" });
        } catch (error) {
          console.error("Post-build script failed:", error);
        }
      },
    },
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
