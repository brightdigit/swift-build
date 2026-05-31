#!/bin/bash
# Calculate the Xcode scheme for a Swift package.
# Prints ONLY the scheme name to stdout; warnings/errors go to stderr.
#
# Derivation (BrightDigit convention):
#   - 1 product            -> that product's name
#   - >1 products          -> "<packageName>-Package"
#   - 0 products, has name -> "<packageName>-Package"
# Fallback (only if the above yields nothing): xcodebuild -list -json,
# picking the first scheme that ends in "-Package".
#
# Optional env var WORKING_DIRECTORY: if set and non-empty, cd into it first.
# Exits 0 on success, 1 if no scheme could be determined.

set -euo pipefail

if [ -n "${WORKING_DIRECTORY:-}" ]; then
  cd "$WORKING_DIRECTORY"
fi

SCHEME=""

# Primary: derive from the Swift package manifest.
if PACKAGE_JSON=$(swift package dump-package 2>/dev/null); then
  SCHEME=$(printf '%s' "$PACKAGE_JSON" | jq -r 'if (.products|length)==1 then .products[0].name elif (.products|length)>1 then "\(.name)-Package" elif (.name // "")!="" then "\(.name)-Package" else empty end')
else
  echo "warning: 'swift package dump-package' failed; trying 'xcodebuild -list' fallback" >&2
fi

# Fallback: only if no scheme was derived above.
if [ -z "$SCHEME" ]; then
  SCHEMES_JSON=$(xcodebuild -list -json 2>/dev/null || true)
  if [ -n "$SCHEMES_JSON" ]; then
    SCHEME=$(printf '%s' "$SCHEMES_JSON" | jq -r '((.project // .workspace // {}).schemes // []) | map(select(endswith("-Package"))) | .[0] // empty')
  fi
fi

if [ -z "$SCHEME" ]; then
  echo "ERROR: Could not auto-calculate an Xcode scheme. Provide the 'scheme' input explicitly." >&2
  exit 1
fi

printf '%s\n' "$SCHEME"
