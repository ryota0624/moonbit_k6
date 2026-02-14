// Simple k6 load test script in MoonBit

///| Test Options

/// k6 test options using Options type
pub fn options() -> @core.Any {
  // Create thresholds
  let thresholds = Map::new()
  thresholds.set("http_req_duration", ["p(95)<500"])

  // Build options with builder pattern
  @k6.Options::default()
    .vus(10)
    .duration("30s")
    .thresholds(thresholds)
    .to_js()
}

///| Test Scenario

///|
/// Main entry point for k6 - executed for each VU iteration
pub fn default() -> Unit {
  @k6.group("HTTP GET Test", fn() {
    // Get environment variable
    let url = match @k6.env("TEST_URL") {
      Some(u) => u
      None => "https://test.k6.io"
    }

    // Perform HTTP GET request
    let res = @k6.get(url)

    // Log response status
    let _status = res.status

    ()
  })

  @k6.group("HTTP POST Test", fn() {
    let url = "https://httpbin.org/post"

    // Create request body
    let body = @core.new_object()
    body["name"] = @core.any("test")
    body["value"] = @core.any(123)

    // Perform HTTP POST request
    let res = @k6.post(url, @core.any(body))

    // Log response status
    let _status = res.status

    ()
  })

  // Sleep for 1 second
  @k6.sleep(1.0)
}
