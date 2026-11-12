/**
 * rex-required — pi extension. Spec: ../HOOK.md
 * Delegates every tool call to the shared `rex-required hook claude` script so the
 * rule lives in one place; blocks only when the script returns a deny decision.
 */
import { spawnSync } from "node:child_process";
import { dirname, join } from "node:path";
import { realpathSync } from "node:fs";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const SCRIPT =
  process.env.REX_REQUIRED_BIN ??
  join(dirname(realpathSync(fileURLToPath(import.meta.url))), "rex-required");

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    const input = JSON.stringify({ tool_name: event.toolName, tool_input: event.input ?? {} });
    const r = spawnSync(SCRIPT, ["hook", "claude"], { input, encoding: "utf8", timeout: 5000 });
    if (r.status !== 0 || !r.stdout) return undefined; // own failure allows
    try {
      const out = JSON.parse(r.stdout)?.hookSpecificOutput;
      if (out?.permissionDecision === "deny") {
        ctx.ui.notify?.(out.permissionDecisionReason, "warn");
        return { block: true, reason: out.permissionDecisionReason };
      }
    } catch {
      /* own failure allows */
    }
    return undefined;
  });
}
