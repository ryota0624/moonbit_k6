// k6/metrics MoonBit Facade
// Custom metrics for k6 load testing

///| Counter Metric

///|
/// Counter metric - counts occurrences
pub struct Counter {
  name : String
  is_time : Bool
  handle : @core.Any
}

///|
/// FFI: Create Counter
#module("k6/metrics")
extern "js" fn ffi_counter_new(name : String, is_time : Bool) -> @core.Any =
  "Counter"

///|
/// FFI: Counter add
extern "js" fn ffi_counter_add(counter : @core.Any, value : Double) -> Unit =
  #|(counter, value) => counter.add(value)

///|
/// Create a new Counter metric
pub fn Counter::new(name : String, is_time : Bool) -> Counter {
  let handle = ffi_counter_new(name, is_time)
  { name, is_time, handle }
}

///|
/// Add a value to the counter
pub fn Counter::add(self : Counter, value : Double) -> Unit {
  ffi_counter_add(self.handle, value)
}

///| Gauge Metric

///|
/// Gauge metric - tracks the latest value
pub struct Gauge {
  name : String
  is_time : Bool
  handle : @core.Any
}

///|
/// FFI: Create Gauge
#module("k6/metrics")
extern "js" fn ffi_gauge_new(name : String, is_time : Bool) -> @core.Any =
  "Gauge"

///|
/// FFI: Gauge add
extern "js" fn ffi_gauge_add(gauge : @core.Any, value : Double) -> Unit =
  #|(gauge, value) => gauge.add(value)

///|
/// Create a new Gauge metric
pub fn Gauge::new(name : String, is_time : Bool) -> Gauge {
  let handle = ffi_gauge_new(name, is_time)
  { name, is_time, handle }
}

///|
/// Set the gauge value
pub fn Gauge::add(self : Gauge, value : Double) -> Unit {
  ffi_gauge_add(self.handle, value)
}

///| Rate Metric

///|
/// Rate metric - tracks the percentage of non-zero values
pub struct Rate {
  name : String
  is_time : Bool
  handle : @core.Any
}

///|
/// FFI: Create Rate
#module("k6/metrics")
extern "js" fn ffi_rate_new(name : String, is_time : Bool) -> @core.Any = "Rate"

///|
/// FFI: Rate add
extern "js" fn ffi_rate_add(rate : @core.Any, value : Bool) -> Unit =
  #|(rate, value) => rate.add(value)

///|
/// Create a new Rate metric
pub fn Rate::new(name : String, is_time : Bool) -> Rate {
  let handle = ffi_rate_new(name, is_time)
  { name, is_time, handle }
}

///|
/// Add a value to the rate (true = success, false = failure)
pub fn Rate::add(self : Rate, value : Bool) -> Unit {
  ffi_rate_add(self.handle, value)
}

///| Trend Metric

///|
/// Trend metric - calculates statistics over added values
pub struct Trend {
  name : String
  is_time : Bool
  handle : @core.Any
}

///|
/// FFI: Create Trend
#module("k6/metrics")
extern "js" fn ffi_trend_new(name : String, is_time : Bool) -> @core.Any =
  "Trend"

///|
/// FFI: Trend add
extern "js" fn ffi_trend_add(trend : @core.Any, value : Double) -> Unit =
  #|(trend, value) => trend.add(value)

///|
/// Create a new Trend metric
pub fn Trend::new(name : String, is_time : Bool) -> Trend {
  let handle = ffi_trend_new(name, is_time)
  { name, is_time, handle }
}

///|
/// Add a value to the trend
pub fn Trend::add(self : Trend, value : Double) -> Unit {
  ffi_trend_add(self.handle, value)
}
