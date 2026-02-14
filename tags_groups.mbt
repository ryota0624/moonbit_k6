// k6 Tags and Groups
// Enhanced support for tagging and grouping

///| Tag Management

///|
/// Tag set for organizing test metrics
pub struct TagSet {
  tags : Map[String, String]
}

///|
/// Create new tag set
pub fn TagSet::new() -> TagSet {
  { tags: Map::new() }
}

///|
/// Add a tag
pub fn TagSet::add(self : TagSet, key : String, value : String) -> TagSet {
  let tags = self.tags
  tags.set(key, value)
  { tags, }
}

///|
/// Add multiple tags
pub fn TagSet::add_all(self : TagSet, tags : Map[String, String]) -> TagSet {
  let current_tags = self.tags
  tags.each(fn(k, v) { current_tags.set(k, v) })
  { tags: current_tags }
}

///|
/// Remove a tag
pub fn TagSet::remove(self : TagSet, key : String) -> TagSet {
  let tags = self.tags
  tags.remove(key)
  { tags, }
}

///|
/// Get tag value
pub fn TagSet::get(self : TagSet, key : String) -> String? {
  self.tags.get(key)
}

///|
/// Convert to map
pub fn TagSet::to_map(self : TagSet) -> Map[String, String] {
  self.tags
}

///| Common Tag Builders

///|
/// Create environment tag
pub fn tag_environment(env : String) -> (String, String) {
  ("environment", env)
}

///|
/// Create test type tag
pub fn tag_test_type(test_type : String) -> (String, String) {
  ("test_type", test_type)
}

///|
/// Create API version tag
pub fn tag_api_version(version : String) -> (String, String) {
  ("api_version", version)
}

///|
/// Create region tag
pub fn tag_region(region : String) -> (String, String) {
  ("region", region)
}

///|
/// Create user type tag
pub fn tag_user_type(user_type : String) -> (String, String) {
  ("user_type", user_type)
}

///|
/// Create scenario tag
pub fn tag_scenario(scenario : String) -> (String, String) {
  ("scenario", scenario)
}

///| Group Management

///|
/// Group configuration
pub struct GroupConfig {
  name : String
  tags : Map[String, String]
}

///|
/// Create group config
pub fn GroupConfig::new(name : String) -> GroupConfig {
  { name, tags: Map::new() }
}

///|
/// Add tag to group
pub fn GroupConfig::tag(self : GroupConfig, key : String, value : String) -> GroupConfig {
  let tags = self.tags
  tags.set(key, value)
  { ..self, tags }
}

///|
/// Execute group with config
pub fn[T : Default] GroupConfig::run(
  self : GroupConfig,
  body : () -> T
) -> T {
  // k6's group function doesn't support tags directly
  // But we can use the RequestBuilder tag system
  group(self.name, body)
}

///| Nested Groups

///|
/// Run nested groups with different tags
pub fn[T : Default] nested_group(
  parent_name : String,
  child_name : String,
  body : () -> T
) -> T {
  group(parent_name, fn() {
    group(child_name, body)
  })
}

///|
/// Run multiple groups in sequence
pub fn run_groups(groups : Array[(String, () -> Unit)]) -> Unit {
  groups.each(fn(item) {
    let (name, body) = item
    group(name, body)
  })
}

///| Group Helpers

///|
/// Group for HTTP requests
pub fn http_group(name : String, body : () -> Unit) -> Unit {
  group("HTTP: " + name, body)
}

///|
/// Group for database operations
pub fn db_group(name : String, body : () -> Unit) -> Unit {
  group("DB: " + name, body)
}

///|
/// Group for API calls
pub fn api_group(endpoint : String, body : () -> Unit) -> Unit {
  group("API: " + endpoint, body)
}

///|
/// Group for authentication
pub fn auth_group(body : () -> Unit) -> Unit {
  group("Authentication", body)
}

///|
/// Group for setup operations
pub fn setup_group(body : () -> Unit) -> Unit {
  group("Setup", body)
}

///|
/// Group for cleanup operations
pub fn cleanup_group(body : () -> Unit) -> Unit {
  group("Cleanup", body)
}

///| Conditional Groups

///|
/// Run group only on first iteration
pub fn group_on_first_iteration(name : String, body : () -> Unit) -> Unit {
  if is_first_iteration() {
    group(name, body)
  }
}

///|
/// Run group only on specific VU
pub fn group_on_vu(vu_id : Int, name : String, body : () -> Unit) -> Unit {
  if current_vu() == vu_id {
    group(name, body)
  }
}

///|
/// Run group every N iterations
pub fn group_every_n_iterations(
  n : Int,
  name : String,
  body : () -> Unit
) -> Unit {
  if current_iteration() % n == 0 {
    group(name, body)
  }
}

///| Tagged Requests

///|
/// Execute request with tags
pub fn tagged_request(
  builder : RequestBuilder,
  tags : Map[String, String]
) -> Response {
  let mut tagged_builder = builder
  tags.each(fn(k, v) { tagged_builder = tagged_builder.tag(k, v) })
  tagged_builder.send()
}

///|
/// Execute request in tagged group
pub fn tagged_group_request(
  group_name : String,
  builder : RequestBuilder,
  tags : Map[String, String]
) -> Response {
  let mut result : Response? = None
  group(group_name, fn() {
    result = Some(tagged_request(builder, tags))
  })
  match result {
    Some(r) => r
    None => {
      // This should never happen, but we need to return something
      // Create a dummy response (would need Response::default() in real implementation)
      quick_get("about:blank") // Placeholder
    }
  }
}

///| Metric Tagging

///|
/// Create counter with tags
pub fn create_tagged_counter(name : String, _tags : Map[String, String]) -> Counter {
  // Note: k6 metrics don't support tags in constructor
  // Tags are applied at add() time via request params
  create_counter(name)
}

///|
/// Create rate with tags
pub fn create_tagged_rate(name : String, _tags : Map[String, String]) -> Rate {
  create_rate(name)
}

///|
/// Create trend with tags
pub fn create_tagged_trend(name : String, _tags : Map[String, String]) -> Trend {
  create_trend(name)
}
