#!/usr/bin/env bash
set -euo pipefail

echo "[User-level GPG decryption]"
sops -d secrets.yaml >/dev/null
echo "✓ GPG decryption OK"

echo "[Host-level AGE decryption]"
SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt sops -d secrets.yaml >/dev/null
echo "✓ Age decryption OK"
