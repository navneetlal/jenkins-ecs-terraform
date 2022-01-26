resource "aws_security_group" "lb_sg" {
  name        = "LoadBalancerSecurityGroup"
  description = "Security group for load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "jenkins_lb_sg"
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "JenkinsSecurityGroup"
  description = "Security group for Jenkins"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "jenkins_sg"
  }
}

resource "aws_security_group" "jenkins_agent_sg" {
  name        = "JenkinsAgentSecurityGroup"
  description = "Security group for Jenkins agents"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = var.jnlp_port
    to_port         = var.jnlp_port
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "jenkins_agent_sg"
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "efs-security_group"
  description = "Enable EFS access via port 2049"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "efs_security_group"
  }
}
