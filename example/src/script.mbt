// Simple k6 load test script in MoonBit

///| Test Scenario

/// Main entry point for k6 - executed for each VU iteration
fn main {
  @k6.group("HTTP GET Test", fn() {
    // Get environment variable
    let url = match @k6.env("TEST_URL") {
      Some(u) => u
      None => "http://localhost:8080"
    }

    // Log VU and iteration info (variables not used, just demonstrating the API)
    let _vu_id = @k6.vu()
    let _iter_id = @k6.iter()

    // Sleep for 1 second
    @k6.sleep(1.0)

    // Check would go here (when http module is implemented)
    // For now, just return
    ()
  })
}
