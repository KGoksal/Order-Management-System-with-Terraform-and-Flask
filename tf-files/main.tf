
# Define Application Load Balancer target group for order-table application instances
resource "aws_alb_target_group" "app-lb-tg" { 
  name        = "order-table-lb-tg" 
  port        = 80    
  protocol    = "HTTP"  
  vpc_id      = data.aws_vpc.selected.id  # VPC ID where the ALB and instances reside 
  target_type = "instance"   

  # Configure health check settings for instances in the target group
  health_check {
    healthy_threshold   = 2   
    unhealthy_threshold = 3   
  }
}


# Define Application Load Balancer (ALB) for order-table application 
resource "aws_alb" "app-lb" {
  name               = "order-table-lb-tf"
  ip_address_type    = "ipv4"  
  internal           = false 
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]  
  subnets            = data.aws_subnets.ot-subnets.ids  
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
# Define ALB listener to listen on HTTP port 80 and forward traffic to target group
resource "aws_alb_listener" "app-listener" {
  load_balancer_arn = aws_alb.app-lb.arn  
  port              = 80                  
  protocol          = "HTTP"
  
  # Default action: forward HTTP traffic to the defined target group 
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app-lb-tg.arn
  }
}


# https://developer.hashicorp.com/terraform/language/functions/templatefile
# Define launch template for Auto Scaling Group (ASG) configuration
resource "aws_launch_template" "asg-lt" {
  name                   = "order-table-lt"
  image_id               = data.aws_ami.al2023.id  # AMI ID for the EC2 instances
  instance_type          = "t2.micro"
  key_name               = var.key-name
  vpc_security_group_ids = [aws_security_group.server-sg.id]  
  # Provide user data script to configure instances on launch
  user_data              = base64encode(templatefile("userdata.sh", {
    db-endpoint         = aws_db_instance.db-server.address, 
    user-data-git-token = var.git-token, 
    user-data-git-name  = var.git-name    
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
  max_size                  = 3                                
  min_size                  = 1                                
  desired_capacity          = 1                                
  name                      = "order-table-asg"
  health_check_grace_period = 300                              
  health_check_type         = "ELB"                            
  target_group_arns         = [aws_alb_target_group.app-lb-tg.arn]  
  vpc_zone_identifier       = aws_alb.app-lb.subnets           
  launch_template {
    id      = aws_launch_template.asg-lt.id                    
    version = aws_launch_template.asg-lt.latest_version        
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
# Define RDS database instance for the order-table application
resource "aws_db_instance" "db-server" {
  instance_class              = "db.t3.micro"                   
  allocated_storage           = 20                              
  vpc_security_group_ids      = [aws_security_group.db-sg.id]   
  allow_major_version_upgrade = false                           
  auto_minor_version_upgrade  = true                           
  backup_retention_period     = 0                               
  identifier                  = "order-table-app-db"            
  db_name                     = "order_table"                   
  engine                      = "mysql"                         
  engine_version              = "8.0"                           
  username                    = "admin"                         
  password                    = "password#"                      
  monitoring_interval         = 0                               
  multi_az                    = false                           
  port                        = 3306                            
  publicly_accessible         = false                         
  skip_final_snapshot         = true                            
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
# Define Route 53 DNS record for the order-table application
# resource "aws_route53_record" "order-table" {
#   zone_id = data.aws_route53_zone.selected.zone_id  
#   name    = "order-table.${var.hosted-zone}"       
#   type    = "A"                                     

  # # Alias record configuration pointing to the ALB
  # alias {
  #   name                   = aws_alb.app-lb.dns_name    
  #   zone_id                = aws_alb.app-lb.zone_id     
  #   evaluate_target_health = true                     
  # }

