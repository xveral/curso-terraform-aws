output "url_web" {
  description = "URL con IP elastica"
  value       = "http://${aws_eip.ip_fija.public_ip}"
}

output "comando_ssh" {
  description = "SSH con IP elastica"
  value       = "ssh ec2-user@${aws_eip.ip_fija.public_ip}"
}

output "ip_privada_fija" {
  value = aws_instance.web.private_ip
}

output "zona_despliegue" {
  description = "Nombre de la zona de disponibilidad (ej. eu-south-2a)"
  value       = aws_instance.web.availability_zone
}

output "id_fisico_zona" {
  description = "ID físico real en Aragón (eus2-az1 (zgz), az2 (Huesca) o az3 (Teruel))"
  value       = data.aws_subnet.selected.availability_zone_id
}