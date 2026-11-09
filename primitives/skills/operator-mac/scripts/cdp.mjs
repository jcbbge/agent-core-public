#!/usr/bin/env node
// cdp.mjs — run the JavaScript on stdin against the operator's Mac Chrome over CDP.
// In scope: browser, context, page (a fresh tab). KEEP=1 leaves the tab open.
import { createRequire } from "node:module";
import { execSync } from "node:child_process";
import { join } from "node:path";

const require = createRequire(import.meta.url);
let playwright;
try {
  playwright = require("playwright");
} catch {
  playwright = require(join(execSync("npm root -g").toString().trim(), "playwright"));
}

const url = process.env.CDP_URL || "http://127.0.0.1:9222";
const code = await new Promise((resolve) => {
  let s = "";
  process.stdin.on("data", (d) => (s += d)).on("end", () => resolve(s));
});

// With every window closed, Chrome refuses Playwright's attach; open a blank tab first, then retry.
let blank = null;
const attach = () => playwright.chromium.connectOverCDP(url);
const browser = await attach().catch(async () => {
  blank = await fetch(url + '/json/new?about:blank', { method: 'PUT' }).then((r) => r.json());
  return attach();
});
const context = browser.contexts()[0] ?? (await browser.newContext());
const page = await context.newPage();
try {
  const AsyncFunction = Object.getPrototypeOf(async () => {}).constructor;
  await new AsyncFunction("browser", "context", "page", code)(browser, context, page);
} catch (e) {
  console.error(e.message);
  process.exitCode = 1;
} finally {
  if (!process.env.KEEP) await page.close();
  if (blank) await fetch(url + '/json/close/' + blank.id).catch(() => {});
  await browser.close(); // disconnects only; the operator's Chrome keeps running
}
