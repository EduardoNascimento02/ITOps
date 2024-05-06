provider "aws" {
  region = "us-east-1"
  shared_config_files = ["./aws/config"]
  shared_credentials_files = ["./aws/credentials"]

}
resource "aws_instance" "example" {
  ami           = "ami-0c94855ba95c574c8"
  instance_type = "t2.micro"
  key_name      = "Terraform"
  subnet_id = "subnet-06ca534a4ee042fc5"
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