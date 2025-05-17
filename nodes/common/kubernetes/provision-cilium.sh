#!/usr/bin/env bash
set -euo pipefail
CILIUM_VERSION="1.17.3"
CILIUM_MANIFEST_URL="https://github.com/cilium/cilium/releases/download/v${CILIUM_VERSION}/cilium.yaml"
CILIUM_MANIFEST="cilium.yaml"
# Ensure kubectl is available
if ! command -v kubectl &>/dev/null; then
  echo "kubectl not found. Please install kubectl first."
  exit 1
fi
# Download the official Cilium DaemonSet manifest
echo "[+] Downloading Cilium DaemonSet manifest v${CILIUM_VERSION}..."
curl -L --fail -o "${CILIUM_MANIFEST}" "${CILIUM_MANIFEST_URL}"
# Apply the manifest
echo "[+] Applying Cilium manifest to Kubernetes..."
kubectl apply -f "${CILIUM_MANIFEST}"
# Wait for Cilium pods to become ready
echo "[+] Waiting for Cilium pods to become ready..."
kubectl -n kube-system rollout status daemonset cilium
# Confirm status
echo "[+] Cilium pods status:"
kubectl -n kube-system get pods -l k8s-app=cilium
# Quick health check
echo "[+] Running Cilium connectivity test..."
kubectl -n kube-system exec ds/cilium -- cilium status --verbose
# Cleanup manifest
echo "[+] Cleaning up downloaded manifest file."
rm -f "${CILIUM_MANIFEST}"
# Success message
echo "[+] Cilium v${CILIUM_VERSION} successfully deployed."
