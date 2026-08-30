// Validate this repository's Cursor manifests against Cursor's PUBLISHED JSON
// schemas.
//
// The schemas are the authority, not the prose reference. The two disagree in
// both directions: the reference page's "Plugin entry fields" table lists ~16
// keys that marketplace.schema.json forbids (the plugin entry is
// additionalProperties: false with only name/source/description/
// minClientVersions), and its "Marketplace manifest fields" table marks `owner`
// required where the schema's required array is only ["name","plugins"]. A
// checklist derived from the prose would therefore pass files a validator
// rejects, and vice versa.
//
// Expects marketplace.schema.json and plugin.schema.json in the working
// directory (CI fetches them at run time so a schema change upstream surfaces
// here rather than going unnoticed).
//
// Usage: node scripts/validate-manifests.mjs
// Exit:  0 all manifests valid, 1 otherwise.

import { readFileSync, existsSync } from "node:fs";
import { globSync } from "node:fs";
import Ajv from "ajv";
import addFormats from "ajv-formats";

const readJson = (path) => JSON.parse(readFileSync(path, "utf8"));

const targets = [
  { schema: "marketplace.schema.json", doc: ".cursor-plugin/marketplace.json" },
  ...globSync("plugins/*/.cursor-plugin/plugin.json").map((doc) => ({
    schema: "plugin.schema.json",
    doc,
  })),
];

let failed = 0;

for (const { schema, doc } of targets) {
  if (!existsSync(schema)) {
    console.error(`::error::schema not found: ${schema}`);
    failed = 1;
    continue;
  }
  if (!existsSync(doc)) {
    console.error(`::error::manifest not found: ${doc}`);
    failed = 1;
    continue;
  }

  // strict:false — Cursor's schemas use keywords Ajv's strict mode rejects;
  // that is a property of their authoring, not of our manifests.
  const ajv = new Ajv({ strict: false, allErrors: true });
  addFormats(ajv);

  const validate = ajv.compile(readJson(schema));
  if (validate(readJson(doc))) {
    console.log(`PASS  ${doc}  (${schema})`);
    continue;
  }

  failed = 1;
  console.log(`FAIL  ${doc}  (${schema})`);
  for (const e of validate.errors) {
    const where = e.instancePath || "/";
    const extra = e.params ? ` ${JSON.stringify(e.params)}` : "";
    console.error(`::error file=${doc}::${where} ${e.message}${extra}`);
  }
}

process.exit(failed);
