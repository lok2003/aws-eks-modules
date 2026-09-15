resource "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster.name
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
  role_arn = var.role_arn
  version  = var.eks_cluster.version
  vpc_config {
    subnet_ids = var.subnet_ids
  }
  #depends_on = [ modules/eks_node_role ]
}