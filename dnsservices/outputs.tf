output "DNS NAME SERVERS" {  
  value = "${aws_route53_zone.bloverse_com.name_servers}"
}