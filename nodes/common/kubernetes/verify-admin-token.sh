#!/usr/bin/env bash
set -euo pipefail
export KUBECONFIG=${KUBECONFIG:-/run/secrets/kubernetes/configs/admin/kubeconfig}
echo "[+] Verifying admin service account token..."
SECRET_NAME=$(kubectl get serviceaccount admin -n default -o jsonpath='{.secrets[0].name}' 2>/dev/null || true)
if [ -z "$SECRET_NAME" ]; then
  echo "[✗] Admin service account or secret not found."
  exit 1
fi
TOKEN=$(kubectl get secret "$SECRET_NAME" -n default -o jsonpath='{.data.token}' 2>/dev/null | base64 --decode || true)
if [ -z "$TOKEN" ]; then
  echo "[✗] Admin token not found or empty."
  exit 1
fi
echo "[✓] Admin token provisioned successfully:"
echo "$TOKEN"
