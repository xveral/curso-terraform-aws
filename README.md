# 🚀 AWS Scalable Infrastructure with Terraform (Spain Region)

Este repositorio contiene una infraestructura automatizada en AWS desplegada mediante **Terraform**, optimizada para la región de **España (eu-south-2)**.

El proyecto ha evolucionado para soportar **Múltiples Entornos (Workspaces)**, **Alta Disponibilidad** mediante bucles de instancias y **CI/CD** con GitHub Actions.

## 🏗️ Arquitectura
La infraestructura despliega los siguientes recursos:

* **Networking:**
    * VPC personalizada (`10.0.0.0/16`) con nombres dinámicos por entorno.
    * Subredes Públicas (Frontend) y Privadas (Backend).
    * Internet Gateway y Tablas de Enrutamiento.
    * Security Groups para acceso SSH (22) y HTTP (80).
* **Computación (Scalable):**
    * Despliegue de **múltiples instancias EC2** (definido por variable) en bucle.
    * Sistema Operativo Amazon Linux 2023.
    * Servidor web Apache preinstalado (`user_data`) mostrando el índice de la instancia.
    * Asociación automática de **Elastic IPs** para cada instancia.
* **Estado y Gestión:**
    * **Backend Remoto:** Estado guardado en S3 (`eu-south-2`) con bloqueo en DynamoDB.
    * **Lógica Condicional:** El Bucket S3 y la tabla DynamoDB solo se crean en el workspace `default`.

## 📂 Estructura del Proyecto

El código se ha modularizado para seguir las mejores prácticas:

| Archivo | Descripción |
| :--- | :--- |
| `main.tf` | Definición de recursos principales (VPC, EC2, SG). |
| `variables.tf` | Variables de entrada configurables (cantidad de servidores, región, etc.). |
| `outputs.tf` | Información de retorno (URLs, IPs, Comandos SSH). |
| `versions.tf` | Configuración del Provider AWS y Backend S3. |
| `.github/workflows/` | Pipeline de CI para validar sintaxis y formato automáticamente. |

## 🛠️ Requisitos previos
1.  [Terraform](https://www.terraform.io/) instalado (v1.0+).
2.  [AWS CLI](https://aws.amazon.com/cli/) configurado con credenciales.
3.  Un par de claves SSH generado en `~/.ssh/id_rsa.pub`.

## 🚀 Guía de Uso con Workspaces

Este proyecto utiliza **Terraform Workspaces** para separar entornos (ej. `dev`, `prod`).

### 1. Inicialización
Descarga los providers y configura el backend.
```bash
terraform init
```
### 2. Gestión de Entornos
Nunca trabajamos en default para desplegar aplicaciones. Creamos entornos aislados:
Crear un nuevo entorno (ej. desarrollo)
```bash
# Crear un nuevo entorno (ej. desarrollo)
terraform workspace new dev

# Listar entornos disponibles
terraform workspace list

# Cambiar entre entornos
terraform workspace select dev
```
### 3. Personalizar el Despliegue
Puedes cambiar cuántas máquinas quieres editando variables.tf o pasando la variable por comando:
```bash
# Desplegar 3 servidores en el entorno actual
terraform apply -var="cantidad_instancias=3"
```
### 4. Limpieza (Destroy)
⚠️ Importante: Debido a la dependencia del backend, seguimos este orden para destruir:
1. Destruir entornos de aplicación (dev, prod):
```bash
terraform workspace select dev
terraform destroy
```
2. Destruir infraestructura base (Solo si quieres borrar el Bucket S3):
```bash
terraform workspace select default
terraform destroy
```
⚙️ Variables Configurables (variables.tf)

| Variable            | Descripción                     | Valor por defecto |
|---------------------|---------------------------------|-------------------|
| `region_aws`       | Región de despliegue           | `eu-south-2` (Spain) |
| `cantidad_instancias` | Número de servidores a crear    | `2`               |
| `tipo_instancia`    | Tamaño de la EC2               | `t3.micro`        |
| `puerto_web`        | Puerto para el Security Group   | `80`              |

📊 Outputs

Al finalizar, tendremos listas de acceso para todas las máquinas:

urls_webs: Lista de URLs HTTP para acceder a cada servidor.

comandos_ssh: Lista de comandos directos para conectar por terminal.

ids_instancias: IDs de AWS de los recursos creados.

🤖 CI/CD (GitHub Actions)

Este repositorio incluye un flujo de trabajo automático que se ejecuta en cada push a la rama main:

Format Check: Verifica que el código esté bien indentado (terraform fmt).

Validation: Comprueba la sintaxis y lógica (terraform validate).