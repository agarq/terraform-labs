#Instancia EC2 pública
resource "aws_instance" "ec2-public" {
    ami = data.aws_ami.aws-linux.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet1_jhon.id
    vpc_security_group_ids = [aws_security_group.sg-public.id]
    key_name = var.key_name # Nombre del Key Pairs generado en AWS para un usuario

    # Lo siguiente para poder ingresar por ssh a esta instancia
    connection {
        type = "ssh"
        #Terraform sabe que se conectará a la IP publica de esta instancia, y ejecutar el provisioner
        host = self.public_ip
        user = "ec2-user"
        private_key = file(var.private_key_path)
    }
    
    tags = merge(local.common_tags, { Name = "${var.environment_tag}-ec2-public" })

    provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start"
    ]
  }
}

#Instancia EC2 privada
resource "aws_instance" "ec2-private" {
    ami = data.aws_ami.aws-linux.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet2_jhon.id
    vpc_security_group_ids = [aws_security_group.sg-private.id]    
    
    tags = merge(local.common_tags, { Name = "${var.environment_tag}-ec2-private" })
}
