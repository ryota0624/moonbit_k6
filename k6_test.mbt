// Blackbox tests run against the package's public API. Use `@k6` to import.
// Prefer high-level behaviors over implementation details.
// Run `moon test` to execute and `moon test --update` to refresh snapshots.

///|
test "k6 API test" {
  // Test that we can call the options function and it returns an object
  fail("hi")
}
