resource "aws_efs_file_system" "jenkins_efs" {
  encrypted = true
  tags = {
    Name = "jenkins-home"
  }
}

resource "aws_efs_mount_target" "jenkins_efs_mt1" {
  file_system_id  = aws_efs_file_system.jenkins_efs.id
  subnet_id       = module.vpc.private_subnets[0]
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "jenkins_efs_mt2" {
  file_system_id  = aws_efs_file_system.jenkins_efs.id
  subnet_id       = module.vpc.private_subnets[1]
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_access_point" "jenkins_efs_ap" {
  file_system_id = aws_efs_file_system.jenkins_efs.id
  posix_user {
    gid = "1000"
    uid = "1000"
  }
  root_directory {
    creation_info {
      owner_gid   = "1000"
      owner_uid   = "1000"
      permissions = "755"
    }
    path = "/jenkins-home"
  }
}