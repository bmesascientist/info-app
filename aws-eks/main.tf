provider "aws" {
  region = "eu-north-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "info-app-vpc"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1b"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "info-app-eks-cluster"
  cluster_version = "1.31"
  vpc_id          = aws_vpc.main.id
  subnet_ids      = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  eks_managed_node_groups = {
    example = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1
      instance_type    = "t3.micro"
    }
  }
}

resource "aws_security_group" "eks_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "eks_security_group"
  }
}

resource "aws_launch_template" "eks_lt" {
  name_prefix   = "info-app-lt"
  image_id      = "-" #
  instance_type = "t3.micro"

  network_interfaces {
    security_groups = [aws_security_group.eks_security_group.id]
  }

  tags = {
    Name = "eks_lt"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "info-app-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-north-1a", "eu-north-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "info-app-eks-vpc"
  }
}

resource "aws_autoscaling_group" "eks_asg" {
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  launch_template {
    id      = aws_launch_template.eks_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "eks_asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "eks_log_group" {
  name              = "/aws/eks/info-app-eks-cluster"
  retention_in_days = 7

  tags = {
    Name = "eks_log_group"
  }
}

resource "aws_sns_topic" "alerts" {
  name = "alerts"

  tags = {
    Name = "alerts-topic"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "cpu_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "This metric monitors EC2 CPU utilization."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_launch_template.eks_lt.id
  }
}

resource "aws_sns_topic_subscription" "alert_subscription" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "-" #
}
