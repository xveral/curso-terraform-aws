# 🚀 AWS Infrastructure with Terraform (Spain Region)

Este repositorio contiene una infraestructura básica en AWS desplegada mediante **Terraform**, optimizada para la región de **España (eu-south-2)** en Zaragoza.

## 🏗️ Arquitectura
La infraestructura incluye:
- **VPC** personalizada con direccionamiento `10.0.0.0/16`.
- **Subredes Dinámicas**: Selección automática de Zonas de Disponibilidad (Zaragoza/Huesca) mediante bloques `data`.
- **Instancia EC2**: Servidor Amazon Linux 2023 con servidor web Apache autoinstalado via `user_data`.
- **Seguridad**: Security Groups configurados para acceso SSH (22) y HTTP (80).
- **Identidad**: Uso de claves SSH locales (`id_rsa.pub`).
- **Estado Remoto**: Configuración de Backend en **S3** con bloqueo mediante **DynamoDB**.

## 🛠️ Requisitos previos
1. Tener instalado [Terraform](https://www.terraform.io/).
2. Configurar [AWS CLI](https://aws.amazon.com/cli/) con tus credenciales.
3. Habilitar la región `eu-south-2` en tu cuenta de AWS.

## 🚀 Despliegue rápido

1. **Clonar el repo:**
   ```bash
   git clone [https://github.com/tu-usuario/curso-terraform-aws.git](https://github.com/tu-usuario/curso-terraform-aws.git)
   cd curso-terraform-aws

Nota: Inicializar (Modo Local): Comenta el bloque backend "s3" en main.tf si es la primera vez que lo lanzas en una cuenta nueva, then:
terraform init
terraform apply
Activar Backend Remoto: Descomenta el bloque backend "s3" y migra el estado, then:
terrform init

Al finalizar, el proyecto te devolverá:

url_web: Dirección para ver el "Hola xxxxx.

zona_despliegue: AZ donde ha caído la instancia.

id_fisico_zona: ID real del centro de datos en Aragón.