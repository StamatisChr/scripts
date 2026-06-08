#!/usr/bin/env bash
set -euo pipefail

tfe_hostname="${1:-}"
tfe_version_image="${2:-}"

if [[ -z "$tfe_hostname" || -z "$tfe_version_image" ]]; then
    echo "Usage: $0 <tfe_hostname> <tfe_version_image>" >&2
    exit 1
fi

tfe_version() {
    [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]
}

if [[ "$tfe_version_image" != v* ]] && tfe_version "$tfe_version_image" "2.0.0"; then
    health_url="https://${tfe_hostname}/api/v1/health/readiness"
    while true; do
        body="$(curl -fsS "$health_url" 2>/dev/null || true)"
        if echo "$body" | jq -e '.status == "OK"' >/dev/null 2>&1; then
            break
        fi
        pending="$(echo "$body" | jq -r '[.checks[]? | select(.status != "OK") | .check] | join(", ")' 2>/dev/null || true)"
        echo "$(date +"%Y-%m-%d %H:%M:%S") Waiting for TFE...${pending:+ pending: $pending}"
        sleep 20
    done
else
    health_url="https://${tfe_hostname}/_health_check"
    while [[ "$(curl -fsS "$health_url" 2>/dev/null || true)" != "OK" ]]; do
        echo "$(date +"%Y-%m-%d %H:%M:%S") Waiting for TFE to start..."
        sleep 20
    done
fi

echo "$(date +"%Y-%m-%d %H:%M:%S") TFE is up."
