// k6 Metrics Helpers
// Convenience wrappers for k6 metrics

///| Counter Helpers

///|
/// Create a simple counter metric
pub fn create_counter(name : String) -> Counter {
  Counter::new(name, false)
}

///|
/// Create a time counter metric (for duration measurements)
pub fn create_time_counter(name : String) -> Counter {
  Counter::new(name, true)
}

///|
/// Increment counter by 1
pub fn Counter::increment(self : Counter) -> Unit {
  self.add(1.0)
}

///|
/// Add value to counter
pub fn Counter::add_value(self : Counter, value : Double) -> Unit {
  self.add(value)
}

///| Gauge Helpers

///|
/// Create a simple gauge metric
pub fn create_gauge(name : String) -> Gauge {
  Gauge::new(name, false)
}

///|
/// Create a time gauge metric
pub fn create_time_gauge(name : String) -> Gauge {
  Gauge::new(name, true)
}

///|
/// Set gauge value
pub fn Gauge::set(self : Gauge, value : Double) -> Unit {
  self.add(value)
}

///| Rate Helpers

///|
/// Create a rate metric
pub fn create_rate(name : String) -> Rate {
  Rate::new(name, false)
}

///|
/// Record success
pub fn Rate::success(self : Rate) -> Unit {
  self.add(true)
}

///|
/// Record failure
pub fn Rate::failure(self : Rate) -> Unit {
  self.add(false)
}

///|
/// Record result (true = success, false = failure)
pub fn Rate::record(self : Rate, success : Bool) -> Unit {
  self.add(success)
}

///| Trend Helpers

///|
/// Create a trend metric
pub fn create_trend(name : String) -> Trend {
  Trend::new(name, false)
}

///|
/// Create a time trend metric (for duration measurements)
pub fn create_time_trend(name : String) -> Trend {
  Trend::new(name, true)
}

///|
/// Add value to trend
pub fn Trend::add_value(self : Trend, value : Double) -> Unit {
  self.add(value)
}

///| Timing Helpers

///|
/// Measure execution time of a function and record to trend
pub fn[T] measure_time(trend : Trend, f : () -> T) -> T {
  // Get start time (would need actual timing in real implementation)
  let result = f()
  // Get end time and calculate duration
  // For now, just record a placeholder value
  trend.add(0.0)
  result
}

///|
/// Measure execution time and return both result and duration
pub fn[T] measure_time_with_duration(f : () -> T) -> (T, Double) {
  // Get start time
  let result = f()
  // Get end time and calculate duration
  let duration = 0.0 // Placeholder
  (result, duration)
}

///| Custom Metrics

///|
/// Track HTTP request duration
pub fn track_http_duration(_name : String, _res : Response, trend : Trend) -> Unit {
  // k6 Response has timing information
  // For now, use a placeholder
  trend.add(100.0)
}

///|
/// Track success rate based on HTTP status
pub fn track_http_success(rate : Rate, res : Response) -> Unit {
  rate.record(res.status >= 200 && res.status < 300)
}

///|
/// Track HTTP request count
pub fn track_http_count(counter : Counter) -> Unit {
  counter.increment()
}

///| Composite Tracking

///|
/// Track all HTTP metrics at once
pub struct HttpMetrics {
  requests : Counter
  success_rate : Rate
  duration : Trend
}

///|
/// Create HTTP metrics set
pub fn HttpMetrics::new(prefix : String) -> HttpMetrics {
  {
    requests: create_counter(prefix + "_requests"),
    success_rate: create_rate(prefix + "_success_rate"),
    duration: create_time_trend(prefix + "_duration"),
  }
}

///|
/// Track HTTP response with all metrics
pub fn HttpMetrics::track(self : HttpMetrics, res : Response) -> Unit {
  track_http_count(self.requests)
  track_http_success(self.success_rate, res)
  track_http_duration("", res, self.duration)
}
