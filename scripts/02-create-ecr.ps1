$ErrorActionPreference = "Stop"
if (Get-Variable PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
  $PSNativeCommandUseErrorActionPreference = $false
}

$REGION = "eu-north-1"
$ACCOUNT_ID = "739135301600"
$REPOS = @("k8s-backend", "k8s-frontend")
$REGISTRY = "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

foreach ($repo in $REPOS) {
  aws ecr describe-repositories --repository-names $repo --region $REGION *> $null
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Creating ECR repository: $repo"
    aws ecr create-repository --repository-name $repo --region $REGION | Out-Null
  } else {
    Write-Host "ECR repository already exists: $repo"
  }
}

Write-Host "`nLogging Docker in to ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY

$backendImage = "$REGISTRY/k8s-backend:v1"
$frontendImage = "$REGISTRY/k8s-frontend:v1"

Write-Host "`nBuilding and pushing backend image: $backendImage"
docker build -t $backendImage .\app
docker push $backendImage

Write-Host "`nBuilding and pushing frontend image: $frontendImage"
docker build -t $frontendImage .\app\frontend
docker push $frontendImage

Write-Host "`nImages pushed:"
Write-Host $backendImage
Write-Host $frontendImage
