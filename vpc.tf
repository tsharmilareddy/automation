data "aws_availability_zones" "available" {
state= "available"

}



# to create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-sharmi"
  }
}


 #create igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "stage-igw"
  }
}

# # public subnet1

resource "aws_subnet" "public" {
  count=length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc.id
  map_public_ip_on_launch = true
   cidr_block = element(var.public_cidr,count.index)
  availability_zone = element(data.aws_availability_zones.available.names,count.index)


  tags = {
    Name = "stage-${count.index+1}-public"
  }
}

# #private
resource "aws_subnet" "private" {
  count=length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc.id
  #  map_public_ip_on_launch = true
   cidr_block = element(var.private_cidr,count.index)
  availability_zone = element(data.aws_availability_zones.available.names,count.index)


  tags = {
    Name = "stage-${count.index+1}-private"
  }
}

resource "aws_subnet" "data" {
  count=length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc.id
  #  map_public_ip_on_launch = true
   cidr_block = element(var.data_cidr,count.index)
  availability_zone = element(data.aws_availability_zones.available.names,count.index)


  tags = {
    Name = "stage-${count.index+1}-data"
  }
}



resource "aws_eip" "eip" {
vpc=true
}


resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "natgw"
  }
depends_on=[
  aws_eip.eip
]
}



resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }



  tags = {
    Name = "route-public"
  }
}




resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }



  tags = {
    Name = "route-private"
  }
}





resource "aws_route_table_association" "public" {
  count=length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public-route.id
}


resource "aws_route_table_association" "private" {
  count=length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private-route.id
}





resource "aws_route_table_association" "data" {
  count=length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.data[*].id,count.index)
  route_table_id = aws_route_table.private-route.id
}






































# resource "aws_route_table_association" "data1" {
#   subnet_id      = "subnet-09e6a845ec4590c24"
#   route_table_id = "rtb-062aed348f2cc50cc"
# }


# resource "aws_route_table_association" "data2" {
#   subnet_id      = "subnet-078fefb16944de695"
#   route_table_id = "rtb-062aed348f2cc50cc"
# }



# resource "aws_route_table_association" "data3" {
#   subnet_id      = "subnet-013ffcabcd5126ff8"
#   route_table_id = "rtb-062aed348f2cc50cc"
# }



# resource "aws_key_pair" "web" {
#   key_name   = "web.pem"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDURWyQzHrJbh4+Cp+lVg/ZIoy+v6Z4KJZryw1pmqtf/GaPiqx1uxZVr5Eq/u/f8Lcq9AWF1j6zS0Dyqrzl6e/tp6PW7cA+4AU/eBYnmma6vCXC1ZFSiOvoykL66/yOn7h2Gi7+HHXl10VQus5nrj0neueT0D7DLp/aSjnpy3gCGBSomeU7ojBMuZLjxxeEUkJdZfKAIQ41UwlpkX6Faj8ywHgJP3ku+vhRrrTgNdeTcK0dTLWoPy1THWciOEzz8IXykceZgnYKOOw5IEJkFUmENYO5JQPV6jBJBaojlSeCxOQtNG84L1y1qNe2wS1YB36FmHT1EzD4mv52kXzy5NyNfVUER6nGj7GMGOmMUfbq+3pCB1vYbnUade8Ct/lsdO7N3+f6VgIGLVTd5PRuK4Tnz7nBHlYU2BbaSI/qBpeqAX7RI6hqvHeWWO+kbpof3lb9HFKFmPQ9uOGJICtnSf1oB3jpztj+IWil5wsvjt8YpkKyFSJ0owDASu3mk5A2P+E= tshar@LAPTOP-311FQHDA"
# }



# resource "aws_instance" "vpc-bastion"{
# ami = "ami-0d8c9816466b422c6"
# subnet_id ="subnet-01cd5f58a8bc15acc"
# instance_type = "t2.micro"
# key_name = "web.pem"
# }




# resource "aws_eip" "bs-eip" {
#   instance = "i-07b52f2423b92e415"
#   vpc      = true
# }





# resource "aws_eip_association" "eip_assoc" {
#   instance_id   = "i-07b52f2423b92e415"
#   allocation_id = "eipalloc-081347a58d4fe4888"
# }




# resource "aws_instance" "vpc-apache"{
# ami = "ami-0d8c9816466b422c6"
# subnet_id ="subnet-01cd5f58a8bc15acc"
# instance_type = "t2.micro"
# key_name = "web.pem"


# resource "aws_security_group" "alb-sg" {
#   name        = "alb-sg"
#   description = "connecting to lb"
#   vpc_id      = "vpc-0d9320c9e56370288"

#   ingress {
#     description      = "connecting to lb"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "lb-sg"
#   }
# }



# resource "aws_lb" "alb" {
#   name               = "alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = ["sg-0bcf4d67086c97d89"]
#   vpc_id = "vpc-0d9320c9e56370288"
#   subnets            = [for subnet in aws_subnet.public : "subnet-0a8150f87dd4f20ef,subnet-0b5e9b34ff2d4188f,subnet-0276b9e4f155823ec"]

#   enable_deletion_protection = true


#   tags = {
#     Environment = "alb"
#   }
# }


# resource "aws_lb_target_group" "tg" {
#   name     = "tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = "vpc-0d9320c9e56370288"
# }

