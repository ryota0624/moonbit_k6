// k6 HTTP Authentication
// Support for various authentication methods

///| Authentication Types

///|
/// Basic Authentication credentials
pub struct BasicAuth {
  username : String
  password : String
}

///|
/// Create Basic Auth
pub fn BasicAuth::new(username : String, password : String) -> BasicAuth {
  { username, password }
}

///|
/// Bearer Token Authentication
pub struct BearerAuth {
  token : String
}

///|
/// Create Bearer Auth
pub fn BearerAuth::new(token : String) -> BearerAuth {
  { token, }
}

///|
/// API Key Authentication
pub struct ApiKeyAuth {
  key : String
  header_name : String
}

///|
/// Create API Key Auth
pub fn ApiKeyAuth::new(key : String, header_name : String) -> ApiKeyAuth {
  { key, header_name }
}

///| Request Builder Extensions for Auth

///|
/// Add Basic Authentication to request
pub fn RequestBuilder::basic_auth(
  self : RequestBuilder,
  username : String,
  password : String,
) -> RequestBuilder {
  // Encode credentials as base64
  let credentials = username + ":" + password
  let encoded = b64encode(credentials)
  self.header("Authorization", "Basic " + encoded)
}

///|
/// Add Bearer token authentication
pub fn RequestBuilder::bearer_auth(
  self : RequestBuilder,
  token : String,
) -> RequestBuilder {
  self.header("Authorization", "Bearer " + token)
}

///|
/// Add API Key authentication
pub fn RequestBuilder::api_key_auth(
  self : RequestBuilder,
  key : String,
  header_name : String,
) -> RequestBuilder {
  self.header(header_name, key)
}

///|
/// Add custom authentication header
pub fn RequestBuilder::custom_auth(
  self : RequestBuilder,
  header_value : String,
) -> RequestBuilder {
  self.header("Authorization", header_value)
}

///| Authentication Helpers

///|
/// Create Authorization header for Basic Auth
pub fn create_basic_auth_header(username : String, password : String) -> String {
  let credentials = username + ":" + password
  let encoded = b64encode(credentials)
  "Basic " + encoded
}

///|
/// Create Authorization header for Bearer token
pub fn create_bearer_auth_header(token : String) -> String {
  "Bearer " + token
}

///|
/// Create API Key header value
pub fn create_api_key_header(key : String) -> String {
  key
}

///| OAuth 2.0 Helpers

///|
/// OAuth 2.0 token response
pub struct OAuthToken {
  access_token : String
  token_type : String
  expires_in : Int?
  refresh_token : String?
}

///|
/// Request OAuth 2.0 token (Client Credentials flow)
pub fn request_oauth_token(
  token_url : String,
  client_id : String,
  client_secret : String,
) -> OAuthToken {
  // Create form data
  let body = @core.new_object()
  body["grant_type"] = @core.any("client_credentials")
  body["client_id"] = @core.any(client_id)
  body["client_secret"] = @core.any(client_secret)

  // Make request
  let res = RequestBuilder::post(token_url)
    .header("Content-Type", "application/x-www-form-urlencoded")
    .json(@core.any(body))
    .send()

  // Parse response
  let json = res.json
  let access_token : String = json["access_token"].cast()
  let token_type : String = json["token_type"].cast()

  { access_token, token_type, expires_in: None, refresh_token: None }
}

///|
/// Use OAuth token with request
pub fn RequestBuilder::oauth_token(
  self : RequestBuilder,
  token : OAuthToken,
) -> RequestBuilder {
  let auth_value = token.token_type + " " + token.access_token
  self.header("Authorization", auth_value)
}

///| Session Management

///|
/// Session with authentication
pub struct AuthSession {
  auth_type : String
  credentials : @core.Any
  headers : Map[String, String]
}

///|
/// Create session with Basic Auth
pub fn AuthSession::basic(username : String, password : String) -> AuthSession {
  let headers = Map::new()
  let auth_header = create_basic_auth_header(username, password)
  headers.set("Authorization", auth_header)

  let creds = @core.new_object()
  creds["username"] = @core.any(username)
  creds["password"] = @core.any(password)

  { auth_type: "basic", credentials: @core.any(creds), headers }
}

///|
/// Create session with Bearer token
pub fn AuthSession::bearer(token : String) -> AuthSession {
  let headers = Map::new()
  headers.set("Authorization", "Bearer " + token)

  let creds = @core.new_object()
  creds["token"] = @core.any(token)

  { auth_type: "bearer", credentials: @core.any(creds), headers }
}

///|
/// Create session with API Key
pub fn AuthSession::api_key(key : String, header_name : String) -> AuthSession {
  let headers = Map::new()
  headers.set(header_name, key)

  let creds = @core.new_object()
  creds["key"] = @core.any(key)
  creds["headerName"] = @core.any(header_name)

  { auth_type: "apikey", credentials: @core.any(creds), headers }
}

///|
/// Apply session auth to request builder
pub fn RequestBuilder::with_session(
  self : RequestBuilder,
  session : AuthSession,
) -> RequestBuilder {
  self.headers(session.headers)
}

///| Authentication Testing Helpers

///|
/// Test if authentication is required
pub fn test_auth_required(url : String) -> Bool {
  let res = quick_get(url)
  res.status == 401 || res.status == 403
}

///|
/// Test if authentication is valid
pub fn test_auth_valid(url : String, session : AuthSession) -> Bool {
  let res = RequestBuilder::get(url).with_session(session).send()
  res.status == 200
}

///|
/// Test Basic Auth credentials
pub fn test_basic_auth(
  url : String,
  username : String,
  password : String,
) -> Bool {
  let res = RequestBuilder::get(url).basic_auth(username, password).send()
  res.status == 200
}

///|
/// Test Bearer token
pub fn test_bearer_token(url : String, token : String) -> Bool {
  let res = RequestBuilder::get(url).bearer_auth(token).send()
  res.status == 200
}
