output "publicip" {
    value = aws_instance.my_instance.public_ip
}