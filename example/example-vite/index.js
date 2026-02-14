// Import MoonBit module
import * as k6Example from "mbt:ryota0624/k6-example";

// Re-export k6 options
export const options = {
  vus: 1,
};

// Re-export default test function
export default k6Example.default;
