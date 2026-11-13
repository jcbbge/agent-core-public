# Human launch policy is configured in rexconfig profiles and implemented by teerex.
# Source last so native profile functions replace earlier agent-name wrappers.
eval "$(teerex agents shell --config "${TEEREX_PROFILES:-$HOME/.config/teerex/profiles.json}")"
