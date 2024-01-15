#VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "myVPC"
  }
}

# IGW for Public Subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}

#EIP for NAT
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw]
}

#Public Subnet
resource "aws_subnet" "my_public_subnet" {
  vpc_id                  = aws_vpc.myvpc.id
  count                   = length(var.public_subnets_cidr_blocks)
  cidr_block              = element(var.public_subnets_cidr_blocks, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "mypublicsubnet-${count.index}"
  }

}

#Private Subnet
resource "aws_subnet" "my_private_subnet" {
  vpc_id            = aws_vpc.myvpc.id
  count             = length(var.private_subnets_cidr_blocks)
  cidr_block        = element(var.private_subnets_cidr_blocks, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "myprivatesubnet-${count.index}"
  }
}

#NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.my_public_subnet.*.id, 0)
  tags = {
    Name = "mynatgateway"
  }
}

#Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "mypublicroutetable"
  }
}

#Route Table for Private Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myprivateroutetable"
  }
}

#Route for Internet Gateway
resource "aws_route" "route_internet_gateway_public" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#Route for NAT Gateway
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}


# Route table associations for Public Subnet
resource "aws_route_table_association" "public_route_table_attach_to_public_subnet" {
  count          = length(var.public_subnets_cidr_blocks)
  subnet_id      = element(aws_subnet.my_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

# Route table associations for Private Subnet
resource "aws_route_table_association" "private_route_table_attach_to_private_subnet" {
  count          = length(var.private_subnets_cidr_blocks)
  subnet_id      = element(aws_subnet.my_private_subnet.*.id,count.index)
  route_table_id = aws_route_table.private_route_table.id
}

#Security Group for VPC
resource "aws_security_group" "mydefaultsg" {
  name       = "mydefaultsg"
  vpc_id     = aws_vpc.myvpc.id
  depends_on = [aws_vpc.myvpc]
  tags = {
    Name = "mydefaultsg"
  }

}

resource "aws_vpc_security_group_ingress_rule" "allow" {
  security_group_id = aws_security_group.mydefaultsg.id
  cidr_ipv4         = aws_vpc.myvpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

#EC2 Network Interface
resource "aws_network_interface" "myvmnic" {
  subnet_id       = element(aws_subnet.my_public_subnet.*.id, 0)
  private_ips     = ["10.0.0.7"]
  security_groups = [aws_security_group.mydefaultsg.id]
  tags = {
    Name = "myvmicprimary"
  }
}

#key Pair
resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbVTatLgFfnJ6DdfSXR8ypq2TtVIu8VC2hmd5yNZXRR3NLBA0QAYr1oFTG6CpyU7yTMW4DtqbqsyLFVs7TTpiA5DTeB7G3Kvm7lsbxVq69RNRGYIqHwg5pHn3hPx24Rb8JiE7e+jae1+z7bCPVQ28ymmNPBOGzMJwXIEIbStQ2s/JrmO+Azfqec1okVsspGGHQSAbTA4FarEoUmdm6hA3v7VN3TM34wssBZFLxuWYGrL4aLohegHEQw/vJs7dn9eVXmI+6K1LXQNNGd1krE4xptwytm+YzpyG3BMxFmRGVQwmBfvYy7Auo6x92DVTftz4AuwROAF6QLWfUTkSicS/r"
}

#EC2 Instance
resource "aws_instance" "myec2instance" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.mykey.key_name

  network_interface {
    network_interface_id = aws_network_interface.myvmnic.id
    device_index         = 0
  }
}

resource "random_string" "random" {
  length    = 10
  special   = false
  lower     = true
  min_lower = 10
  numeric   = false
  upper     = false
}

#My S3 Bucket
resource "aws_s3_bucket" "mys3bucket" {
  bucket = random_string.random.id

  tags = {
    Name = "mybucket"
  }
}

resource "aws_iam_role" "test_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}
