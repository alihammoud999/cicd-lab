# Lab 010 Screenshot Commands

Capture these screenshots in this order.

1. **Actions tab - dev run**
   - GitHub Actions run on branch `dev` showing `test`, `build`, and `deploy-dev` all green.

2. **Actions tab - prod run**
   - GitHub Actions run on branch `main` showing the production deployment and approval step.

3. **Approval dialog**
   - GitHub `Review deployments` dialog for environment `prod`.

4. **Dev pods**
   ```powershell
   kubectl get pods -n dev -o wide
   ```

5. **Prod pods**
   ```powershell
   kubectl get pods -n prod -o wide
   ```

6. **Browser - dev app**
   ```powershell
   kubectl port-forward -n dev svc/frontend-service 8080:80
   ```
   Open `http://localhost:8080`. The page should show `CI/CD Lab - Ali Al Hadi Hammoud`, the `DEV` label after you edit it for the dev test, and a backend pod name.

7. **Browser - prod app**
   ```powershell
   kubectl port-forward -n prod svc/frontend-service 8081:80
   ```
   Open `http://localhost:8081`. The page should show the production app and a backend pod name.

8. **Rollout history**
   ```powershell
   kubectl rollout history deployment/backend -n prod
   ```
   It should show at least two revisions after a successful prod update.

9. **Trivy output**
   - Open the GitHub Actions build job logs and screenshot the Trivy table output for backend and frontend image scans.

10. **Branch protection**
    - GitHub Settings -> Branches page showing protection rules for `main`.

11. **Terraform PR comment**
    - Pull request showing the Terraform plan output posted as a comment.

12. **ci.yml**
    - GitHub repo page showing the full contents of `.github/workflows/ci.yml`.
