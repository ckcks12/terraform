variable "tag" {
  type = object({})
}

variable "asg_name" {
  type        = string
  description = "Target Auto Scaling Group Name"
}

variable "name" {
  type        = string
  description = "Load Balancer Name"
}

variable "sg_ids" {
  type        = list(string)
  description = "EC2 Security Groups"
}

variable "subnet_ids" {
  type        = list(string)
  description = "LoadBalancer Subnet IDs"
}

variable "vpc_id" {
  type        = string
  description = "Target Group VPC ID"
}

variable "ports" {
  type        = map(number)
  description = "LoadBalancer:Port -> TargetGroup:Port"
}

variable "deregistration_delay" {
  type        = number
  description = "Amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 300 seconds."
  default     = 300
}
