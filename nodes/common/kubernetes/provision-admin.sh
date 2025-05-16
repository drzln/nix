#!/usr/bin/env bash
set -euo pipefail
export KUBECONFIG=/run/secrets/kubernetes/configs/admin/kubeconfig
HOSTNAME=$(hostname)
echo "[+] Creating Kubernetes service account 'admin'..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: default
EOF
echo "[+] Binding cluster-admin role to 'admin' service account..."
kubectl create clusterrolebinding admin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=default:admin \
  --dry-run=client -o yaml | ${pkgs.kubernetes}/bin/kubectl apply -f -
echo "[✓] Admin service account provisioned successfully."
