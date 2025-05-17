#!/usr/bin/env bash
set -euo pipefail

# Variables
CILIUM_VERSION="1.17.3"
CILIUM_NAMESPACE="kube-system"
CILIUM_RELEASE_NAME="cilium"

# Check for kubectl
if ! command -v kubectl &>/dev/null; then
  echo "kubectl not found. Install kubectl first."
  exit 1
fi

# Check for helm
if ! command -v helm &>/dev/null; then
  echo "Helm not found. Install Helm first."
  exit 1
fi

# Add Cilium Helm repo and update
helm repo add cilium https://helm.cilium.io/
helm repo update

# Install or Upgrade Cilium
helm upgrade --install "$CILIUM_RELEASE_NAME" cilium/cilium \
  --version "$CILIUM_VERSION" \
  --namespace "$CILIUM_NAMESPACE" \
  --set kubeProxyReplacement=strict \
  --set k8sServiceHost=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}' | sed 's|https://||; s|:.*||') \
  --set k8sServicePort=6443 \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true

# Wait for deployment to be ready
echo "[+] Waiting for Cilium DaemonSet rollout..."
kubectl -n "$CILIUM_NAMESPACE" rollout status daemonset "$CILIUM_RELEASE_NAME"

# Show pods
echo "[+] Current Cilium pods:"
kubectl -n "$CILIUM_NAMESPACE" get pods -l k8s-app=cilium

# Check Cilium status
echo "[+] Running Cilium status check:"
kubectl -n "$CILIUM_NAMESPACE" exec ds/$CILIUM_RELEASE_NAME -- cilium status --verbose

# Verify connectivity with Hubble
if helm get values "$CILIUM_RELEASE_NAME" -n "$CILIUM_NAMESPACE" | grep -q 'hubble.relay.enabled: true'; then
  echo "[+] Running Hubble connectivity test:"
  cilium connectivity test
fi

echo "[+] Cilium v$CILIUM_VERSION deployed successfully."
