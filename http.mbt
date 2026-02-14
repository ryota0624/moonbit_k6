// k6/http MoonBit Facade
// HTTP client for k6 load testing

///| Response Type

///|
/// HTTP Response type
/// Represents the response from an HTTP request
pub struct Response {
  status : Int
  status_text : String
  body : String
  headers : Map[String, String]
  json : @core.Any
  html : @core.Any
  timings : @core.Any
}

///|
/// Create Response from JS object
fn response_from_js(obj : @core.Any) -> Response {
  let status : Int = obj["status"].cast()
  let status_text : String = obj["status_text"].cast()
  let body : String = obj["body"].cast()

  // Extract headers
  let headers_obj : @core.Any = obj["headers"]
  let headers : Map[String, String] = Map::new()
  // TODO: Convert headers object to Map

  {
    status,
    status_text,
    body,
    headers,
    json: obj["json"],
    html: obj["html"],
    timings: obj["timings"],
  }
}

///| HTTP Methods (FFI)

///|
/// FFI: HTTP GET request
#module("k6/http")
extern "js" fn ffi_get(url : String) -> @core.Any = "get"

///|
/// FFI: HTTP GET request with params
#module("k6/http")
extern "js" fn ffi_get_with_params(url : String, params : @core.Any) -> @core.Any =
  "get"

///| Public API - GET

///|
/// Performs an HTTP GET request
pub fn get(url : String) -> Response {
  let res = ffi_get(url)
  response_from_js(res)
}

///|
/// Performs an HTTP GET request with parameters
pub fn get_with_params(url : String, params : @core.Any) -> Response {
  let res = ffi_get_with_params(url, params)
  response_from_js(res)
}
