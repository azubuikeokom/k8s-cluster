resource "aws_instance" "web" {
  ami           = "ami-0574da719dca65348"
  count = var.count_num
  instance_type = "t2.medium"
  key_name = "cloude-key"
  vpc_security_group_ids = [ aws_security_group.allow_tls.id ]
  subnet_id = aws_subnet.public_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.id
  
  user_data=<<-EOF
  #! /bin/bash
  sudo apt-get update
  sudo apt-get install docker.io -y
  EOF
  tags = {
    Name = "${var.server_name}-server${count.index}"
  }


}

