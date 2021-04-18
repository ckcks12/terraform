locals {
  ssm_core_policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "this" {
  name               = var.name
  tags               = var.tag
  assume_role_policy = <<JSON
{
 "Version":"2012-10-17",
 "Statement":[
    {
       "Effect":"Allow",
       "Principal":{
          "Service":"ec2.amazonaws.com"
       },
       "Action":"sts:AssumeRole"
    }
 ]
}
JSON
}

resource "aws_iam_policy_attachment" "this" {
  name       = var.name
  policy_arn = local.ssm_core_policy_arn
  roles      = [aws_iam_role.this.id]
}
