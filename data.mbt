// k6/data MoonBit Facade
// Data utilities for k6

///| Shared Array

///|
/// Shared array for sharing data between VUs
pub struct SharedArray {
  name : String
  handle : @core.Any
}

///|
/// FFI: Create SharedArray
#module("k6/data")
extern "js" fn ffi_shared_array_new(
  name : String,
  callback : @core.Any
) -> @core.Any =
  "SharedArray"

///|
/// Create a new SharedArray
/// The callback function should return an array
pub fn SharedArray::new(name : String, callback : () -> @core.Any) -> SharedArray {
  let wrapped : @core.Any = @core.any(callback)
  let handle = ffi_shared_array_new(name, wrapped)
  { name, handle }
}

///|
/// FFI: Get array element by index
extern "js" fn ffi_array_get(arr : @core.Any, index : Int) -> @core.Any =
  #|(arr, index) => arr[index]

///|
/// Get value from SharedArray by index
pub fn SharedArray::get(self : SharedArray, index : Int) -> @core.Any {
  ffi_array_get(self.handle, index)
}

///|
/// Get length of SharedArray
extern "js" fn ffi_array_length(arr : @core.Any) -> Int =
  #|(arr) => arr.length

///|
/// Get the length of the SharedArray
pub fn SharedArray::length(self : SharedArray) -> Int {
  ffi_array_length(self.handle)
}
