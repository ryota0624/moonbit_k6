// k6/encoding MoonBit Facade
// Encoding utilities for k6

///| Base64 Encoding

///|
/// FFI: Base64 encode
#module("k6/encoding")
extern "js" fn ffi_b64encode(input : String) -> String = "b64encode"

///|
/// FFI: Base64 encode with encoding
#module("k6/encoding")
extern "js" fn ffi_b64encode_with_encoding(
  input : String,
  encoding : String
) -> String =
  "b64encode"

///|
/// FFI: Base64 decode
#module("k6/encoding")
extern "js" fn ffi_b64decode(input : String) -> String = "b64decode"

///|
/// FFI: Base64 decode with encoding
#module("k6/encoding")
extern "js" fn ffi_b64decode_with_encoding(
  input : String,
  encoding : String,
  format : String
) -> String =
  "b64decode"

///| Public API - Base64

///|
/// Encode string to base64
pub fn b64encode(input : String) -> String {
  ffi_b64encode(input)
}

///|
/// Encode string to base64 with specific encoding
/// encoding: "std" (standard) or "rawstd", "url" or "rawurl"
pub fn b64encode_with_encoding(input : String, encoding : String) -> String {
  ffi_b64encode_with_encoding(input, encoding)
}

///|
/// Decode base64 string
pub fn b64decode(input : String) -> String {
  ffi_b64decode(input)
}

///|
/// Decode base64 string with specific encoding and format
/// encoding: "std" (standard) or "rawstd", "url" or "rawurl"
/// format: "s" (string) or "b" (binary)
pub fn b64decode_with_format(
  input : String,
  encoding : String,
  format : String
) -> String {
  ffi_b64decode_with_encoding(input, encoding, format)
}
