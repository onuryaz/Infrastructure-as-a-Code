### Set a Provider ###
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

### Get Data from other Resources ###

# Get Availability Zones
data "aws_availability_zones" "available" {}

# Get the Webservers Load Balancers
data "aws_elb" "selected" {
  name = "knox-loadbalancer"

  tags {
    Name = "knox-loadbalancer"
  }
}

### Configure DNS Services ###

# Hosted Zones
resource "aws_route53_zone" "knox_com" {
  name    = "knox.com"
  comment = "Hosted Zone for Knox Domain"
}

### Configure the Records ###

# NS Record
resource "aws_route53_record" "knox_com_ns" {
  zone_id = "${aws_route53_zone.knox_com.zone_id}"
  name    = "knox.com"
  type    = "NS"
  ttl     = "30"
  records = ["${slice(aws_route53_zone.knox_com.name_servers,0,4)}"]
}

# A Record
resource "aws_route53_record" "knox_com" {
  zone_id = "${aws_route53_zone.knox_com.zone_id}"
  name    = "knox.com"
  type    = "A"

  alias {
    name                   = "${data.aws_elb.selected.dns_name}"
    zone_id                = "${data.aws_elb.selected.zone_id}"
    evaluate_target_health = true
  }
}

# CNAME Record
resource "aws_route53_record" "www_knox_com" {
  zone_id = "${aws_route53_zone.knox_com.zone_id}"
  name    = "www.knox.com"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 20
  }

  set_identifier = "www"
  records        = ["${aws_route53_record.knox_com.name}"]
}

# SSL knox.com CNAME Record
resource "aws_route53_record" "ssl_knox_com" {
  zone_id = "${aws_route53_zone.knox_com.zone_id}"
  name    = "_2ec6ec68ba50037b0abe4ca463edca19.knox.com"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 40
  }

  set_identifier = "http"
  records        = ["_bdbf85e9dc761fe734211bfb8567891b.acm-validations.aws"]
}

# SSL www.knox.com CNAME Record
resource "aws_route53_record" "ssl_www_knox_com" {
  zone_id = "${aws_route53_zone.knox_com.zone_id}"
  name    = "_9dff6087c3d3457f0d2ed319bc41ff78.www.knox.com"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 40
  }

  set_identifier = "www"
  records        = ["_e974f3a093fddc9309b75402260477by.acm-validations.aws"]
}
