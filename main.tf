provider "aws" {
  region = "ap-south-1"
}
# Create a new security group
resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow HTTP and SSH traffic"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "Nginx-WebServer" {
  ami           = "ami-07d3a50bd29811cd1"
  instance_type = "t2.micro"
  key_name      = "ansible-nginx"
  security_groups = [aws_security_group.web.name]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./ansible-nginx.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install pip -y",
      "sudo pip install ansible"
    ]
  }

  tags = {
    Name = "Nginx-Webserver"
  }
}

output "public_ip" {
  value = aws_instance.Nginx-WebServer.public_ip
}

