output "ami" {
  value = data.aws_ami.linux2.id
}

output "name" {
  value = aws_autoscaling_group.this.name
}
