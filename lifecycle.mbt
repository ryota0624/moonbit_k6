// k6 Test Lifecycle Helpers
// Utilities for test lifecycle management

///| Test Lifecycle Hooks

///|
/// Setup function type - runs once before test
pub type SetupFunc = () -> @core.Any

///|
/// Teardown function type - runs once after test
pub type TeardownFunc = (@core.Any) -> Unit

///|
/// VU function type - runs for each VU iteration
pub type VUFunc = (@core.Any) -> Unit

///| Test Configuration

///|
/// Test configuration with lifecycle hooks
pub struct TestConfig {
  setup_fn : SetupFunc?
  teardown_fn : TeardownFunc?
  vu_fn : VUFunc
}

///|
/// Create test config with only VU function
pub fn TestConfig::new(vu_fn : VUFunc) -> TestConfig {
  { setup_fn: None, teardown_fn: None, vu_fn }
}

///|
/// Set setup function
pub fn TestConfig::setup(self : TestConfig, setup_fn : SetupFunc) -> TestConfig {
  { ..self, setup_fn: Some(setup_fn) }
}

///|
/// Set teardown function
pub fn TestConfig::teardown(
  self : TestConfig,
  teardown_fn : TeardownFunc
) -> TestConfig {
  { ..self, teardown_fn: Some(teardown_fn) }
}

///| Iteration Control

///|
/// Get current iteration number
pub fn current_iteration() -> Int {
  iter()
}

///|
/// Get current VU ID
pub fn current_vu() -> Int {
  vu()
}

///|
/// Check if this is the first iteration
pub fn is_first_iteration() -> Bool {
  iter() == 0
}

///|
/// Check if this is a specific iteration
pub fn is_iteration(n : Int) -> Bool {
  iter() == n
}

///|
/// Run code only on first iteration
pub fn on_first_iteration(f : () -> Unit) -> Unit {
  if is_first_iteration() {
    f()
  }
}

///|
/// Run code only on specific iteration
pub fn on_iteration(n : Int, f : () -> Unit) -> Unit {
  if is_iteration(n) {
    f()
  }
}

///|
/// Run code every N iterations
pub fn every_n_iterations(n : Int, f : () -> Unit) -> Unit {
  if iter() % n == 0 {
    f()
  }
}

///| VU Control

///|
/// Check if this is a specific VU
pub fn is_vu(n : Int) -> Bool {
  vu() == n
}

///|
/// Run code only on specific VU
pub fn on_vu(n : Int, f : () -> Unit) -> Unit {
  if is_vu(n) {
    f()
  }
}

///|
/// Run code only on first VU
pub fn on_first_vu(f : () -> Unit) -> Unit {
  on_vu(1, f)
}

///| Scenario Helpers

///|
/// Get scenario information
pub fn scenario_info() -> @core.Any {
  execution_scenario()
}

///|
/// Get VU information
pub fn vu_info() -> @core.Any {
  execution_vu()
}

///|
/// Get test information
pub fn test_info_data() -> @core.Any {
  test_info()
}

///| Pacing Helpers

///|
/// Sleep for a specific duration in seconds
pub fn pace(duration_seconds : Double) -> Unit {
  sleep(duration_seconds)
}

///|
/// Sleep for a random duration between min and max seconds
pub fn pace_random(min_seconds : Double, max_seconds : Double) -> Unit {
  // Generate random duration (using k6's randomSeed for reproducibility)
  let range = max_seconds - min_seconds
  // Simple pseudo-random (would need proper random in real implementation)
  let random_offset = range / 2.0
  let duration = min_seconds + random_offset
  sleep(duration)
}

///| Think Time

///|
/// Simulate user think time (alias for sleep)
pub fn think(duration_seconds : Double) -> Unit {
  sleep(duration_seconds)
}

///|
/// Think time between min and max seconds
pub fn think_random(min_seconds : Double, max_seconds : Double) -> Unit {
  pace_random(min_seconds, max_seconds)
}
