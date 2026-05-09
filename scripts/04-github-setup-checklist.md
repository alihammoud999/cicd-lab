# GitHub Setup Checklist

1. Create a GitHub repository named `cicd-lab`.
2. Add repository secrets in GitHub Settings -> Secrets and variables -> Actions:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION` = `eu-north-1`
   - `AWS_ACCOUNT_ID` = `739135301600`
   - `EKS_CLUSTER_NAME` = `cicd-lab`
3. Never put AWS access keys in code, README files, screenshots, or chat messages.
4. Create GitHub environments:
   - `dev`: no approval required.
   - `prod`: required reviewer approval enabled.
5. Add a branch protection rule for `main`:
   - Require a pull request before merging.
   - Require status checks to pass.
   - Include the CI workflow checks.
6. Push `main`.
7. Create and push `dev`.
8. Make a small frontend change on `dev` so the page label says `DEV`, then push to trigger `deploy-dev`.
9. Merge or push to `main` to trigger `deploy-prod` and capture the approval screenshots.
