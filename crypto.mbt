// k6/crypto MoonBit Facade
// Cryptographic hashing for k6

///| Hash Functions

///|
/// FFI: Create hasher
#module("k6/crypto")
extern "js" fn ffi_create_hash(algorithm : String) -> @core.Any =
  "createHash"

///|
/// FFI: Create HMAC
#module("k6/crypto")
extern "js" fn ffi_create_hmac(
  algorithm : String,
  secret : String
) -> @core.Any =
  "createHMAC"

///|
/// FFI: MD5 hash
#module("k6/crypto")
extern "js" fn ffi_md5(data : String, output_encoding : String) -> String =
  "md5"

///|
/// FFI: SHA1 hash
#module("k6/crypto")
extern "js" fn ffi_sha1(data : String, output_encoding : String) -> String =
  "sha1"

///|
/// FFI: SHA256 hash
#module("k6/crypto")
extern "js" fn ffi_sha256(data : String, output_encoding : String) -> String =
  "sha256"

///|
/// FFI: SHA384 hash
#module("k6/crypto")
extern "js" fn ffi_sha384(data : String, output_encoding : String) -> String =
  "sha384"

///|
/// FFI: SHA512 hash
#module("k6/crypto")
extern "js" fn ffi_sha512(data : String, output_encoding : String) -> String =
  "sha512"

///|
/// FFI: SHA512_256 hash
#module("k6/crypto")
extern "js" fn ffi_sha512_256(
  data : String,
  output_encoding : String
) -> String =
  "sha512_256"

///|
/// FFI: RIPEMD160 hash
#module("k6/crypto")
extern "js" fn ffi_ripemd160(
  data : String,
  output_encoding : String
) -> String =
  "ripemd160"

///| Public API - Hash Functions

///|
/// Create a hash object
/// algorithm: "md5", "sha1", "sha256", "sha384", "sha512", "sha512_256", "ripemd160"
pub fn create_hash(algorithm : String) -> @core.Any {
  ffi_create_hash(algorithm)
}

///|
/// Create an HMAC object
/// algorithm: "md5", "sha1", "sha256", "sha384", "sha512", "sha512_256", "ripemd160"
pub fn create_hmac(algorithm : String, secret : String) -> @core.Any {
  ffi_create_hmac(algorithm, secret)
}

///|
/// Calculate MD5 hash
/// output_encoding: "hex", "base64", "base64url", "base64rawurl", "binary"
pub fn md5(data : String, output_encoding : String) -> String {
  ffi_md5(data, output_encoding)
}

///|
/// Calculate SHA1 hash
/// output_encoding: "hex", "base64", "base64url", "base64rawurl", "binary"
pub fn sha1(data : String, output_encoding : String) -> String {
  ffi_sha1(data, output_encoding)
}

///|
/// Calculate SHA256 hash
/// output_encoding: "hex", "base64", "base64url", "base64rawurl", "binary"
pub fn sha256(data : String, output_encoding : String) -> String {
  ffi_sha256(data, output_encoding)
}

///|
/// Calculate SHA384 hash
/// output_encoding: "hex", "base64", "base64url", "base64rawurl", "binary"
pub fn sha384(data : String, output_encoding : String) -> String {
  ffi_sha384(data, output_encoding)
}

///|
/// Calculate SHA512 hash
/// output_encoding: "hex", "base64", "base64url", "base64rawurl", "binary"
pub fn sha512(data : String, output_encoding : String) -> String {
  ffi_sha512(data, output_encoding)
}

///|
/// Calculate SHA512/256 hash
/// output_encoding: "hex", "base64", "base64url", "base64rawurl", "binary"
pub fn sha512_256(data : String, output_encoding : String) -> String {
  ffi_sha512_256(data, output_encoding)
}

///|
/// Calculate RIPEMD160 hash
/// output_encoding: "hex", "base64", "base64url", "base64rawurl", "binary"
pub fn ripemd160(data : String, output_encoding : String) -> String {
  ffi_ripemd160(data, output_encoding)
}

///| Random Data Generation

///|
/// FFI: Generate random bytes
#module("k6/crypto")
extern "js" fn ffi_random_bytes(size : Int) -> @core.Any = "randomBytes"

///|
/// Generate random bytes
pub fn random_bytes(size : Int) -> @core.Any {
  ffi_random_bytes(size)
}
