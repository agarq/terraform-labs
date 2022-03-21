
#VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.network_address_space
  enable_dns_hostnames = "true"
  #tags = {
  #  Name = "jhon-vpc"
  #}
  tags = merge(local.common_tags, { Name = "${var.environment_tag}-vpc" })
}

#Internet Gateway
resource "aws_internet_gateway" "igw_jhon" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.common_tags, { Name = "${var.environment_tag}-igw" })
}

#Subnet public
resource "aws_subnet" "subnet1_jhon" {
  cidr_block = var.subnet1_address_space
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.az_jhon.names[0]
  tags = merge(local.common_tags, { Name = "${var.environment_tag}-subnet1" })
}

#Subnet private
resource "aws_subnet" "subnet2_jhon" {
  cidr_block = var.subnet2_address_space
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = false #el valor por defecto es false, podría omitirse.
  availability_zone = data.aws_availability_zones.az_jhon.names[1]
  tags = merge(local.common_tags, { Name = "${var.environment_tag}-subnet2" })
}

#Route Table
resource "aws_route_table" "rtb_jhon" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_jhon.id
  }

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-rtb" })
}

#Route Table Asociation Subnet 1 (public)
resource "aws_route_table_association" "rta-subnet1_jhon" {
  subnet_id      = aws_subnet.subnet1_jhon.id
  route_table_id = aws_route_table.rtb_jhon.id
}

########### SECURITY GROUPS ###########
#Security Group public
resource "aws_security_group" "sg-public" {
  name = "sg_public"
  vpc_id = aws_vpc.vpc.id

  ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-sg_public" })
}

#Security Group private
resource "aws_security_group" "sg-private" {
  name = "sg_private"
  vpc_id = aws_vpc.vpc.id

  #Allow SSH from anywhere
  ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-sg_private" })
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
  value = aws_instance.ec2-public.public_dns
}