variable "region_aws" {
  description = "La region donde se despliega"
  type        = string
  default     = "eu-south-2"
}

variable "tipo_instancia" {
  description = "El tamaño del server"
  type        = string
  default     = "t3.micro"
}

variable "puerto_web" {
  description = "Puerto para server web"
  type        = number
  default     = 80
}
