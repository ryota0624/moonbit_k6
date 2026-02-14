// Simple k6 load test script in MoonBit

///| Test Options

/// k6 test options as a JavaScript object
pub fn options() -> @core.Any {
  let opts = @core.new_object()
  opts["vus"] = @core.any(10)
  opts["duration"] = @core.any("30s")
  opts
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
