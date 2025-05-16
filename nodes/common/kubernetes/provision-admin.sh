#!/usr/bin/env bash
set -euo pipefail

KUBECTL="${KUBECTL:-kubectl}"

# Ensure KUBECONFIG is set
export KUBECONFIG=${KUBECONFIG:-/run/secrets/kubernetes/configs/admin/kubeconfig}

check_pods_ready() {
  local required_pods=("etcd" "kube-apiserver" "kube-controller-manager" "kube-scheduler")
  for pod in "${required_pods[@]}"; do
    if ! "$KUBECTL" get pods -n kube-system -o jsonpath="{.items[*].metadata.name}" | grep -q "${pod}"; then
      echo "[!] ${pod} is not yet running"
      return 1
    fi

    pod_status=$("$KUBECTL" get pods -n kube-system -l component="${pod}" -o jsonpath="{.items[*].status.containerStatuses[*].ready}")
    if [[ "$pod_status" != "true" ]]; then
      echo "[!] ${pod} containers are not yet ready"
      return 1
    fi
  done
  return 0
}

# Wait for pods to be ready
echo "[+] Waiting for Kubernetes control plane components to stabilize..."
until check_pods_ready; do
  echo "[-] Control plane not yet ready. Checking again in 5 seconds..."
  sleep 5
done
echo "[✓] Control plane is stable."

# Check if admin account is already provisioned
if "$KUBECTL" get serviceaccount admin -n default >/dev/null 2>&1; then
  echo "[✓] Admin service account already exists. Skipping provisioning."
else
  echo "[+] Creating Kubernetes service account 'admin'..."
  "$KUBECTL" apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: default
EOF

  echo "[+] Binding cluster-admin role to 'admin' service account..."
  "$KUBECTL" create clusterrolebinding admin-binding \
    --clusterrole=cluster-admin \
    --serviceaccount=default:admin \
    --dry-run=client -o yaml | "$KUBECTL" apply -f -

  echo "[✓] Admin service account provisioned successfully."
fi
