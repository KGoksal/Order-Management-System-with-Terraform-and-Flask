# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
# Define Application Load Balancer target group for order-table application instances
resource "aws_alb_target_group" "app-lb-tg" {
  name        = "order-table-lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.selected.id  # VPC ID where the ALB and instances reside
  target_type = "instance"  # Targets are EC2 instances

  # Configure health check settings for instances in the target group
  health_check {
    healthy_threshold   = 2   # Number of consecutive successful health checks to consider instance healthy
    unhealthy_threshold = 3   # Number of consecutive failed health checks to consider instance unhealthy
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
# Define Application Load Balancer (ALB) for order-table application
resource "aws_alb" "app-lb" {
  name               = "order-table-lb-tf"
  ip_address_type    = "ipv4"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]  # Attach ALB security group for inbound traffic control
  subnets            = data.aws_subnets.ot-subnets.ids  # Subnets where ALB will distribute traffic
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
# Define ALB listener to listen on HTTP port 80 and forward traffic to target group
resource "aws_alb_listener" "app-listener" {
  load_balancer_arn = aws_alb.app-lb.arn  # ARN of the ALB
  port              = 80                  # HTTP port
  protocol          = "HTTP"
  
  # Default action: forward HTTP traffic to the defined target group 
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app-lb-tg.arn
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
# https://developer.hashicorp.com/terraform/language/functions/templatefile
# Define launch template for Auto Scaling Group (ASG) configuration
resource "aws_launch_template" "asg-lt" {
  name                   = "order-table-lt"
  image_id               = data.aws_ami.al2023.id  # AMI ID for the EC2 instances
  instance_type          = "t2.micro"
  key_name               = var.key-name
  vpc_security_group_ids = [aws_security_group.server-sg.id]  # Security group for EC2 instances
  # Provide user data script to configure instances on launch
  user_data              = base64encode(templatefile("userdata.sh", {
    db-endpoint         = aws_db_instance.db-server.address,  # Database endpoint for the application
    user-data-git-token = var.git-token,  # Git token for cloning the application repository
    user-data-git-name  = var.git-name    # Git username for cloning the application repository
  }))
  
  # Tag specification for instances launched by this template
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Web Server of Order-Table App"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
# Define Auto Scaling Group (ASG) for managing EC2 instances
resource "aws_autoscaling_group" "app-asg" {
  max_size                  = 3                                # Maximum number of instances in the ASG
  min_size                  = 1                                # Minimum number of instances in the ASG
  desired_capacity          = 1                                # Initial desired capacity of instances
  name                      = "order-table-asg"
  health_check_grace_period = 300                              # Grace period for instance health checks
  health_check_type         = "ELB"                            # Health check type: Elastic Load Balancer
  target_group_arns         = [aws_alb_target_group.app-lb-tg.arn]  # Target group for the ASG
  vpc_zone_identifier       = aws_alb.app-lb.subnets           # Subnets where instances will be launched
  launch_template {
    id      = aws_launch_template.asg-lt.id                    # ID of the launch template
    version = aws_launch_template.asg-lt.latest_version        # Latest version of the launch template
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
# Define RDS database instance for the order-table application
resource "aws_db_instance" "db-server" {
  instance_class              = "db.t3.micro"                   # Instance type for the RDS instance
  allocated_storage           = 20                              # Allocated storage in GB
  vpc_security_group_ids      = [aws_security_group.db-sg.id]   # Security group for the RDS instance
  allow_major_version_upgrade = false                           # Disallow major version upgrades
  auto_minor_version_upgrade  = true                            # Allow minor version upgrades automatically
  backup_retention_period     = 0                               # Backup retention period in days (0 means no backup)
  identifier                  = "order-table-app-db"            # Identifier for the RDS instance
  db_name                     = "order_table"                   # Default database name
  engine                      = "mysql"                         # Database engine (MySQL)
  engine_version              = "8.0"                           # MySQL version
  username                    = "admin"                         # Master username for database access
  password                    = "password#"                      # Master password for database access
  monitoring_interval         = 0                               # Monitoring interval in seconds (0 means no monitoring)
  multi_az                    = false                           # Disable Multi-AZ deployment
  port                        = 3306                            # Database port
  publicly_accessible         = false                           # Disable public accessibility
  skip_final_snapshot         = true                            # Skip final DB snapshot on instance termination
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
# Define Route 53 DNS record for the order-table application
# resource "aws_route53_record" "order-table" {
#   zone_id = data.aws_route53_zone.selected.zone_id  # Route 53 hosted zone ID where the record will be created
#   name    = "order-table.${var.hosted-zone}"        # DNS name for the application
#   type    = "A"                                     # Record type: A record

  # # Alias record configuration pointing to the ALB
  # alias {
  #   name                   = aws_alb.app-lb.dns_name    # DNS name of the ALB
  #   zone_id                = aws_alb.app-lb.zone_id     # Zone ID of the ALB
  #   evaluate_target_health = true                       # Evaluate target health for the ALB
  # }

