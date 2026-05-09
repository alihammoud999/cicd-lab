$ErrorActionPreference = "Stop"

$REGION = "eu-north-1"
$CLUSTER_NAME = "cicd-lab"
$NODEGROUP_NAME = "workers"

Write-Host "Creating EKS cluster $CLUSTER_NAME in $REGION with 5 t3.micro nodes..."
eksctl create cluster `
  --name $CLUSTER_NAME `
  --region $REGION `
  --nodegroup-name $NODEGROUP_NAME `
  --node-type t3.micro `
  --nodes 5 `
  --nodes-min 3 `
  --nodes-max 6 `
  --managed

Write-Host "`nUpdating kubeconfig..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

Write-Host "`nCluster nodes:"
kubectl get nodes -o wide
