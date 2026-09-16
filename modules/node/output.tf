output "eks_node_iam_role" {
  value = aws_iam_role.eks_node_role.arn
}
