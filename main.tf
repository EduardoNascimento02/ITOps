provider "aws" {
  region = "us-east-1"
  shared_config_files = ["./aws/config"]
  shared_credentials_files = ["./aws/credentials"]

}

resource "aws_security_group" "instance_sg" {
  name        = "instance_sg-5"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = "<vpc-id>"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "github_sha" {}

output "public_ip" {
  value = aws_instance.ec2_instance.public_ip
}

resource "aws_instance" "example" {
  ami           = "ami-0c94855ba95c574c8"
  instance_type = "t2.micro"
  key_name      = "Terraform"
  subnet_id = "subnet-06ca534a4ee042fc5"
  vpc_security_group_ids = ["${aws_security_group.instance_sg.id}"]
  user_data     = <<EOF
    #!/bin/bash
    # Install Docker
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
    # Pull and run the Docker image
    sudo docker pull eddydox/apicontainer:$COMMIT_SHA
    sudo docker run -d -p 8080:8080 eddydox/apicontainer:$COMMIT_SHA
  EOF
  tags = {
    Name = "inst"
  }
}