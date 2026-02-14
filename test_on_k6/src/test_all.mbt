// Comprehensive test suite for k6 MoonBit library
// This file combines all tests into a single executable

///| Custom Metrics

let test_counter : @k6.Counter = @k6.create_counter("test_counter")
let test_requests : @k6.Counter = @k6.create_counter("test_requests")

///| Test Configuration

// 期待される動作:
// - VU: 1
// - Iterations: 3
// - http_reqs: 6 (2 requests per iteration)
// - checks: 9 (3 checks per iteration)
// - test_counter: 3
// - test_requests: 6
pub fn options() -> @core.Any {
  @k6.Options::default()
    .vus(1)
    .iterations(3)
    .to_js()
}

///| Setup Phase

pub fn setup() -> @core.Any {
  // 環境変数HTTPBIN_URLから取得、未設定の場合はローカルを使用
  let base_url = match @k6.env("HTTPBIN_URL") {
    Some(url) => url
    None => "http://localhost:8080"
  }

  let config = @k6.TestSetup::new()
    .base_url(base_url)
    .timeout("10s")
    .build()

  config
}

///| Main Test Function

pub fn default(data : @core.Any) -> Unit {
  let base_url : String = data["baseUrl"].cast()

  // =====================================
  // Test Group 1: Core API
  // =====================================
  @k6.group("1. Core API Tests", fn() {
    // Test: Group and check functionality
    let res = @k6.quick_get(base_url + "/status/200")
    test_requests.increment()

    // 期待: check成功
    let _check = @k6.check_status_200(res)

    @k6.sleep(0.05)
  })

  // =====================================
  // Test Group 2: HTTP Requests
  // =====================================
  @k6.group("2. HTTP Tests", fn() {
    // Test: HTTP GET request
    let res = @k6.quick_get(base_url + "/get")
    test_requests.increment()

    // 期待: status 2xx, body not empty
    let _checks = @k6.check_all(res, [
      ("status is 2xx", fn(r) { r.status >= 200 && r.status < 300 }),
      ("body not empty", fn(r) { r.body.length() > 0 }),
    ])

    @k6.sleep(0.05)
  })

  // =====================================
  // Test Group 3: Custom Metrics
  // =====================================
  @k6.group("3. Metrics Tests", fn() {
    // Test: Counter increment
    test_counter.increment()

    // 期待: カウンタがインクリメントされる
    @k6.sleep(0.05)
  })

  // =====================================
  // Test Group 4: Lifecycle Helpers
  // =====================================
  @k6.group("4. Lifecycle Tests", fn() {
    // Test: on_first_iteration
    @k6.on_first_iteration(fn() {
      // 期待: 最初のイテレーションでのみ実行
      ()
    })

    // Test: every_n_iterations
    @k6.every_n_iterations(2, fn() {
      // 期待: 2イテレーションごとに実行
      ()
    })

    @k6.sleep(0.05)
  })

  // Think time to simulate real user behavior
  @k6.think(0.1)
}

///| Teardown Phase

pub fn teardown(data : @core.Any) -> Unit {
  @k6.cleanup_group(fn() {
    @k6.log_test_summary(data)
    @k6.cleanup_resources(data)
  })
}
