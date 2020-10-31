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

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.subnetCIDRblock_private
  map_public_ip_on_launch = false
  availability_zone       = var.availabilityZone
  tags = {
    Name = "Database_private_subnet"
  }
}
resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.subnetCIDRblock_private2
  map_public_ip_on_launch = false
  availability_zone       = var.availabilityZone2
  tags = {
    Name = "Database_private_subnet2"
  }
}
resource "aws_subnet" "webserver1_subnet" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
  tags = {
    Name = "Webserver 1"
  }
}
resource "aws_subnet" "webserver2_subnet" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.subnetCIDRblock2
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
  tags = {
    Name = "Webserver2"
  }
}
resource "aws_subnet" "monitoring_subnet" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.subnetCIDRblock3
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
  tags = {
    Name = "Monitoring node"
  }
} # end resource

# Create the Internet Gateway
resource "aws_internet_gateway" "My_VPC_GW" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "Week5_proj_VPC_Gateway"
  }
}
# Create the Route Table
resource "aws_route_table" "RDS_route_table" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "RDS_Route_Table"
  }
}
resource "aws_route_table" "RDS_route_table2" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "RDS_Route_Table"
  }
}
resource "aws_route_table" "webserver1_route_table" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "prometheus_Route_Table"
  }
}
resource "aws_route_table" "webserver2_route_table" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "Webserver2_Route_Table"
  }
}
resource "aws_route_table" "monitoring_route_table" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "monitoring_Route_Table"
  }
} # end resource  

#Associate the Route Table with the Subnet
resource "aws_route_table_association" "RDS_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.RDS_route_table.id
} 
resource "aws_route_table_association" "RDS_association2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.RDS_route_table2.id
} 
resource "aws_route_table_association" "Webserver1_association" {
  subnet_id      = aws_subnet.webserver1_subnet.id
  route_table_id = aws_route_table.webserver1_route_table.id
}
resource "aws_route_table_association" "Webserver2_association" {
  subnet_id      = aws_subnet.webserver2_subnet.id
  route_table_id = aws_route_table.webserver2_route_table.id
} # end resource
#Associate the Route Table with the Subnet
resource "aws_route_table_association" "Monitoring_association" {
  subnet_id      = aws_subnet.monitoring_subnet.id
  route_table_id = aws_route_table.monitoring_route_table.id
} # end resource

# Create the Internet Access
resource "aws_route" "Webserver1_internet_access" {
  route_table_id         = aws_route_table.webserver1_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.My_VPC_GW.id
}
resource "aws_route" "Webserver2_access" {
  route_table_id         = aws_route_table.webserver2_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.My_VPC_GW.id
}
resource "aws_route" "Monitoring_access" {
  route_table_id         = aws_route_table.monitoring_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.My_VPC_GW.id
}

# end resource
# create Security_group
resource "aws_security_group" "My_server_Security" {
  name   = "webservers_sec_group"
  vpc_id = aws_vpc.My_VPC.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
} # end resource
resource "aws_security_group" "My_monitoring_Security" {
  name   = "monitoring_sec"
  vpc_id = aws_vpc.My_VPC.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
  resource "aws_security_group" "My_RDS_Security" {
    name   = "RDS_sec_group"
    vpc_id = aws_vpc.My_VPC.id
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
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
  resource "aws_instance" "Webserver_1" {
    ami                    = "ami-0e96cd6da58a32233"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.webserver1_subnet.id
    key_name               = "devops-key2"
    vpc_security_group_ids = [aws_security_group.My_server_Security.id]

    tags = {
      Name        = "Web box 1"
      provisioner = "Terraform"
    }
  }
  output "Web_1_ip" {
    value       = aws_instance.Webserver_1.public_ip
    description = "The URL of the server instance."
  }

  resource "aws_instance" "Webserver_2" {
    ami                    = "ami-027ca4e9778162ff8"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.webserver2_subnet.id
    key_name               = "devops-key2"
    vpc_security_group_ids = [aws_security_group.My_server_Security.id]

    tags = {
      Name        = "Web box 2"
      provisioner = "Terraform"
    }

    
  }

  output "Web_2_ip" {
    value       = aws_instance.Webserver_2.public_ip
    description = "The URL of the server instance."
  }
  

resource "aws_instance" "Monitoring_node" {
    ami                    = "ami-0b854eb099b3b9cafyes
    "
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.monitoring_subnet.id
    key_name               = "devops-key2"
    vpc_security_group_ids = [aws_security_group.My_monitoring_Security.id]

    tags = {
      Name        = "Monitoring_node"
      provisioner = "Terraform"
    }
}
output "monitor_ip" {
    value       = aws_instance.Monitoring_node.public_ip
    description = "The URL of the server instance."
  }
