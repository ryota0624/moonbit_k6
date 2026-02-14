// Import MoonBit test module
// Note: MoonBit compiles all .mbt files in src/ into a single module
// We're using test_all.mbt as the main test suite
import * as k6Test from "mbt:ryota0624/k6-test";

// Re-export k6 functions
// Note: options must be the result of calling options(), not the function itself
export const options = k6Test.options();
export const setup = k6Test.setup;
export const teardown = k6Test.teardown;
export default k6Test.default;
