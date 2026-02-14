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
  @k6.group("HTTP GET Test with Builder", fn() {
    // Get environment variable
    let url = match @k6.env("TEST_URL") {
      Some(u) => u
      None => "https://test.k6.io"
    }

    // Use Request Builder for fluent API
    let res = @k6.RequestBuilder::get(url)
      .header("User-Agent", "k6-moonbit/0.1.0")
      .tag("test", "get")
      .timeout("5s")
      .send()

    // Type-safe checks
    let _check1 = @k6.check_status_ok(res)
    let _check2 = @k6.check_response(res, "body not empty", fn(r) {
      r.body.length() > 0
    })

    ()
  })

  @k6.group("HTTP POST Test with Builder", fn() {
    let url = "https://httpbin.org/post"

    // Create request body
    let body = @core.new_object()
    body["name"] = @core.any("test")
    body["value"] = @core.any(123)

    // Use Request Builder with JSON
    let res = @k6.RequestBuilder::post(url)
      .json(@core.any(body))
      .header("X-Custom-Header", "moonbit")
      .tag("test", "post")
      .send()

    // Check status is 200
    let _check = @k6.check_status_200(res)

    ()
  })

  // Think time (user simulation)
  @k6.think(1.0)
}
