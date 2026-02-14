// k6 options MoonBit Facade
// Test configuration options for k6

///| Options Type

///|
/// Test options configuration
pub struct Options {
  vus : Int?
  duration : String?
  iterations : Int?
  stages : Array[@core.Any]?
  thresholds : Map[String, Array[String]]?
  scenarios : Map[String, @core.Any]?
  tags : Map[String, String]?
  no_connection_reuse : Bool?
  user_agent : String?
}

///|
/// Create default Options
pub fn Options::default() -> Options {
  {
    vus: None,
    duration: None,
    iterations: None,
    stages: None,
    thresholds: None,
    scenarios: None,
    tags: None,
    no_connection_reuse: None,
    user_agent: None,
  }
}

///|
/// Convert Options to JS object
pub fn Options::to_js(self : Options) -> @core.Any {
  let obj = @core.new_object()

  match self.vus {
    Some(v) => obj["vus"] = @core.any(v)
    None => ()
  }

  match self.duration {
    Some(d) => obj["duration"] = @core.any(d)
    None => ()
  }

  match self.iterations {
    Some(i) => obj["iterations"] = @core.any(i)
    None => ()
  }

  match self.stages {
    Some(s) => obj["stages"] = @core.any(s)
    None => ()
  }

  match self.thresholds {
    Some(t) => {
      let thresholds_obj = @core.new_object()
      t.each(fn(metric, conditions) {
        // Convert MoonBit array to JS array via @core.any
        thresholds_obj[metric] = @core.any(conditions)
      })
      obj["thresholds"] = @core.any(thresholds_obj)
    }
    None => ()
  }

  match self.scenarios {
    Some(s) => {
      let scenarios_obj = @core.new_object()
      s.each(fn(name, config) { scenarios_obj[name] = config })
      obj["scenarios"] = @core.any(scenarios_obj)
    }
    None => ()
  }

  match self.tags {
    Some(t) => {
      let tags_obj = @core.new_object()
      t.each(fn(key, value) { tags_obj[key] = @core.any(value) })
      obj["tags"] = @core.any(tags_obj)
    }
    None => ()
  }

  match self.no_connection_reuse {
    Some(n) => obj["noConnectionReuse"] = @core.any(n)
    None => ()
  }

  match self.user_agent {
    Some(u) => obj["userAgent"] = @core.any(u)
    None => ()
  }

  @core.any(obj)
}

///| Builder Pattern

///|
/// Set VUs (virtual users)
pub fn Options::vus(self : Options, vus : Int) -> Options {
  { ..self, vus: Some(vus) }
}

///|
/// Set duration
pub fn Options::duration(self : Options, duration : String) -> Options {
  { ..self, duration: Some(duration) }
}

///|
/// Set iterations
pub fn Options::iterations(self : Options, iterations : Int) -> Options {
  { ..self, iterations: Some(iterations) }
}

///|
/// Set thresholds
pub fn Options::thresholds(
  self : Options,
  thresholds : Map[String, Array[String]]
) -> Options {
  { ..self, thresholds: Some(thresholds) }
}

///|
/// Set tags
pub fn Options::tags(self : Options, tags : Map[String, String]) -> Options {
  { ..self, tags: Some(tags) }
}

///|
/// Set user agent
pub fn Options::user_agent(self : Options, user_agent : String) -> Options {
  { ..self, user_agent: Some(user_agent) }
}

///| Stage Type

///|
/// Load test stage configuration
pub struct Stage {
  duration : String
  target : Int
}

///|
/// Create a new Stage
pub fn Stage::new(duration : String, target : Int) -> Stage {
  { duration, target }
}

///|
/// Convert Stage to JS object
pub fn Stage::to_js(self : Stage) -> @core.Any {
  let obj = @core.new_object()
  obj["duration"] = @core.any(self.duration)
  obj["target"] = @core.any(self.target)
  @core.any(obj)
}

///| Scenario Type

///|
/// Scenario configuration
pub struct Scenario {
  executor : String
  vus : Int?
  iterations : Int?
  duration : String?
  start_time : String?
  graceful_stop : String?
  exec : String?
}

///|
/// Create default Scenario
pub fn Scenario::default() -> Scenario {
  {
    executor: "shared-iterations",
    vus: None,
    iterations: None,
    duration: None,
    start_time: None,
    graceful_stop: None,
    exec: None,
  }
}

///|
/// Set executor type
pub fn Scenario::executor(self : Scenario, executor : String) -> Scenario {
  { ..self, executor }
}

///|
/// Set VUs for scenario
pub fn Scenario::vus(self : Scenario, vus : Int) -> Scenario {
  { ..self, vus: Some(vus) }
}

///|
/// Set iterations for scenario
pub fn Scenario::iterations(self : Scenario, iterations : Int) -> Scenario {
  { ..self, iterations: Some(iterations) }
}

///|
/// Set duration for scenario
pub fn Scenario::duration(self : Scenario, duration : String) -> Scenario {
  { ..self, duration: Some(duration) }
}

///|
/// Convert Scenario to JS object
pub fn Scenario::to_js(self : Scenario) -> @core.Any {
  let obj = @core.new_object()
  obj["executor"] = @core.any(self.executor)

  match self.vus {
    Some(v) => obj["vus"] = @core.any(v)
    None => ()
  }

  match self.iterations {
    Some(i) => obj["iterations"] = @core.any(i)
    None => ()
  }

  match self.duration {
    Some(d) => obj["duration"] = @core.any(d)
    None => ()
  }

  match self.start_time {
    Some(s) => obj["startTime"] = @core.any(s)
    None => ()
  }

  match self.graceful_stop {
    Some(g) => obj["gracefulStop"] = @core.any(g)
    None => ()
  }

  match self.exec {
    Some(e) => obj["exec"] = @core.any(e)
    None => ()
  }

  @core.any(obj)
}
