// k6/ws MoonBit Facade
// WebSocket client for k6 load testing

///| WebSocket Connection

///|
/// WebSocket connection handle
pub struct Socket {
  handle : @core.Any
}

///| WebSocket Events

///|
/// Event handler for WebSocket connection open
pub type OnOpenHandler = (@core.Any) -> Unit

///|
/// Event handler for WebSocket message
pub type OnMessageHandler = (@core.Any) -> Unit

///|
/// Event handler for WebSocket close
pub type OnCloseHandler = (@core.Any) -> Unit

///|
/// Event handler for WebSocket error
pub type OnErrorHandler = (@core.Any) -> Unit

///| WebSocket Params

///|
/// WebSocket connection parameters
pub struct WebSocketParams {
  headers : Map[String, String]?
  tags : Map[String, String]?
}

///|
/// Create default WebSocket params
pub fn WebSocketParams::default() -> WebSocketParams {
  { headers: None, tags: None }
}

///|
/// Convert Params to JS object
fn ws_params_to_js(params : WebSocketParams) -> @core.Any {
  let obj = @core.new_object()

  match params.headers {
    Some(h) => {
      let headers_obj = @core.new_object()
      h.each(fn(key, value) { headers_obj[key] = @core.any(value) })
      obj["headers"] = @core.any(headers_obj)
    }
    None => ()
  }

  match params.tags {
    Some(t) => {
      let tags_obj = @core.new_object()
      t.each(fn(key, value) { tags_obj[key] = @core.any(value) })
      obj["tags"] = @core.any(tags_obj)
    }
    None => ()
  }

  @core.any(obj)
}

///| WebSocket Response

///|
/// WebSocket connection response
pub struct WebSocketResponse {
  url : String
  status : Int
  headers : @core.Any
}

///|
/// Create WebSocketResponse from JS object
fn ws_response_from_js(obj : @core.Any) -> WebSocketResponse {
  let url : String = obj["url"].cast()
  let status : Int = obj["status"].cast()
  let headers = obj["headers"]
  { url, status, headers }
}

///| FFI Functions

///|
/// FFI: Connect to WebSocket
#module("k6/ws")
extern "js" fn ffi_connect(
  url : String,
  params : @core.Any,
  callback : @core.Any
) -> @core.Any =
  "connect"

///|
/// FFI: Send message
extern "js" fn ffi_socket_send(socket : @core.Any, data : String) -> Unit =
  #|(socket, data) => socket.send(data)

///|
/// FFI: Close connection
extern "js" fn ffi_socket_close(socket : @core.Any) -> Unit =
  #|(socket) => socket.close()

///|
/// FFI: Set event handlers
extern "js" fn ffi_socket_on(
  socket : @core.Any,
  event : String,
  handler : @core.Any
) -> Unit =
  #|(socket, event, handler) => socket.on(event, handler)

///|
/// FFI: Set timeout
extern "js" fn ffi_socket_set_timeout(socket : @core.Any, callback : @core.Any, delay : Int) -> Unit =
  #|(socket, callback, delay) => socket.setTimeout(callback, delay)

///| Public API

///|
/// Connect to WebSocket server
/// The callback function receives a Socket object
pub fn connect(
  url : String,
  params : WebSocketParams,
  callback : (Socket) -> Unit
) -> WebSocketResponse {
  let params_obj = ws_params_to_js(params)
  let wrapped_callback : @core.Any = @core.any(fn(socket_obj : @core.Any) {
    let socket = { handle: socket_obj }
    callback(socket)
  })
  let res = ffi_connect(url, params_obj, wrapped_callback)
  ws_response_from_js(res)
}

///|
/// Send message to WebSocket server
pub fn Socket::send(self : Socket, data : String) -> Unit {
  ffi_socket_send(self.handle, data)
}

///|
/// Close WebSocket connection
pub fn Socket::close(self : Socket) -> Unit {
  ffi_socket_close(self.handle)
}

///|
/// Set event handler for WebSocket events
/// Events: "open", "message", "close", "error"
pub fn Socket::on(self : Socket, event : String, handler : @core.Any) -> Unit {
  ffi_socket_on(self.handle, event, handler)
}

///|
/// Set timeout for WebSocket connection
pub fn Socket::set_timeout(
  self : Socket,
  callback : () -> Unit,
  delay : Int
) -> Unit {
  let wrapped : @core.Any = @core.any(callback)
  ffi_socket_set_timeout(self.handle, wrapped, delay)
}
