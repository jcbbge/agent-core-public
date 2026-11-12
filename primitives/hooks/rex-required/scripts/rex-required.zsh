# rex-required launch wrapper — source LAST in ~/.zshrc (after any agent shell functions).
# Spec: ../HOOK.md. Type the agent's name, nothing else (Josh, 2026-11-12: "I do not want to have to
# remember a shitload of flags"):
#   - each agent gets its standing flags here (claude: --dangerously-skip-permissions), never typed;
#   - outside a Rex pane it is not refused: it opens itself in a new Rex tab, the same command.
# Existing shell functions (e.g. pi, amp) are kept and called through.

_rexreq_bin="${0:A:h}/rex-required"
_rexreq_agents=(claude codex cursor-agent agent pi amp opencode gemini)
typeset -gA _rexreq_flags=(claude --dangerously-skip-permissions codex --dangerously-bypass-approvals-and-sandbox)

# _rexreq_launch <name> <runner> [args...]: standing flags added once, in this pane or a new Rex tab.
_rexreq_launch() {
  local name=$1 runner=$2; shift 2
  local -a args=("$@")
  local f=${_rexreq_flags[$name]:-}
  [[ -n "$f" && ${args[(Ie)$f]} -eq 0 ]] && args=("$f" "${args[@]}")
  if "$_rexreq_bin" check 2>/dev/null; then
    "$runner" "${args[@]}"
  elif command -v rex >/dev/null 2>&1 && rex run -- zsh -ic "${(j: :)${(q)name}} ${(j: :)${(q)args[@]}}" >/dev/null; then
    echo "$name opened in a new Rex tab."
  else
    "$_rexreq_bin" check   # prints why, and how to start it in Rex
  fi
}

for _rexreq_name in $_rexreq_agents; do
  if (( $+functions[$_rexreq_name] )); then
    functions -c "$_rexreq_name" "_rexreq_orig_$_rexreq_name"
    eval "$_rexreq_name() { _rexreq_launch $_rexreq_name _rexreq_orig_$_rexreq_name \"\$@\"; }"
  elif (( $+commands[$_rexreq_name] )); then
    eval "_rexreq_cmd_$_rexreq_name() { command $_rexreq_name \"\$@\"; }"
    eval "$_rexreq_name() { _rexreq_launch $_rexreq_name _rexreq_cmd_$_rexreq_name \"\$@\"; }"
  fi
done
unset _rexreq_name
