resource "aws_security_group" "alb-sg" {
  name   = "ALBSecurityGroup"
  vpc_id = data.aws_vpc.selected.id  # Assumes you have a data source defined for aws_vpc

  tags = {
    Name = "TF_ALBSecurityGroup"
  }

  // Ingress rule allowing incoming HTTP (port 80) traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Egress rule allowing all outbound traffic (any port, any protocol) to anywhere
  egress {
    from_port   = 0 // all ports
    to_port     = 0 // all ports
    protocol    = "-1" // all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "server-sg" {
  name   = "WebServerSecurityGroup"
  vpc_id = data.aws_vpc.selected.id  # Assumes you have a data source defined for aws_vpc

  tags = {
    Name = "TF_WebServerSecurityGroup"
  }

  // Ingress rule allowing incoming HTTP (port 80) traffic from ALB security group
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.alb-sg.id]  // Allows traffic only from ALB security group
  }

  // Ingress rule allowing incoming SSH (port 22) traffic from anywhere. in order to check the ec2 instances
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Egress rule allowing all outbound traffic (any port, any protocol) to anywhere
  egress {
    from_port   = 0 // all ports
    to_port     = 0 // all ports
    protocol    = "-1" // all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db-sg" {
  name   = "RDSSecurityGroup"
  vpc_id = data.aws_vpc.selected.id  # Assumes you have a data source defined for aws_vpc

  tags = {
    Name = "TF_RDSSecurityGroup"
  }

  // Ingress rule allowing incoming MySQL (port 3306) traffic from server security group
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.server-sg.id]  // Allows traffic only from server security group
  }

  // Egress rule allowing all outbound traffic (any port, any protocol) to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


/* -- -------------------------------------------------------- PURPOSE  --------------------------------------------------------
aws_security_group "alb-sg":
Purpose: This security group is created for the Application Load Balancer (ALB).
Reason: It allows inbound HTTP traffic (port 80) from any IP address (0.0.0.0/0). This is essential for the ALB to receive HTTP requests from clients on the internet.

aws_security_group "server-sg":
Purpose: This security group is created for the web server instances.
Reason: It allows inbound HTTP traffic (port 80) from the ALB security group (aws_security_group.alb-sg.id). This ensures that only the ALB can communicate with the web servers over HTTP. It also allows inbound SSH traffic (port 22) from any IP address (0.0.0.0/0) for administrative purposes. Outbound traffic is allowed to anywhere (0.0.0.0/0).

aws_security_group "db-sg":
Purpose: This security group is created for the RDS database instance.
Reason: It allows inbound MySQL traffic (port 3306) only from the server security group (aws_security_group.server-sg.id). This restricts database access to only the web server instances, ensuring a more secure communication path between the application and the database. Outbound traffic is allowed to anywhere (0.0.0.0/0), which is typically required for databases to communicate with clients and services. */
