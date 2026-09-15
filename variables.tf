variable "region" {
  type = object({
    region = string
  })
}
variable "vpc" {
  type = object({
    name       = string
    cidr_block = string
  })
}


variable "public_subnet" {
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}

variable "private_subnet" {
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}



variable "aws_sg" {
  type = object({
    name = string
  })
}

variable "ingress" {
  type = list(object({
    name        = string
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = string
  }))
}


variable "eks_cluster" {
  type = object({
    name    = string
    version = string
  })
}

variable "node" {
  type = object({
    node_group_name = string
    desired_size    = number
    max_size        = number
    min_size        = number
    max_unavailable = number
  })
}

