output "RDS Address" {
  value = "${aws_db_instance.bloverse_db.address}"
}

output "RDS Endpoint" {
  value = "${aws_db_instance.bloverse_db.endpoint}"
}

output "RDS Name" {
  value = "${aws_db_instance.bloverse_db.name}"
}

output "RDS Port" {
  value = "${aws_db_instance.bloverse_db.port}"
}

output "RDS Username" {
  value = "${aws_db_instance.bloverse_db.username}"
}