# rex-required launch wrapper — source LAST in ~/.zshrc (after any agent shell functions).
# Spec: ../HOOK.md. Wraps each agent command so launching it outside a Rex pane is refused.
# Existing shell functions (e.g. pi, amp) are kept and called through.

_rexreq_bin="${0:A:h}/rex-required"
_rexreq_agents=(claude codex cursor-agent agent pi amp opencode gemini)

for _rexreq_name in $_rexreq_agents; do
  if (( $+functions[$_rexreq_name] )); then
    functions -c "$_rexreq_name" "_rexreq_orig_$_rexreq_name"
    eval "$_rexreq_name() { \"\$_rexreq_bin\" check || return 1; _rexreq_orig_$_rexreq_name \"\$@\"; }"
  elif (( $+commands[$_rexreq_name] )); then
    eval "$_rexreq_name() { \"\$_rexreq_bin\" check || return 1; command $_rexreq_name \"\$@\"; }"
  fi
done
unset _rexreq_name
