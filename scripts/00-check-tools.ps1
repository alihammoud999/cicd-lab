$ErrorActionPreference = "Stop"

Write-Host "Checking AWS identity..."
aws sts get-caller-identity

Write-Host "`nChecking AWS region..."
$region = aws configure get region
Write-Host "Configured AWS region: $region"
if ($region -ne "eu-north-1") {
  Write-Warning "Expected eu-north-1. Run: aws configure set region eu-north-1"
}

Write-Host "`nChecking kubectl..."
kubectl version --client

Write-Host "`nChecking eksctl..."
eksctl version

Write-Host "`nChecking Docker..."
docker version

Write-Host "`nChecking Git..."
git --version

Write-Host "`nTool check complete."
