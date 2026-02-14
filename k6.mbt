// k6 MoonBit Facade
// Type-safe bindings for k6 load testing framework

///| Core API - check (FFI)

///|
/// FFI: k6 check function
#module("k6")
extern "js" fn ffi_check(val : @core.Any, checks : @core.Any) -> @core.Any =
  "check"

///| Core API - fail (FFI)

///|
/// FFI: k6 fail function
#module("k6")
extern "js" fn ffi_fail(message : String) -> Unit = "fail"

///| Core API - group (FFI)

///|
/// FFI: k6 group function
#module("k6")
extern "js" fn ffi_group(name : String, body : @core.Any) -> @core.Any = "group"

///| Core API - sleep (FFI)

///|
/// FFI: k6 sleep function
#module("k6")
extern "js" fn ffi_sleep(duration : Double) -> Unit = "sleep"

///| Core API - randomSeed (FFI)

///|
/// FFI: k6 randomSeed function
#module("k6")
extern "js" fn ffi_random_seed(seed : Int) -> Unit = "randomSeed"

///| Global Variables (FFI)

///|
/// FFI: Get __ENV object
extern "js" fn ffi_env() -> @core.Any =
  #| () => __ENV

///|
/// FFI: Get __VU number
extern "js" fn ffi_vu() -> Int =
  #| () => __VU

///|
/// FFI: Get __ITER number
extern "js" fn ffi_iter() -> Int =
  #| () => __ITER

///| Global Functions (FFI)

///|
/// FFI: k6 open function
#module("k6")
extern "js" fn ffi_open(filename : String) -> String = "open"

///| Public API - check

///|
/// Runs checks on values and returns whether all checks passed
pub fn check(
  val : @core.Any,
  checks : Map[String, (@core.Any) -> Bool],
) -> Bool {
  // Convert Map to JS object
  let checks_obj = @core.new_object()
  checks.each(fn(name, check_fn) {
    // Wrap the MoonBit check function for JavaScript
    let wrapped : @core.Any = @core.any(fn(v : @core.Any) -> Bool {
      check_fn(v)
    })
    checks_obj[name] = wrapped
  })
  let result = ffi_check(val, checks_obj)
  result.cast()
}

///| Public API - fail

///|
/// Throws an error and aborts the current iteration
pub fn fail(message : String) -> Unit {
  ffi_fail(message)
}

///| Public API - group

///|
/// Executes code within a group context
pub fn[T : Default] group(name : String, body : () -> T) -> T {
  let wrapped : @core.Any = @core.any(body)
  let result = ffi_group(name, wrapped)
  if @core.is_nullish(result) {
    T::default()
  } else {
    result.cast()
  }
}

///| Public API - sleep

///|
/// Pauses VU execution for the specified duration in seconds
pub fn sleep(duration : Double) -> Unit {
  ffi_sleep(duration)
}

///| Public API - randomSeed

///|
/// Sets the seed for reproducible pseudo-random number generation
pub fn random_seed(seed : Int) -> Unit {
  ffi_random_seed(seed)
}

///| Public API - env

///|
/// Get environment variable by name
pub fn env(key : String) -> String? {
  let env_obj = ffi_env()
  let value = env_obj[key]
  if @core.is_nullish(value) {
    None
  } else {
    Some(value.cast())
  }
}

///| Public API - vu

///|
/// Current VU number (only available in VU context)
pub fn vu() -> Int {
  ffi_vu()
}

///| Public API - iter

///|
/// Current iteration number (only available in VU context)
pub fn iter() -> Int {
  ffi_iter()
}

///| Public API - open

///|
/// Loads file content into memory (only available in init context)
pub fn open(filename : String) -> String {
  ffi_open(filename)
}
