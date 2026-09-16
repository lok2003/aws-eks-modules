# AWS EKS Cluster Using Terraform Modules

This project creates an **Amazon EKS cluster using Terraform modules**.

The infrastructure is divided into separate modules for:

* VPC
* Security Group
* EKS Cluster IAM Role
* EKS Cluster
* EKS Node IAM Role
* EKS Worker Node Group

## Project Structure

```text
terraform_aws/
│
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── providers.tf
│
└── modules/
    │
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── output.tf
    │
    ├── sg/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── output.tf
    │
    ├── eks-cluster-role/
    │   ├── main.tf
    │   └── output.tf
    │
    ├── eks/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── output.tf
    │
    ├── node/
    │   ├── main.tf
    │   └── output.tf
    │
    ├── worker-node/
    |   ├── main.tf
    |   ├── variable.tf
    |
    └── eks-addons/
        ├── main.tf
        ├── variables.tf
        └── output.tf
    
```

## Architecture

```text
                    AWS
                     │
                     ▼
                  VPC
                     │
          ┌──────────┴──────────┐
          │                     │
    Public Subnets        Private Subnets
          │                     │
          │                     ▼
          │                EKS Cluster
          │                     │
          │                     ▼
          │                Node Group
          │                     │
          │               EC2 Worker Nodes
          │                       │
          |                ┌──────┼────────┐
          |                ▼      ▼        ▼
          |               VPC CNI CoreDNS kube-proxy
       Internet
```

## Terraform Modules

### 1. VPC Module

Creates:

* VPC
* Public subnets
* Private subnets

```text
modules/vpc/
├── main.tf
├── variables.tf
└── output.tf
```

The VPC module provides subnet IDs to the EKS cluster and worker node group.

---

### 2. Security Group Module

Creates the security group used by the infrastructure.

```text
modules/sg/
├── main.tf
├── variables.tf
└── output.tf
```

---

### 3. EKS Cluster IAM Role

Creates the IAM role required by the EKS control plane.

```text
modules/eks-cluster-role/
├── main.tf
└── output.tf
```

The role uses:

```text
AmazonEKSClusterPolicy
```

---

### 4. EKS Cluster Module

Creates the EKS control plane.

```text
modules/eks/
├── main.tf
├── variables.tf
└── output.tf
```

Example:

```hcl
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster.name
  role_arn = var.role_arn
  version  = var.eks_cluster.version

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}
```

---

### 5. Node IAM Role

Creates the IAM role for EKS worker nodes.

```text
modules/node/
├── main.tf
└── output.tf
```

The node role uses:

```text
AmazonEKSWorkerNodePolicy
AmazonEKS_CNI_Policy
AmazonEC2ContainerRegistryPullOnly
```

---

### 6. Worker Node Group

Creates the EKS managed node group.

```text
modules/worker-node/
├── main.tf
└── variable.tf
```

The node group receives:

* EKS cluster name
* IAM role
* Private subnet IDs
* Desired node count
* Minimum node count
* Maximum node count

## 7. EKS Add-ons

This project uses AWS EKS add-ons to provide important Kubernetes functionality.

### VPC CNI

The Amazon VPC CNI plugin provides networking for Kubernetes pods.

```text
vpc-cni
```
## Root Module Flow

The root `main.tf` connects all modules.

```text
VPC
 │
 ├── VPC ID
 └── Private Subnet IDs
          │
          ▼
     EKS Cluster
          │
          │ Cluster Name
          ▼
    Worker Node Group

EKS Cluster IAM Role
          │
          ▼
     EKS Cluster

Node IAM Role
          │
          ▼
   Worker Node Group
```

## Example Terraform Commands

### 1. Initialize Terraform

```powershell
terraform init
```

### 2. Format Terraform files

```powershell
terraform fmt -recursive
```

### 3. Validate configuration

```powershell
terraform validate
```

### 4. Create execution plan

```powershell
terraform plan
```

### 5. Create infrastructure

```powershell
terraform apply
```

Type:

```text
yes
```

when Terraform asks for confirmation.

### 6. Check Terraform state

```powershell
terraform state list
```

### 7. Destroy infrastructure

When finished with the lab:

```powershell
terraform destroy
```

Type:

```text
yes
```

## Useful AWS Commands

Check EKS clusters:

```powershell
aws eks list-clusters
```

Get cluster information:

```powershell
aws eks describe-cluster --name <cluster-name>
```

Configure `kubectl`:

```powershell
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

Check Kubernetes nodes:

```powershell
kubectl get nodes
```

Check all pods:

```powershell
kubectl get pods -A
```

## Important

AWS resources can incur charges.

After completing the practice:

```powershell
terraform destroy
```

Verify in the AWS Console that the resources have been removed.


## Troubleshooting

### 1. EKS Node Group `Cross-account pass role is not allowed`

If Terraform shows:

```text
Error: creating EKS Node Group
AccessDeniedException: Cross-account pass role is not allowed
```

Check the AWS account:

```powershell
aws sts get-caller-identity
```

Check the node IAM role ARN:

```powershell
aws iam get-role --role-name eks-node-role --query "Role.Arn" --output text
```

The AWS account ID in the role ARN should match the account being used by Terraform.

---

### 2. `kubectl` asks for credentials

If you see:

```text
the server has asked the client to provide credentials
```

Check the EKS authentication mode:

```powershell
aws eks describe-cluster --region <region> --name <cluster-name> --query "cluster.accessConfig"
```

Check EKS access entries:

```powershell
aws eks list-access-entries --region <region> --cluster-name <cluster-name>
```

If the IAM user is not present, create an EKS access entry:

```powershell
aws eks create-access-entry `
  --region <region> `
  --cluster-name <cluster-name> `
  --principal-arn arn:aws:iam::<ACCOUNT_ID>:user/<USERNAME>
```

Associate the EKS cluster administrator policy:

```powershell
aws eks associate-access-policy `
  --region <region> `
  --cluster-name <cluster-name> `
  --principal-arn arn:aws:iam::<ACCOUNT_ID>:user/<USERNAME> `
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy `
  --access-scope type=cluster
```

Update the kubeconfig:

```powershell
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

Test:

```powershell
kubectl get nodes
```

---

### 3. Check EKS authentication token

If `kubectl` cannot authenticate, test the AWS EKS token:

```powershell
aws eks get-token --region <region> --cluster-name <cluster-name>
```

If a token is returned, AWS authentication is working.

---

### 4. Check AWS Region

Check the configured AWS region:

```powershell
aws configure list
```

You can specify the region directly when working with EKS:

```powershell
aws eks list-clusters --region <region>
```

```powershell
aws eks update-kubeconfig --region <region> --name <cluster-name>
```
