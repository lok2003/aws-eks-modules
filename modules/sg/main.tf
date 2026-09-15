resource "aws_security_group" "eks_sg" {
  vpc_id = var.vpc_id
  name   = var.aws_sg.name
  tags = {
    Name = var.aws_sg.name
  }
}
resource "aws_vpc_security_group_ingress_rule" "inbound" {
  security_group_id = aws_security_group.eks_sg.id
  count             = length(var.ingress)
  cidr_ipv4         = var.ingress[count.index].cidr_ipv4
  from_port         = var.ingress[count.index].from_port
  to_port           = var.ingress[count.index].to_port
  ip_protocol       = var.ingress[count.index].ip_protocol
  tags = {
    Name = var.ingress[count.index].name
  }
}


