output "ELB URI" {
  value = "${aws_elb.load_balancer.dns_name}"
}

output "SSL ARN" {
  value = "${aws_acm_certificate.bloverse_ssl.arn}"
}

