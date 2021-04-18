data "aws_ami" "linux2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami*gp2"]
  }
}

data "template_cloudinit_config" "this" {
  gzip = true
  part {
    content_type = "text/cloud-config"
    content      = var.cloudinit
  }
}

resource "aws_launch_template" "this" {
  name          = var.name
  image_id      = var.ami == "" ? data.aws_ami.linux2.id : var.ami
  instance_type = var.instance_type
  ebs_optimized = var.ebs_optimized

  block_device_mappings {
    device_name = var.volume_device_name

    ebs {
      volume_type           = var.volume_type
      volume_size           = var.volume_size
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "iam_instance_profile" {
    for_each = var.iam_name != "" ? list(var.iam_name) : []
    content {
      name = var.iam_name
    }
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.sg_ids
    delete_on_termination       = true
  }

  key_name = var.key_name

  user_data = data.template_cloudinit_config.this.rendered
}

resource "aws_autoscaling_group" "asg" {
  name = var.name

  min_size         = var.node_min_cnt
  desired_capacity = var.node_desired_cnt
  max_size         = var.node_max_cnt

  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  health_check_type         = ""
  health_check_grace_period = 10
  default_cooldown          = 300
  termination_policies = [
    "OldestLaunchConfiguration",
    "OldestInstance"
  ]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tags = concat([for k, v in var.tag : {
    key                 = k,
    value               = v,
    propagate_at_launch = true
    }], [
    {
      key                 = "Name",
      value               = var.name,
      propagate_at_launch = true
    }
  ])

  depends_on = [aws_launch_template.this]
}
