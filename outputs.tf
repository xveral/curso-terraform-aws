output "urls_web" {
  description = "URLs de todas las instancias web"
  value       = [for ip in aws_eip.ip_fija[*].public_ip : "http://${ip}"]
}

output "comando_ssh" {
  description = "SSH con IP elastica"
  value       = [for ip in aws_eip.ip_fija[*].public_ip : "ssh ec2-user@${ip}"]
}

output "ips_privadas_fijas" {
  value = [for ip in aws_instance.web[*].private_ip : "${ip}"]
}

output "zona_despliegue" {
  description = "Nombre de la zona de disponibilidad (ej. eu-south-2a)"
  value       = aws_instance.web[*].availability_zone
}

output "id_fisico_zona" {
  description = "ID físico real en Aragón (eus2-az1 (zgz), az2 (Huesca) o az3 (Teruel))"
  value       = data.aws_subnet.selected.availability_zone_id
}