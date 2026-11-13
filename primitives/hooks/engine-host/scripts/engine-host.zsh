# Human launch policy is configured in rexconfig profiles and implemented by teerex.
# Source last so native profile functions replace earlier agent-name wrappers.
if _enghost_functions=$(teerex agents shell --config "${TEEREX_PROFILES:-$HOME/.config/teerex/profiles.json}"); then
  eval "$_enghost_functions"
else
  print -u2 'teerex human launch functions unavailable; check rexconfig profiles.'
fi
unset _enghost_functions
