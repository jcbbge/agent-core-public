#!/usr/bin/env bash
# shell-code-only — the one place that separates shell CODE from shell DATA.
#
# Every command-matching hook has the same job before it matches anything: look
# only at what the shell would EXECUTE, never at what it would pass along as
# text. Miss that and the hook blocks prose — a commit message, a doc, a grep,
# a heredoc — that merely mentions the verb it guards.
#
# Source it, do not re-implement it:
#   . "$(dirname "$0")/shell-code-only.sh"
#   CODE=$(shell_code_only "$CMD")
#
# Ordering is load-bearing. Heredoc bodies go FIRST, while real newlines are
# still real newlines — a heredoc quotes by delimiter, not around its text, so
# nothing downstream can recognise it once lines are flattened.

# Drop heredoc bodies, keeping the command lines around them.
# An unterminated heredoc keeps its pending text: better to over-match and
# refuse than to silently blind the guard that called us.
strip_heredoc_bodies() {
  local raw="$1" out="" pending="" delim="" dash=0 active=0 line cmp
  local heredoc_re="<<(-)?['\"]?([A-Za-z_][A-Za-z0-9_]*)['\"]?"
  while IFS= read -r line || [ -n "$line" ]; do
    if [ "$active" -eq 1 ]; then
      pending="$pending$line"$'\n'
      cmp="$line"
      if [ "$dash" -eq 1 ]; then
        while [ "${cmp:0:1}" = $'\t' ]; do cmp="${cmp:1}"; done
      fi
      if [ "$cmp" = "$delim" ]; then
        active=0
        pending=""
      fi
      continue
    fi
    out="$out$line"$'\n'
    if [[ "$line" =~ $heredoc_re ]]; then
      dash=0
      [ -n "${BASH_REMATCH[1]}" ] && dash=1
      delim="${BASH_REMATCH[2]}"
      active=1
      pending=""
    fi
  done <<< "$raw"
  [ "$active" -eq 1 ] && out="$out$pending"
  printf '%s' "$out"
}

# Heredoc bodies, then single-quoted, double-quoted and BACKTICKED segments.
# Backticks matter because prose about a command habitually wraps it in them,
# and that is exactly the text a commit message or a directive carries.
shell_code_only() {
  strip_heredoc_bodies "$1" \
    | tr '\n' ' ' \
    | sed -e "s/'[^']*'//g" -e 's/"[^"]*"//g' -e 's/`[^`]*`//g'
}
