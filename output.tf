#To print out public ip
output "master_ip" {
  value = aws_instance.master.public_ip
}

output "workers_ip" {
  value = aws_instance.worker.*.public_ip

}
