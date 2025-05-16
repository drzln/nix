set -euo pipefail
export KUBECONFIG=/run/secrets/kubernetes/configs/admin/kubeconfig
SERVER=kubectl config view -o jsonpath='{.clusters[0].cluster.server}')
CA_CERT=kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
TOKEN=kubectl get secret kubectl get sa admin -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 --decode)
cat > admin.kubeconfig <<EOF
apiVersion: v1
kind: Config
clusters:
  - name: kubernetes
    cluster:
      certificate-authority-data: $CA_CERT
      server: $SERVER
contexts:
  - name: admin@kubernetes
    context:
      cluster: kubernetes
      user: admin
current-context: admin@kubernetes
users:
  - name: admin
    user:
      token: $TOKEN
EOF
echo "[✓] Generated admin.kubeconfig successfully."
