// Import MoonBit module
import * as k6Example from "mbt:ryota0624/k6-example";

// Re-export k6 functions
// Note: options must be the result of calling options(), not the function itself
export const options = k6Example.options();
export const setup = k6Example.setup;
export const teardown = k6Example.teardown;
export default k6Example.default;
