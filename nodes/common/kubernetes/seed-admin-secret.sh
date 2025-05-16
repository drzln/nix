#!/usr/bin/env bash
set -euo pipefail
export KUBECONFIG=${KUBECONFIG:-/run/secrets/kubernetes/configs/admin/kubeconfig}
SECRET_YAML=${1:-admin-secret.yaml}
echo "[+] Seeding Kubernetes admin secret..."
kubectl apply -f "$SECRET_YAML"
echo "[+] Binding cluster-admin role to 'admin' service account..."
kubectl create clusterrolebinding admin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=default:admin \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[✓] Admin secret seeded and role binding complete."
