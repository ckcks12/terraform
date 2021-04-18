variable "tag" {
  type = object({})
}

variable "name" {
  type        = string
  description = "ASG and EC2 Name"
}

variable "node_min_cnt" {
  type        = number
  description = "ASG EC2 instance minimum size"
}

variable "node_desired_cnt" {
  type        = number
  description = "ASG EC2 instance desired size"
}

variable "node_max_cnt" {
  type        = number
  description = "ASG EC2 instance maximum size"
}

variable "subnet_ids" {
  type        = list(string)
  description = "ASG VPC Subnet Ids"
}

variable "ami" {
  type        = string
  description = "EC2 AMI"
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "EC2 Instance Type"
}

variable "volume_device_name" {
  type    = string
  default = "/dev/xvda"
}

variable "volume_type" {
  type        = string
  description = "EBS Volume Type"
  default     = "gp2"
}

variable "volume_size" {
  type        = number
  description = "EC2 Volume Size"
}

variable "iam_name" {
  type        = string
  description = "EC2 Instance IAM Profile Name"
  default     = ""
}

variable "sg_ids" {
  type        = list(string)
  description = "EC2 Security Group Ids"
}

variable "cloudinit" {
  type        = string
  description = "EC2 cloudinit.yml for User Data"
}

variable "key_name" {
  type        = string
  description = "Key Pair Name"
}

variable "ebs_optimized" {
  type        = bool
  description = "EC2 EBS Optimized"
  default     = true
}
