# Specify the provider and access details
provider "aws" {
  shared_credentials_files = [var.shared_credentials_file]
  region                  = var.region
  profile                 = var.profile
}

# 2. Configure the new VPC
resource "aws_vpc" "default" {
  cidr_block = "172.25.0.0/16"

  tags = {
    Name = "pfsense-VPC"
  }
}

# 3. Create the public subnet(s) to serve as a DMZ
resource "aws_subnet" "DMZ" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "172.25.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  depends_on = [ aws_internet_gateway.default ]

  tags = {
    Name = "pfsense-DMZ"
  }
}


# 5. Create a new route table for the public subnet to override AWS default behavior
resource "aws_route_table" public_route {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

/* # This apparently gets auto created
  route {
    cidr_block = "172.25.0.0/16"
    gateway_id = "local"

  }
*/
}

# 6. Associate the public subnet with the newly created routing table 
resource "aws_route_table_association" public {
  subnet_id = aws_subnet.DMZ.id
  route_table_id = aws_route_table.public_route.id

}

# 7. Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = var.custom-tags
}

# 8. Associate the gateway with the public route table
# Run current version, I think this happens automatically.....

/*
# Grant the VPC internet access on its main route table
resource "aws_route" "internal_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "172.25.0.0/16"
  #gateway_id             = aws_internet_gateway.default.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}
*/

# 4. Create the private subnet(s) to serve as an internal LAN
resource "aws_subnet" "LAN" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "172.25.2.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "pfsense-LAN"
  }
}

# Our default security group for the 
resource "aws_security_group" "pfsense" {
  name        = "cns_security_group"
  description = "Security Group for external pfsense access"
  vpc_id      = aws_vpc.default.id

  tags = {
    Name = "pfsense-SG"
  }

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # OpenVPN access
  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # IKE for IPsec access
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Encapsulated IPsec traffic (ESP)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "50"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # IPsec/NAT-T for IPsec VPN
    ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all traffic from the private subnet
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.25.1.0/24"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = var.public_key_name
  public_key = file(var.public_key_path)
}

resource "aws_network_interface" "public" {
  subnet_id = aws_subnet.DMZ.id
  security_groups = [aws_security_group.pfsense.id]
  private_ips = ["172.25.1.5"]
}

resource "aws_network_interface" "private" {
  subnet_id = aws_subnet.LAN.id
  private_ips = ["172.25.2.5"]
}

resource "aws_instance" "pfsense" {
  instance_type = "m5.large"
  key_name = var.public_key_name
  ami = "ami-0f1c68e571ab71af6" # Should be pfsense.....
  user_data = "password=dWlsZGFtaS8="
  
  tags = {
    Name = "pfsense-firewall"
  }

  network_interface {
    network_interface_id = aws_network_interface.public.id
    device_index = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.private.id
    device_index = 1
  }

  root_block_device {
    delete_on_termination = true
  }
}

resource "aws_eip" "bar" {

  network_interface = aws_network_interface.public.id
  associate_with_private_ip = "172.25.1.5"
  depends_on = [ aws_internet_gateway.default ]

}