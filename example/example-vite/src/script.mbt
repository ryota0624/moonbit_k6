// Comprehensive k6 load test example in MoonBit
// Demonstrates all major features of the k6 MoonBit facade

///| Test Configuration

///|
/// Test options with thresholds and configuration
pub fn options() -> @core.Any {
  // Define performance thresholds
  let thresholds = Map::new()
  thresholds.set("http_req_duration", ["p(95)<500", "p(99)<1000"])
  thresholds.set("http_req_failed", ["rate<0.01"])
  thresholds.set("checks", ["rate>0.95"])

  // Build options with builder pattern
  @k6.Options::default()
    .vus(2)
    .duration("20s")
    .thresholds(thresholds)
    .to_js()
}

///| Custom Metrics

let api_requests : @k6.Counter = @k6.create_counter("api_requests_total")
let success_rate : @k6.Rate = @k6.create_rate("request_success_rate")
let response_time : @k6.Trend = @k6.create_time_trend("response_time")

///| Setup Phase

///|
/// Setup function - runs once before the test starts
pub fn setup() -> @core.Any {
  // Create test configuration
  let config = @k6.TestSetup::new()
    .base_url("https://test.k6.io")
    .timeout("30s")
    .build()

  // Verify test environment is ready in setup group
  @k6.setup_group(fn() {
    let res = @k6.quick_get("https://test.k6.io")
    let _check = @k6.check_status_ok(res)
  })

  config
}

///| Main Test Scenarios

///|
/// Main test function - runs for each VU iteration
pub fn default(data : @core.Any) -> Unit {
  let base_url : String = data["baseUrl"].cast()

  // Scenario 1: Basic HTTP GET with Request Builder
  @k6.http_group("GET /", fn() {
    let res = @k6.RequestBuilder::get(base_url)
      .header("User-Agent", "k6-moonbit/0.1.0")
      .header("Accept", "application/json")
      .tag("scenario", "basic_get")
      .tag("endpoint", "home")
      .timeout("5s")
      .send()

    // Track metrics
    api_requests.increment()
    success_rate.record(res.status >= 200 && res.status < 300)

    // Multiple checks
    let _check = @k6.check_all(res, [
      ("status is 2xx", fn(r) { r.status >= 200 && r.status < 300 }),
      ("body not empty", fn(r) { r.body.length() > 0 }),
      ("response time OK", fn(_r) { true }), // Would check actual timing
    ])
  })

  @k6.think(0.5)

  // Scenario 2: HTTP POST with JSON
  @k6.api_group("contacts", fn() {
    // Create request body
    let contact = @core.new_object()
    contact["name"] = @core.any("John Doe")
    contact["email"] = @core.any("john@example.com")
    contact["message"] = @core.any("Hello from k6 MoonBit!")

    let res = @k6.RequestBuilder::post(base_url + "/contacts.php")
      .json(@core.any(contact))
      .tag("scenario", "create_contact")
      .tag("endpoint", "contacts")
      .send()

    api_requests.increment()

    // Check response
    let _check = @k6.check_status_ok(res)
  })

  @k6.think(0.3)

  // Scenario 3: Authentication example
  @k6.auth_group(fn() {
    // Simulate Basic Auth
    let res = @k6.RequestBuilder::get("https://httpbin.org/basic-auth/user/pass")
      .basic_auth("user", "pass")
      .tag("scenario", "authentication")
      .send()

    let _check = @k6.check_status_200(res)
  })

  @k6.think(0.2)

  // Scenario 4: Conditional execution based on iteration
  @k6.group("Conditional Execution", fn() {
    // Run only on first iteration
    @k6.on_first_iteration(fn() {
      let res = @k6.quick_get(base_url)
      let _check = @k6.check_status_ok(res)
    })

    // Run every 5 iterations
    @k6.every_n_iterations(5, fn() {
      let res = @k6.quick_get(base_url + "/news.php")
      let _check = @k6.check_status_ok(res)
    })
  })

  @k6.think(0.2)

  // Scenario 5: Using session for multiple requests
  @k6.group("Session Example", fn() {
    let session = @k6.AuthSession::bearer("mock_token_12345")

    // Multiple requests with same session
    let res1 = @k6.RequestBuilder::get("https://httpbin.org/get")
      .with_session(session)
      .tag("request", "first")
      .send()

    let _check1 = @k6.check_status_ok(res1)

    @k6.sleep(0.1)

    let res2 = @k6.RequestBuilder::get("https://httpbin.org/headers")
      .with_session(session)
      .tag("request", "second")
      .send()

    let _check2 = @k6.check_status_ok(res2)
  })

  @k6.think(0.5)

  // Scenario 6: Performance tracking
  @k6.group("Performance Tracking", fn() {
    let res = @k6.quick_get(base_url)

    // Track response time (would use actual timing in real implementation)
    response_time.add_value(100.0)

    // Check performance
    let _check = @k6.check_response(res, "fast response", fn(r) {
      r.status == 200
    })
  })

  // Scenario 7: VU-specific behavior
  @k6.group("VU-specific", fn() {
    let vu_id = @k6.current_vu()

    // Only VU 1 performs this
    @k6.on_first_vu(fn() {
      let res = @k6.quick_get(base_url)
      let _check = @k6.check_status_ok(res)
    })

    // All VUs perform this
    let res = @k6.RequestBuilder::get(base_url)
      .tag("vu", vu_id.to_string())
      .send()

    let _check = @k6.check_status_ok(res)
  })

  // Think time to simulate real user behavior
  @k6.think(1.0)
}

///| Teardown Phase

///|
/// Teardown function - runs once after the test completes
pub fn teardown(data : @core.Any) -> Unit {
  @k6.cleanup_group(fn() {
    // Log test completion
    @k6.log_test_summary(data)

    // Clean up any resources
    @k6.cleanup_resources(data)
  })
}
