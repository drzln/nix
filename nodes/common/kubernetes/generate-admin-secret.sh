#!/usr/bin/env bash
set -euo pipefail
TOKEN_PATH=${1:?Usage: $0 <token-file-path>}
TOKEN=$(base64 -w0 < "$TOKEN_PATH")
cat > admin-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: admin-token
  namespace: default
  annotations:
    kubernetes.io/service-account.name: admin
type: kubernetes.io/service-account-token
data:
  token: $TOKEN
EOF
echo "[✓] admin-secret.yaml generated successfully."
