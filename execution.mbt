// k6/execution MoonBit Facade
// Execution context information for k6

///| VU Information

///|
/// FFI: Get vu object
#module("k6/execution")
extern "js" fn ffi_get_vu() -> @core.Any = "vu"

///|
/// FFI: Get scenario object
#module("k6/execution")
extern "js" fn ffi_get_scenario() -> @core.Any = "scenario"

///|
/// FFI: Get instance object
#module("k6/execution")
extern "js" fn ffi_get_instance() -> @core.Any = "instance"

///|
/// FFI: Get test object
#module("k6/execution")
extern "js" fn ffi_get_test_info() -> @core.Any = "test"

///| Public API

///|
/// Get VU execution context
/// Contains: idInInstance, idInTest, iterationInInstance, iterationInScenario
pub fn execution_vu() -> @core.Any {
  ffi_get_vu()
}

///|
/// Get scenario execution context
/// Contains: name, executor, startTime, progress, iterationInInstance, iterationInTest
pub fn execution_scenario() -> @core.Any {
  ffi_get_scenario()
}

///|
/// Get instance execution context
/// Contains: vusActive, vusInitialized, iterationsCompleted, iterationsInterrupted
pub fn execution_instance() -> @core.Any {
  ffi_get_instance()
}

///|
/// Get test execution context
/// Contains: options, abort()
pub fn test_info() -> @core.Any {
  ffi_get_test_info()
}

///| Helper Functions

///|
/// Get VU ID in instance
pub fn vu_id_in_instance() -> Int {
  let vu_obj = execution_vu()
  let id : Int = vu_obj["idInInstance"].cast()
  id
}

///|
/// Get VU ID in test
pub fn vu_id_in_test() -> Int {
  let vu_obj = execution_vu()
  let id : Int = vu_obj["idInTest"].cast()
  id
}

///|
/// Get iteration number in instance
pub fn iteration_in_instance() -> Int {
  let vu_obj = execution_vu()
  let iter : Int = vu_obj["iterationInInstance"].cast()
  iter
}

///|
/// Get iteration number in scenario
pub fn iteration_in_scenario() -> Int {
  let vu_obj = execution_vu()
  let iter : Int = vu_obj["iterationInScenario"].cast()
  iter
}

///|
/// Get scenario name
pub fn scenario_name() -> String {
  let scenario_obj = execution_scenario()
  let name : String = scenario_obj["name"].cast()
  name
}

///|
/// Get scenario executor
pub fn scenario_executor() -> String {
  let scenario_obj = execution_scenario()
  let executor : String = scenario_obj["executor"].cast()
  executor
}

///|
/// Get scenario progress (0.0 to 1.0)
pub fn scenario_progress() -> Double {
  let scenario_obj = execution_scenario()
  let progress : Double = scenario_obj["progress"].cast()
  progress
}
