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
    use_status_check=true
else
    health_url="https://${tfe_hostname}/_health_check"
    use_status_check=false
fi

while true; do
    if $use_status_check; then
        curl -fsS -o /dev/null "$health_url" && break
    else
        [[ "$(curl -fsS "$health_url" || true)" == "OK" ]] && break
    fi
    echo "$(date +"%Y-%m-%d %H:%M:%S") Waiting for TFE to start..."
    sleep 20
done

echo "$(date +"%Y-%m-%d %H:%M:%S") TFE is up."
