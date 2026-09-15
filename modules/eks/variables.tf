variable "eks_cluster" {
  type = object({
    name    = string
    version = string
  })
}
variable "role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}
