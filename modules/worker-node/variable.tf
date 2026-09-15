variable "node" {
  type = object({
    node_group_name = string
    desired_size    = number
    max_size        = number
    min_size        = number
    max_unavailable = number
  })
}

variable "cluster" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

