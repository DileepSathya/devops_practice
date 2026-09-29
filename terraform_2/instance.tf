

resource "aws_instance" "my_web_server" {

  ami           = "ami-066c4849e6b3a1e3d"
  instance_type = "t3.micro"
}