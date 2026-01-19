terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
    }
    backend "s3" {
        bucket = "tf-state-xavi-2024-zaragoza-v1" # El nombre del bucket debe ser unico a nivel global
        key    = "global/s3/terraform.tfstate"
        region = "eu-south-2"
    
        dynamodb_table = "terraform-locks" # Tabla para locking
        encrypt        = true               # Encriptacion del state
        skip_region_validation = true
    }
}

provider "aws" {
    region = var.region_aws  # usamos la region de ES en zaragoza
}

# Consulto zonas de disponibilidad en la region
data "aws_availability_zones" "available" {
    state = "available"
}

# VPC
resource "aws_vpc" "mi_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "VPC-Espana"
    }
}

# Subred de Frontend
resource "aws_subnet" "frontend" {
    vpc_id = aws_vpc.mi_vpc.id # Referencio la vpc de arriba
    cidr_block = "10.0.1.0/24" # creamos subred con 254 ips
    # Uso la zona disponible en la lista
    availability_zone = data.aws_availability_zones.available.names[0]

    tags = {
        Name = "Subred-Frontend-Dinamica"
    }
}

# Subred de Backend
resource "aws_subnet" "backend" {
    vpc_id = aws_vpc.mi_vpc.id # Referencio la vpc de arriba
    cidr_block = "10.0.2.0/24" # creamos subred con 254 ips
    availability_zone = "eu-south-2a" # usamos la zona a de spain

    tags = {
        Name = "Subred-Backend"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.mi_vpc.id

    tags = {
        Name = "Mi-Gateway-Internet"
    }
}

# Tabla de rutas
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.mi_vpc.id

    route {
        cidr_block = "0.0.0.0/0" #Defino todo el trafico
        gateway_id = aws_internet_gateway.gw.id #Lo tiro todo al gw de internet creadso antes
    }

    tags = {
        Name = "Tabla-Rutas-Publica"
    }
}


# Ahora asocio la tabla de rutas a la subred de frontend
resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.frontend.id
    route_table_id = aws_route_table.public_rt.id
}

# Security Group (FW)
resource "aws_security_group" "servidor_sg" {
    name = "servidor_sg"
    description = "Permitir SSH y HTTP"
    vpc_id = aws_vpc.mi_vpc.id
    # SSH
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # HTTP
    ingress {
        from_port = var.puerto_web
        to_port = var.puerto_web
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # Salida
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Llave SSH para acceso a la instancia
resource "aws_key_pair" "mi_key" {
    key_name   = "mi-llave-${timestamp()}" # Esto le añade la fecha/hora al nombre
    public_key = file("~/.ssh/id_rsa.pub")
}

# Busco la ami mas nueva de amazon
data "aws_ami" "amazon_linux" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["al2023-ami-2023.*-x86_64"] # Es la ami de amazon linux 2023
    }
}

# La instancia en si.
resource "aws_instance" "web" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = var.tipo_instancia
    subnet_id = aws_subnet.frontend.id
    private_ip = "10.0.1.50"

    vpc_security_group_ids = [aws_security_group.servidor_sg.id]
    key_name = aws_key_pair.mi_key.key_name
    associate_public_ip_address = true

    # Script de inicio (User Data) - Se ejecuta solo la primera vez
    user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd
                systemctl start httpd
                systemctl enable httpd
                echo "<h1 style='color:green;'>¡Tengo IPs FIJAS! 🌵</h1>" > /var/www/html/index.html
                EOF

  tags = { Name = "Servidor-Web-Espana" }
}

# Creo una elastic ip fija
resource "aws_eip" "ip_fija" {
    instance = aws_instance.web.id
    domain = "vpc"

    tags = {
        Name = "Mi-IP-Elastica-Fija"
    }
}


# BACKEND - Almacenamiento de datos

# 1. Cubo S3 para guardar terraform state
resource "aws_s3_bucket" "terraform_state" {
    bucket = "tf-state-xavi-2024-zaragoza-v1" # El nombre del bucket debe ser unico a nivel global
    force_destroy = true  # Para borrar el bucket aunque tenga objetos dentro

    tags = {
        Name = "Bucket-Terraform-State"
    }
}

# Habilito versionado en el bucket
resource "aws_s3_bucket_versioning" "versioning" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}

# 2. Tabla DynamoDB para locking
resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID" # Clave primaria
    attribute {
        name = "LockID"
        type = "S"
    }   
    tags = {
        Name = "Terraform-Lock-Table"
    }
}    