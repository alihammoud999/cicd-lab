# Cleanup Commands

Run cleanup only after all screenshots are finished.

```powershell
kubectl delete namespace dev
kubectl delete namespace prod
```

If you applied the Terraform demo:

```powershell
cd terraform
terraform destroy
cd ..
```

Delete the EKS cluster:

```powershell
eksctl delete cluster --name cicd-lab --region eu-north-1 --wait
```

Delete ECR repositories:

```powershell
aws ecr delete-repository --repository-name k8s-backend --force --region eu-north-1
aws ecr delete-repository --repository-name k8s-frontend --force --region eu-north-1
```

If you created Terraform backend resources for your own testing, delete the S3 bucket and DynamoDB lock table after the Terraform state no longer needs them.

If you created a temporary IAM lab user or access keys, delete the access keys and user after submission.

Final verification:

```powershell
aws eks list-clusters --region eu-north-1
aws ec2 describe-instances --region eu-north-1 --filters Name=instance-state-name,Values=pending,running,stopping,stopped --query "Reservations[].Instances[].{Id:InstanceId,Name:Tags[?Key=='Name']|[0].Value,State:State.Name}" --output table
aws elbv2 describe-load-balancers --region eu-north-1 --query "LoadBalancers[].LoadBalancerName" --output table
aws ecr describe-repositories --region eu-north-1 --query "repositories[].repositoryName" --output table
```
