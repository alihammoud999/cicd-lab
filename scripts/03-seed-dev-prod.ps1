$ErrorActionPreference = "Stop"

$REGION = "eu-north-1"
$ACCOUNT_ID = "739135301600"
$REGISTRY = "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
$BACKEND_IMAGE = "$REGISTRY/k8s-backend:v1"
$FRONTEND_IMAGE = "$REGISTRY/k8s-frontend:v1"
$NAMESPACES = @("dev", "prod")

foreach ($ns in $NAMESPACES) {
  Write-Host "`nCreating namespace $ns if needed..."
  kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f -

  Write-Host "Applying manifests to $ns..."
  kubectl apply -n $ns -f .\manifests\redis.yaml
  kubectl apply -n $ns -f .\manifests\backend.yaml
  kubectl apply -n $ns -f .\manifests\frontend.yaml

  Write-Host "Setting v1 images in $ns..."
  kubectl -n $ns set image deployment/backend backend=$BACKEND_IMAGE
  kubectl -n $ns set image deployment/frontend frontend=$FRONTEND_IMAGE

  Write-Host "Waiting for rollouts in $ns..."
  kubectl -n $ns rollout status deployment/redis --timeout=180s
  kubectl -n $ns rollout status deployment/backend --timeout=180s
  kubectl -n $ns rollout status deployment/frontend --timeout=180s

  Write-Host "`nPods in ${ns}:"
  kubectl get pods -n $ns -o wide
}

$pendingPods = kubectl get pods -A --field-selector=status.phase=Pending --no-headers 2>$null
if ($pendingPods) {
  Write-Warning "Some pods are Pending. With t3.micro nodes this can happen if pod capacity is too low. Increase the nodegroup size up to max 6 or reduce non-lab workloads."
  $pendingPods
}
