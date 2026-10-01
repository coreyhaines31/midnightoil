#!/usr/bin/env node
// Issues a Midnight Oil for Teams license key by hand (comps, testing, support).
// The Teams service issues keys automatically; this uses the same format.
//
//   node ee/Scripts/issue-license.mjs --name "Acme, Inc." --seats 10 --days 395 [--org org_123]
//
// Reads the Ed25519 private key (PKCS8, base64) from LICENSE_SIGNING_KEY, or from the
// macOS keychain item "midnightoil-license-signing".
import { createPrivateKey, randomUUID, sign } from "node:crypto";
import { execFileSync } from "node:child_process";
import { parseArgs } from "node:util";

const { values } = parseArgs({
  options: {
    name: { type: "string" },
    seats: { type: "string", default: "5" },
    days: { type: "string", default: "395" },
    org: { type: "string" },
    features: { type: "string", default: "policies,webhook,fleet" },
  },
});
if (!values.name) {
  console.error('Usage: issue-license.mjs --name "Acme, Inc." [--seats 10] [--days 395] [--org id]');
  process.exit(1);
}

const secret =
  process.env.LICENSE_SIGNING_KEY ??
  execFileSync("security", ["find-generic-password", "-s", "midnightoil-license-signing", "-w"]).toString().trim();
const privateKey = createPrivateKey({ key: Buffer.from(secret, "base64"), format: "der", type: "pkcs8" });

// Whole seconds: the app's ISO 8601 parser rejects fractional seconds.
const exp = new Date(Date.now() + Number(values.days) * 86_400_000).toISOString().replace(/\.\d{3}Z$/, "Z");
const payload = {
  v: 1,
  org: values.org ?? `org_${randomUUID()}`,
  name: values.name,
  seats: Number(values.seats),
  exp,
  features: values.features.split(","),
};
const body = Buffer.from(JSON.stringify(payload)).toString("base64url");
const signature = sign(null, Buffer.from(body), privateKey).toString("base64url");
console.log(`MO1-${body}.${signature}`);
