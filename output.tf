output "vpc" {
  value = module.vpc
}

output "public_subnet" {
  value = module.vpc.public_subnet_ids
}
output "private_subnet" {
  value = module.vpc.private_subnet_ids
}

output "sg" {
  value = module.sg
}

output "eks-cluster" {
  value = module.cluster
}

output "node-group" {
  value = module.node-role
}