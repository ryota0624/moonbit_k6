// k6 Test Verification Script
// Verifies that k6 test results match expected values

///|
/// FFI: Node.js APIs
extern "js" fn read_file(path : String) -> String =
  #|(path) => require('fs').readFileSync(path, 'utf8')

///|
extern "js" fn console_log(msg : String) -> Unit =
  #|(msg) => console.log(msg)

///|
extern "js" fn console_error(msg : String) -> Unit =
  #|(msg) => console.error(msg)

///|
extern "js" fn process_exit(code : Int) -> Unit =
  #|(code) => process.exit(code)

///|
/// Data Structures (with derive(FromJson))

// expectations.json structure
struct Expectation {
  metric : String
  path : String
  expected : Double
  type_ : String // "exact", "min", "max" - JSON field is "type_"
} derive(FromJson)

///|
struct ExpectationsFile {
  testName : String
  expectations : Array[Expectation]
} derive(FromJson)

// summary.json structure
// Note: k6 summary.json has metrics directly without "values" nesting

///|
struct Metric {
  count : Double?
  rate : Double?
  passes : Int?
  fails : Int?
  value : Double?
} derive(FromJson)

///|
struct Summary {
  metrics : Map[String, Metric]
} derive(FromJson)

// Failure record

///|
struct Failure {
  metric : String
  expected : Double
  actual : Double
}

///|
/// Main Function
fn run_verification() -> Unit {
  // Read files
  let summary_str = read_file("summary.json")
  let expectations_str = read_file("expectations.json")

  // Parse JSON - for now, just use the unsafe version
  // If parse fails, the program will crash with an error message
  let parse_result = try? @json.parse(summary_str)
  guard parse_result is Ok(json) else {
    console_error("Failed to parse summary.json")
    process_exit(1)
    abort("parse failed")
  }

  let summary : Result[Summary, _] = try? @json.from_json(json)
  guard summary is Ok(summary) else {
    console_error("Failed to deserialize summary.json")
    process_exit(1)
    abort("deserialization failed")
  }

  let parse_result = try? @json.parse(expectations_str)
  guard parse_result is Ok(json) else {
    console_error("Failed to parse expectations.json")
    process_exit(1)
    abort("parse failed")
  }

  let expectations_file : Result[ExpectationsFile, _] = try? @json.from_json(
    json,
  )
  guard expectations_file is Ok(expectations_file) else {
    console_error("Failed to deserialize expectations.json")
    process_exit(1)
    abort("deserialization failed")
  }

  console_log("Verifying test results for: \{expectations_file.testName}")
  console_log("")

  let mut all_passed = true
  let failures = []

  // Check each expectation
  for exp in expectations_file.expectations {
    match get_value_from_summary(summary, exp.path) {
      Some(actual_value) =>
        if check_expectation(exp.type_, exp.expected, actual_value) {
          console_log(
            "✓ \{exp.metric}: \{actual_value} (expected: \{exp.expected})",
          )
        } else {
          all_passed = false
          failures.push({
            metric: exp.metric,
            expected: exp.expected,
            actual: actual_value,
          })
          console_error(
            "✗ \{exp.metric}: \{actual_value} (expected: \{exp.expected})",
          )
        }
      None => {
        console_error(
          "✗ \{exp.metric}: Failed to get value at path: \{exp.path}",
        )
        all_passed = false
      }
    }
  }

  // Output results
  console_log("")
  if all_passed {
    console_log("✅ All expectations passed!")
    process_exit(0)
  } else {
    console_error("❌ \{failures.length()} expectation(s) failed:")
    for failure in failures {
      console_error("  - \{failure.metric}:")
      console_error("      Expected: \{failure.expected}")
      console_error("      Actual:   \{failure.actual}")
    }
    process_exit(1)
  }
}

///|
fn main {
  run_verification()
}

///|
/// Helper Functions

// Get value from Summary using path string
fn get_value_from_summary(summary : Summary, path : String) -> Double? {
  // path format: "metrics.<metric_name>.<field_name>"
  // example: "metrics.http_reqs.count" or "metrics.checks.passes"
  let parts = path.split(".").collect()

  if parts.length() < 3 {
    return None
  }

  // parts[0] = "metrics"
  // parts[1] = metric name (e.g., "http_reqs")
  // parts[2] = field name (e.g., "count")

  let metric_name = parts[1].to_string()
  let field_name = parts[2].to_string()

  match summary.metrics.get(metric_name) {
    Some(metric) =>
      match field_name {
        "count" => metric.count
        "rate" => metric.rate
        "value" => metric.value
        "passes" =>
          match metric.passes {
            Some(p) => Some(p.to_double())
            None => None
          }
        "fails" =>
          match metric.fails {
            Some(f) => Some(f.to_double())
            None => None
          }
        _ => None
      }
    None => None
  }
}

// Check if actual value matches expectation

///|
fn check_expectation(
  type_ : String,
  expected : Double,
  actual : Double,
) -> Bool {
  match type_ {
    "exact" => actual == expected
    "min" => actual >= expected
    "max" => actual <= expected
    _ => {
      console_error("Unknown expectation type: \{type_}")
      false
    }
  }
}
