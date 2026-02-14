// k6 Checks Helper
// Type-safe check functions for k6

///| Check Builders

///|
/// Create a check for HTTP response status
pub fn check_status(res : Response, expected : Int) -> Bool {
  let checks = Map::new()
  checks.set("status is " + expected.to_string(), fn(r : @core.Any) -> Bool {
    let response : Response = r.cast()
    response.status == expected
  })
  check(@core.any(res), checks)
}

///|
/// Create a check for HTTP response status in range
pub fn check_status_range(res : Response, min : Int, max : Int) -> Bool {
  let checks = Map::new()
  let desc = "status is " + min.to_string() + "-" + max.to_string()
  checks.set(desc, fn(r : @core.Any) -> Bool {
    let response : Response = r.cast()
    response.status >= min && response.status <= max
  })
  check(@core.any(res), checks)
}

///|
/// Check if response status is 2xx (success)
pub fn check_status_ok(res : Response) -> Bool {
  check_status_range(res, 200, 299)
}

///|
/// Check if response status is 200
pub fn check_status_200(res : Response) -> Bool {
  check_status(res, 200)
}

///|
/// Check if response status is 201
pub fn check_status_201(res : Response) -> Bool {
  check_status(res, 201)
}

///|
/// Check if response status is 204
pub fn check_status_204(res : Response) -> Bool {
  check_status(res, 204)
}

///|
/// Check if response status is 400
pub fn check_status_400(res : Response) -> Bool {
  check_status(res, 400)
}

///|
/// Check if response status is 404
pub fn check_status_404(res : Response) -> Bool {
  check_status(res, 404)
}

///|
/// Check if response status is 500
pub fn check_status_500(res : Response) -> Bool {
  check_status(res, 500)
}

///|
/// Create a check for response body contains text
pub fn check_body_contains(res : Response, text : String) -> Bool {
  let checks = Map::new()
  checks.set("body contains '" + text + "'", fn(r : @core.Any) -> Bool {
    let response : Response = r.cast()
    // Simple contains check (MoonBit String should have contains method)
    response.body.contains(text)
  })
  check(@core.any(res), checks)
}

///|
/// Check response with custom condition
pub fn check_response(
  res : Response,
  name : String,
  condition : (Response) -> Bool
) -> Bool {
  let checks = Map::new()
  checks.set(name, fn(r : @core.Any) -> Bool {
    let response : Response = r.cast()
    condition(response)
  })
  check(@core.any(res), checks)
}

///| Multiple Checks

///|
/// Run multiple checks on a response
pub fn check_all(res : Response, checks_list : Array[(String, (Response) -> Bool)]) -> Bool {
  let checks = Map::new()
  checks_list.each(fn(item) {
    let (name, condition) = item
    checks.set(name, fn(r : @core.Any) -> Bool {
      let response : Response = r.cast()
      condition(response)
    })
  })
  check(@core.any(res), checks)
}

///| Generic Checks

///|
/// Check any value with custom condition
pub fn[T] check_value(
  val : T,
  name : String,
  condition : (T) -> Bool
) -> Bool {
  let checks = Map::new()
  checks.set(name, fn(v : @core.Any) -> Bool {
    let value : T = v.cast()
    condition(value)
  })
  check(@core.any(val), checks)
}

///|
/// Check if value equals expected
pub fn[T : Eq] check_equals(val : T, expected : T, name : String) -> Bool {
  check_value(val, name, fn(v) { v == expected })
}

///|
/// Check if value is greater than threshold
pub fn[T : Compare] check_greater(val : T, threshold : T, name : String) -> Bool {
  check_value(val, name, fn(v) { v.compare(threshold) > 0 })
}

///|
/// Check if value is less than threshold
pub fn[T : Compare] check_less(val : T, threshold : T, name : String) -> Bool {
  check_value(val, name, fn(v) { v.compare(threshold) < 0 })
}
