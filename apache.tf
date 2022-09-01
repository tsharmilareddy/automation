# resource "aws_security_group" "apache-sg" {
#   name        = "apache-sg"
#   description = "connecting to bastion"
#   vpc_id   = "aws_vpc.vpc.id"

#   ingress {
#     description      = "connecting to bastion"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     security_groups = [aws_security_group.bastion.id]
#   }

# ingress {
#     description      = "connecting to enduser"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     security_groups = [aws_security_group.alb.id]
#   }
#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "apache-sg"
#   }
# }
