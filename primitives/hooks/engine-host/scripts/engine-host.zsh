# engine-host launch wrapper — source LAST in ~/.zshrc (after any agent shell functions).
# Spec: ../HOOK.md. Type the agent's name, nothing else (Josh, 2026-11-12: "I do not want to have to
# remember a shitload of flags"):
#   - on hive each agent gets its standing flags here (claude: --dangerously-skip-permissions), never typed;
#   - anywhere else it is not refused: the same command opens on hive over ssh, in this terminal,
#     starting in hive's home (this machine's folders do not exist there).
# Existing shell functions (e.g. pi, amp) are kept and called through.

_enghost_bin="${0:A:h}/engine-host"
_enghost_agents=(claude codex cursor-agent agent pi amp opencode gemini)
typeset -gA _enghost_flags=(claude --dangerously-skip-permissions codex --dangerously-bypass-approvals-and-sandbox)

# _enghost_launch <name> <runner> [args...]: on hive, standing flags added once; elsewhere, on hive.
_enghost_launch() {
  local name=$1 runner=$2; shift 2
  local -a args=("$@")
  if "$_enghost_bin" check 2>/dev/null; then
    local f=${_enghost_flags[$name]:-}
    [[ -n "$f" && ${args[(Ie)$f]} -eq 0 ]] && args=("$f" "${args[@]}")
    "$runner" "${args[@]}"
  else
    echo "$name runs on hive: opening it there." >&2
    local remote="${(q)name}"
    (( $#args )) && remote+=" ${(j: :)${(q)args[@]}}"
    command ssh -t "${ENGINE_SSH:-hive}" "zsh -ic ${(q)remote}"
  fi
}

for _enghost_name in $_enghost_agents; do
  if (( $+functions[$_enghost_name] )); then
    functions -c "$_enghost_name" "_enghost_orig_$_enghost_name"
    eval "$_enghost_name() { _enghost_launch $_enghost_name _enghost_orig_$_enghost_name \"\$@\"; }"
  elif (( $+commands[$_enghost_name] )); then
    eval "_enghost_cmd_$_enghost_name() { command $_enghost_name \"\$@\"; }"
    eval "$_enghost_name() { _enghost_launch $_enghost_name _enghost_cmd_$_enghost_name \"\$@\"; }"
  elif ! "$_enghost_bin" check 2>/dev/null; then
    # Not installed on this machine, but it runs on hive anyway.
    eval "$_enghost_name() { _enghost_launch $_enghost_name false \"\$@\"; }"
  fi
done
unset _enghost_name
