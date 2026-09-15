resource "aws_eks_node_group" "node" {
  cluster_name    = var.cluster
  node_group_name = var.node.node_group_name
  node_role_arn   = var.role_arn
  subnet_ids      = var.subnet_ids
  scaling_config {
    desired_size = var.node.desired_size
    max_size     = var.node.max_size
    min_size     = var.node.min_size
  }
  update_config {
    max_unavailable = var.node.max_unavailable
  }
}