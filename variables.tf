variable "jnlp_port" {
  type    = number
  default = 50000
}

variable "cluster_name" {
  type    = string
  default = "jenkins_ecs"
}

variable "certificate_arn" {
  type    = string
  default = "arn::acm:certificate"
}

variable "region" {
  type    = string
  default = "us-east-1"
}
