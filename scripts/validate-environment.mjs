// Validate .cursor/environment.json against Cursor's published environment
// schema (https://cursor.com/schemas/environment.schema.json, linked from
// https://cursor.com/docs/cloud-agent/setup).
//
// The schema is JSON Schema draft 2019-09 with unevaluatedProperties: false,
// so this file uses Ajv's 2019 dialect — not the draft-07 Ajv used for the
// plugin/marketplace manifests.
//
// Expects environment.schema.json in the working directory (CI fetches it at
// run time so an upstream contract change surfaces here).
//
// Usage: node scripts/validate-environment.mjs
// Exit:  0 valid, 1 otherwise.

import { readFileSync, existsSync } from "node:fs";
import Ajv2019 from "ajv/dist/2019.js";
import addFormats from "ajv-formats";

const schemaPath = "environment.schema.json";
const doc = ".cursor/environment.json";

if (!existsSync(schemaPath)) {
  console.error(`::error::schema not found: ${schemaPath}`);
  process.exit(1);
}
if (!existsSync(doc)) {
  console.error(`::error::environment file not found: ${doc}`);
  process.exit(1);
}

const ajv = new Ajv2019({ strict: false, allErrors: true });
addFormats(ajv);
const validate = ajv.compile(JSON.parse(readFileSync(schemaPath, "utf8")));
if (validate(JSON.parse(readFileSync(doc, "utf8")))) {
  console.log(`PASS  ${doc}  (${schemaPath})`);
  process.exit(0);
}

console.log(`FAIL  ${doc}  (${schemaPath})`);
for (const e of validate.errors ?? []) {
  const where = e.instancePath || "/";
  const extra = e.params ? ` ${JSON.stringify(e.params)}` : "";
  console.error(`::error file=${doc}::${where} ${e.message}${extra}`);
}
process.exit(1);
