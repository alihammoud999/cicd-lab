# Lab 010 - CI/CD with GitHub Actions

This repository contains a small Kubernetes application and CI/CD pipeline for Lab 010. The app has a Node.js backend, Redis, an Nginx frontend, Kubernetes manifests for `dev` and `prod`, GitHub Actions workflows, and a small Terraform demo.

AWS settings used for this lab:

- Region: `eu-north-1`
- Account ID: `739135301600`
- EKS cluster: `cicd-lab`
- ECR repositories: `k8s-backend`, `k8s-frontend`
- Worker nodes: 5 managed `t3.micro` nodes, min 3, max 6

Do not commit AWS credentials, `.env` files, kubeconfig files, Terraform state, or `.pem` keys.

## 1. Check Tools

Run from the repository root:

```powershell
.\scripts\00-check-tools.ps1
```

You need `aws`, `kubectl`, `eksctl`, `docker`, `git`, `node`, `npm`, and `terraform`.

## 2. Create the EKS Cluster

Only run this when you are ready to create AWS resources:

```powershell
.\scripts\01-create-cluster.ps1
```

This creates the `cicd-lab` EKS cluster in `eu-north-1` with 5 `t3.micro` worker nodes.

## 3. Create ECR Repos and Push v1 Images

```powershell
.\scripts\02-create-ecr.ps1
```

This creates or reuses:

- `739135301600.dkr.ecr.eu-north-1.amazonaws.com/k8s-backend:v1`
- `739135301600.dkr.ecr.eu-north-1.amazonaws.com/k8s-frontend:v1`

## 4. Seed Dev and Prod

```powershell
.\scripts\03-seed-dev-prod.ps1
```

This creates `dev` and `prod`, applies the same namespace-free manifests to both, sets both images to `v1`, waits for rollouts, and prints pod status.

## 5. GitHub Repository Setup

Create a GitHub repository named `cicd-lab`, then add these Actions secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` = `eu-north-1`
- `AWS_ACCOUNT_ID` = `739135301600`
- `EKS_CLUSTER_NAME` = `cicd-lab`

Create GitHub environments:

- `dev`: no approval required
- `prod`: required reviewer approval enabled

Set branch protection on `main` so the screenshot shows protected branch rules.

## 6. Push Main and Dev

```powershell
git init
git add .
git commit -m "Initial commit for Lab 010 CI/CD"
git branch -M main
git remote add origin https://github.com/alihammoud999/cicd-lab.git
git push -u origin main
git checkout -b dev
git push -u origin dev
```

For the dev screenshot, make a small visible frontend change first. For example, edit `app/frontend/index.html` and change the environment badge text from `LAB` to `DEV`, then commit and push on the `dev` branch.

## 7. Test Pipelines

Push to `dev` to trigger:

- `test`
- `build`
- `deploy-dev`

Push or merge to `main` to trigger:

- `test`
- `build`
- `deploy-prod`

The `prod` environment should pause for approval so you can capture the approval screenshots.

## 8. Local App Tests

Install and run backend tests:

```powershell
cd app
npm install
npm test
cd ..
```

Integration tests require Redis on `localhost:6379`:

```powershell
docker run -d --name cicd-lab-redis-test -p 6379:6379 redis:7-alpine
cd app
npm run test:integration
cd ..
docker rm -f cicd-lab-redis-test
```

Build images locally:

```powershell
docker build -t cicd-backend-local app
docker build -t cicd-frontend-local app/frontend
```

## 9. Port Forward for Screenshots

Dev:

```powershell
kubectl port-forward -n dev svc/frontend-service 8080:80
```

Open `http://localhost:8080`.

Prod:

```powershell
kubectl port-forward -n prod svc/frontend-service 8081:80
```

Open `http://localhost:8081`.

## 10. Terraform Demo

The Terraform workflow demonstrates CI/CD for infrastructure with a small S3 bucket.

Local test:

```powershell
cd terraform
copy terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt
terraform plan
cd ..
```

Do not commit `terraform.tfvars` or state files.

## 11. Screenshots

Use [scripts/05-screenshot-commands.md](scripts/05-screenshot-commands.md) for the exact screenshot order:

1. GitHub Actions dev run green.
2. GitHub Actions prod run with approval step.
3. Review deployments approval dialog.
4. `kubectl get pods -n dev`.
5. `kubectl get pods -n prod`.
6. Dev browser through port-forward with name and `DEV`.
7. Prod browser through port-forward.
8. Prod backend rollout history with at least two revisions.
9. Trivy scan table in build logs.
10. Branch protection settings.
11. Terraform PR plan comment.
12. Full `.github/workflows/ci.yml` in GitHub.

## 12. Cleanup

Only clean up after all screenshots are complete:

```powershell
kubectl delete namespace dev
kubectl delete namespace prod
eksctl delete cluster --name cicd-lab --region eu-north-1 --wait
aws ecr delete-repository --repository-name k8s-backend --force --region eu-north-1
aws ecr delete-repository --repository-name k8s-frontend --force --region eu-north-1
```

See [scripts/99-cleanup.md](scripts/99-cleanup.md) for the full cleanup checklist.
