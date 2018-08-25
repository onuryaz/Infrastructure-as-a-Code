### Set a Provider ###
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

### Get Data from other Resources ###

# Get Availability Zones
data "aws_availability_zones" "available" {}

# Get Local Data
data "template_file" "user_data" {
  template = "${file("bootstrap-webserver.sh")}"

  vars {
    app_port = "${var.app_port}"
  }
}

### Create Security Groups ###

# Create the Load Balancer Security Group
resource "aws_security_group" "knox_loadbalancer_sg" {
  name = "knox-loadbalancer-sg"

  ingress {
    from_port   = "${var.http_port}"
    to_port     = "${var.http_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.https_port}"
    to_port     = "${var.https_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "knox-loadbalancer-sg"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

# Create the Web Server Security Group
resource "aws_security_group" "knox_webservers_sg" {
  name = "knox-webservers-sg"

  ingress {
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.knox_loadbalancer_sg.id}"]
  }

  ingress {
    from_port       = "${var.http_port}"
    to_port         = "${var.http_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.knox_loadbalancer_sg.id}"]
  }

  ingress {
    from_port       = "${var.https_port}"
    to_port         = "${var.https_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.knox_loadbalancer_sg.id}"]
  }

  ingress {
    from_port   = "${var.ssh_port}"
    to_port     = "${var.ssh_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "knox-webservers-sg"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

# Create the Database Security Group
resource "aws_security_group" "knox_db_sg" {
  name = "knox-db-sg"

  ingress {
    from_port       = "${var.db_port}"
    to_port         = "${var.db_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.knox_webservers_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "knox-db-sg"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

### Create an SSL Certificate ###
resource "aws_acm_certificate" "knox_ssl" {
  domain_name               = "knox.com"
  subject_alternative_names = ["www.knox.com"]
  validation_method         = "DNS"

  tags {
    Name        = "knox-ssl-certificate"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

### Create a Load Balancer and Associate its SG ###

# Create a Load Balancer
resource "aws_elb" "knox_loadbalancer" {
  name               = "knox-loadbalancer"
  availability_zones = ["${slice(data.aws_availability_zones.available.names,0,2)}"]
  security_groups    = ["${aws_security_group.knox_loadbalancer_sg.id}"]

  listener {
    lb_port           = "${var.http_port}"
    lb_protocol       = "http"
    instance_port     = "${var.app_port}"
    instance_protocol = "http"
  }

  listener {
    lb_port            = "${var.https_port}"
    lb_protocol        = "https"
    instance_port      = "${var.app_port}"
    instance_protocol  = "http"
    ssl_certificate_id = "${aws_acm_certificate.knox_ssl.arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.app_port}/"
  }

  tags {
    Name        = "knox-loadbalancer"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

### Create Web Server Clusters ###

# Create a Launch Configuration for the Web Servers
resource "aws_launch_configuration" "knox_webserver" {
  image_id        = "${var.web_ami}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_pair_name}"
  security_groups = ["${aws_security_group.knox_webservers_sg.id}"]

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

# Create the Web Server Clusters from the Launch Configuration
resource "aws_autoscaling_group" "knox_webservers_asg" {
  name                 = "knox-webservers-asg"
  launch_configuration = "${aws_launch_configuration.knox_webserver.id}"
  load_balancers       = ["${aws_elb.load_balancer.name}"]
  availability_zones   = ["${slice(data.aws_availability_zones.available.names,0,2)}"]
  health_check_type    = "ELB"
  min_size             = "${var.asg_min_size}"
  max_size             = "${var.asg_max_size}"

  tag {
    key                 = "Name"
    value               = "knox-webserver-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "${var.project}"
    propagate_at_launch = true
  }
}

# Define the Web Cluster Scaling Policies
resource "aws_autoscaling_policy" "knox_asg_scaling_policy" {
  name                      = "knox-asg-scaling-policy"
  adjustment_type           = "ChangeInCapacity"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 300
  autoscaling_group_name    = "${aws_autoscaling_group.knox_webservers_asg.name}"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}

# Schedule Web Cluster Behaviour On-Peak, Off-Peak Hours and Weekends
resource "aws_autoscaling_schedule" "on_peak_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 4
  desired_capacity      = 2
  recurrence            = "0 9 * * *"

  autoscaling_group_name = "${aws_autoscaling_group.knox_webservers_asg.name}"
}

resource "aws_autoscaling_schedule" "off_peak_hours" {
  scheduled_action_name = "scale-in-at-night"
  min_size              = 1
  max_size              = 3
  desired_capacity      = 1
  recurrence            = "0 17 * * *"

  autoscaling_group_name = "${aws_autoscaling_group.knox_webservers_asg.name}"
}

# Define the Monitoring Notification

resource "aws_cloudwatch_metric_alarm" "high_cpu_usage" {
  alarm_name          = "${var.environment}-high-cpu-usage"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 300
  statistic           = "Average"
  threshold           = 80
  unit                = "Percent"
  alarm_actions       = ["${aws_autoscaling_policy.knox_webservers_asg.arn}"]

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.knox_webservers_asg.name}"
  }
}