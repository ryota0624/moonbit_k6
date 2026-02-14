// k6 HTTP Request Builder
// High-level, type-safe HTTP client API

///| HTTP Request Builder

///|
/// HTTP Request Builder for fluent API
pub struct RequestBuilder {
  method : String
  url : String
  body : @core.Any?
  headers : Map[String, String]
  tags : Map[String, String]
  timeout : String?
}

///|
/// Create a new GET request builder
pub fn RequestBuilder::get(url : String) -> RequestBuilder {
  {
    method: "GET",
    url,
    body: None,
    headers: Map::new(),
    tags: Map::new(),
    timeout: None,
  }
}

///|
/// Create a new POST request builder
pub fn RequestBuilder::post(url : String) -> RequestBuilder {
  {
    method: "POST",
    url,
    body: None,
    headers: Map::new(),
    tags: Map::new(),
    timeout: None,
  }
}

///|
/// Create a new PUT request builder
pub fn RequestBuilder::put(url : String) -> RequestBuilder {
  {
    method: "PUT",
    url,
    body: None,
    headers: Map::new(),
    tags: Map::new(),
    timeout: None,
  }
}

///|
/// Create a new PATCH request builder
pub fn RequestBuilder::patch(url : String) -> RequestBuilder {
  {
    method: "PATCH",
    url,
    body: None,
    headers: Map::new(),
    tags: Map::new(),
    timeout: None,
  }
}

///|
/// Create a new DELETE request builder
pub fn RequestBuilder::delete(url : String) -> RequestBuilder {
  {
    method: "DELETE",
    url,
    body: None,
    headers: Map::new(),
    tags: Map::new(),
    timeout: None,
  }
}

///|
/// Set request body as JSON
pub fn RequestBuilder::json(self : RequestBuilder, data : @core.Any) -> RequestBuilder {
  let headers = self.headers
  headers.set("Content-Type", "application/json")
  { ..self, body: Some(data), headers }
}

///|
/// Set request body as text
pub fn RequestBuilder::text(self : RequestBuilder, data : String) -> RequestBuilder {
  { ..self, body: Some(@core.any(data)) }
}

///|
/// Add a header
pub fn RequestBuilder::header(
  self : RequestBuilder,
  key : String,
  value : String
) -> RequestBuilder {
  let headers = self.headers
  headers.set(key, value)
  { ..self, headers }
}

///|
/// Add multiple headers
pub fn RequestBuilder::headers(
  self : RequestBuilder,
  headers_map : Map[String, String]
) -> RequestBuilder {
  let headers = self.headers
  headers_map.each(fn(k, v) { headers.set(k, v) })
  { ..self, headers }
}

///|
/// Add a tag
pub fn RequestBuilder::tag(
  self : RequestBuilder,
  key : String,
  value : String
) -> RequestBuilder {
  let tags = self.tags
  tags.set(key, value)
  { ..self, tags }
}

///|
/// Set timeout
pub fn RequestBuilder::timeout(
  self : RequestBuilder,
  timeout : String
) -> RequestBuilder {
  { ..self, timeout: Some(timeout) }
}

///|
/// Execute the request and return Response
pub fn RequestBuilder::send(self : RequestBuilder) -> Response {
  // Create params with headers and tags
  let params = {
    headers: self.headers,
    tags: self.tags,
    timeout: self.timeout,
  }

  // Execute request
  match self.body {
    Some(b) => request(self.method, self.url, b, params)
    None => request(self.method, self.url, @core.any(null), params)
  }
}

///| Helper Functions

///|
/// Quick GET request
pub fn quick_get(url : String) -> Response {
  RequestBuilder::get(url).send()
}

///|
/// Quick POST request with JSON body
pub fn quick_post_json(url : String, data : @core.Any) -> Response {
  RequestBuilder::post(url).json(data).send()
}

///|
/// Quick PUT request with JSON body
pub fn quick_put_json(url : String, data : @core.Any) -> Response {
  RequestBuilder::put(url).json(data).send()
}

///|
/// Quick PATCH request with JSON body
pub fn quick_patch_json(url : String, data : @core.Any) -> Response {
  RequestBuilder::patch(url).json(data).send()
}

///|
/// Quick DELETE request
pub fn quick_delete(url : String) -> Response {
  RequestBuilder::delete(url).send()
}

///| Response Extensions

///|
/// Check if response status is 2xx
pub fn Response::is_ok(self : Response) -> Bool {
  self.status >= 200 && self.status < 300
}

///|
/// Check if response status is specific code
pub fn Response::is_status(self : Response, code : Int) -> Bool {
  self.status == code
}

///|
/// Get JSON body as Any
pub fn Response::json_body(self : Response) -> @core.Any {
  self.json
}

///|
/// Get text body
pub fn Response::text_body(self : Response) -> String {
  self.body
}
