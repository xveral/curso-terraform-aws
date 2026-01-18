output "url_web" {
    description = "URL con IP elastica"  
    value = "http://${aws_eip.ip_fija.public_ip}"
}

output "comando_ssh" {
    description = "SSH con IP elastica"
    value = "ssh ec2-user@${aws_eip.ip_fija.public_ip}"
}

output "ip_privada_fija" {
    value = aws_instance.web.private_ip
}