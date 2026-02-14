#!/usr/bin/env node
// Post-build script to make MoonBit output k6-compatible

import { readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const scriptPath = join(__dirname, '../dist/script.js');

// Read the generated file
let content = readFileSync(scriptPath, 'utf-8');

// Replace the export statement to call options() immediately
// From: export { optionsFn as options, defaultFn as default }
// To:   const __options = optionsFn(); export { __options as options, defaultFn as default }

const exportMatch = content.match(/export \{ (.+) as options, (.+) as default \}/);
if (exportMatch) {
  const optionsFn = exportMatch[1];
  const defaultFn = exportMatch[2];

  // Replace the export
  content = content.replace(
    /export \{ .+ as options, .+ as default \}/,
    `const __options = ${optionsFn}();\nexport { __options as options, ${defaultFn} as default }`
  );

  writeFileSync(scriptPath, content);
  console.log('✓ Converted options to object for k6 compatibility');
} else {
  console.warn('⚠ Could not find options export, skipping conversion');
}
