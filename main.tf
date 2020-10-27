provider "aws" {
  version = "~> 2.0"
  profile = "default"
  region  = var.region
}
# create the VPC
resource "aws_vpc" "My_VPC" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
  tags = {
    Name = "Week_5_proj_VPC"
  }
} # end resource
# create the Subnet
resource "aws_subnet" "Private_subnet" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = false
  availability_zone       = var.availabilityZone
  tags = {
    Name = "Prometheus_private"
  }
}
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.subnetCIDRblock2
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
  tags = {
    Name = "grafana_public"
  } # end resource
}
# Create the Internet Gateway
resource "aws_internet_gateway" "My_VPC_GW" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "Docker_VPC_Gateway"
  }
}
# Create the Route Table
resource "aws_route_table" "Grafana_route_table" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "Grafana_Route_Table"
  }
}
resource "aws_route_table" "prometheus_route_table" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "prometheus_Route_Table"
  }
} # end resource  

#Associate the Route Table with the Subnet
resource "aws_route_table_association" "grafana_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.Grafana_route_table.id
} # end resource
#Associate the Route Table with the Subnet
resource "aws_route_table_association" "prometheus_association" {
  subnet_id      = aws_subnet.Private_subnet.id
  route_table_id = aws_route_table.prometheus_route_table.id
} # end resource

# Create the Internet Access
resource "aws_route" "My_VPC_internet_access" {
  route_table_id         = aws_route_table.Grafana_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.My_VPC_GW.id
} # end resource
# create Security_group
resource "aws_security_group" "My_VPC_Security" {
  name = "prometheus_sec"
  vpc_id = aws_vpc.My_VPC.id
    ingress {
       from_port = 22
    to_port = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 9090
    to_port = 9090
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  }# end resource
resource "aws_security_group" "My_VPC_Security2" {
  name = "grafana_sec"
  vpc_id = aws_vpc.My_VPC.id
    ingress {
       from_port = 22
    to_port = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port = 3000
    to_port = 3000
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 9090
    to_port = 9090
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create EC2 instance
resource "aws_instance" "prometheus_machine" {
  ami                    = "ami-027ca4e9778162ff8"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Private_subnet.id
  key_name               = "devops-key2"
  vpc_security_group_ids = [aws_security_group.My_VPC_Security.id]

  tags = {
    Name        = "prometheus_machine"
    provisioner = "Terraform"
  }
}
output "prom_ip" {
  value       = aws_instance.prometheus_machine.public_ip
  description = "The URL of the server instance."
}

resource "aws_instance" "grafana_machine" {
  ami                    = "ami-027ca4e9778162ff8"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = "devops-key2"
  vpc_security_group_ids = [aws_security_group.My_VPC_Security2.id]

  tags = {
    Name        = "grafana_machine"
    provisioner = "Terraform"
  }
}

output "graf_ip" {
  value       = aws_instance.grafana_machine.public_ip
  description = "The URL of the server instance."
}

