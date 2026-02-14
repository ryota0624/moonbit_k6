# k6 MoonBit Example

This example demonstrates how to write k6 load tests in MoonBit.

## Prerequisites

- [MoonBit](https://www.moonbitlang.com/) installed
- Node.js and npm/pnpm
- Docker and Docker Compose

## Setup

1. Install dependencies:

```bash
npm install
# or
pnpm install
```

2. Build the MoonBit script:

```bash
npm run build
# or
pnpm build
```

This will:
1. Compile `src/script.mbt` to JavaScript with MoonBit
2. Copy the output to `dist/script.js`
3. Post-process to convert to k6-compatible format (`export default` and `export options`)

## Running the Load Test

### With Docker Compose

The easiest way to run the example:

```bash
docker-compose up
```

This will:
1. Start a simple nginx server on port 8080
2. Run the k6 load test against the server
3. Display the test results

### Locally (without Docker)

1. Start a local server (or use any HTTP server):

```bash
# Start the test server
cd server && python -m http.server 8080
```

2. Run k6 with the built script:

```bash
k6 run dist/script.js
```

## Script Structure

The MoonBit script (`src/script.mbt`) demonstrates:

- Importing the k6 library with `@k6` alias
- Defining test options as a JavaScript object (exported for k6)
- Using k6 global functions (group, sleep, env, vu, iter)
- Structuring a basic load test
- Type-safe API calls with MoonBit

### How it works

1. **MoonBit code**: Written in type-safe MoonBit
2. **Compilation**: `moon build --target js` compiles to JavaScript
3. **Post-processing**: `scripts/post-build.js` converts the output to k6 format:
   - Converts `options` function to object: `const __options = options()`
   - Exports in k6-compatible format: `export { __options as options, default }`

## Customization

### Test Options

Edit the `options` in `src/script.mbt`:

```moonbit
pub let options : Options = {
  vus: 10,        // Number of virtual users
  duration: "30s" // Test duration
}
```

### Test URL

Set the `TEST_URL` environment variable:

```bash
TEST_URL=http://example.com k6 run dist/script.js
```

Or in `docker-compose.yml`:

```yaml
environment:
  - TEST_URL=http://your-server.com
```

## Next Steps

- Add HTTP requests when `k6/http` module is implemented
- Add custom metrics
- Add more complex test scenarios
- Implement checks and thresholds
