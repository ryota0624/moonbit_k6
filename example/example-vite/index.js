// Import k6 functions and make them available globally for MoonBit FFI
import { group, sleep, check, fail, open } from "k6";

// Make k6 functions available globally
globalThis.group = group;
globalThis.sleep = sleep;
globalThis.check = check;
globalThis.fail = fail;
globalThis.open = open;

// k6 global variables are already available in k6 runtime
// No need to reassign them here

import * as k6Example from "mbt:ryota0624/k6-example";

// Re-export k6 options
export const options = {
  vus: 1,
};

// Re-export default test function
export default k6Example.default;
