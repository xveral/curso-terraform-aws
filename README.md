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
Crear un nuevo entorno (ej. desarrollo)
```bash
terraform workspace new dev
Listar entornos disponibles
```bash
terraform workspace list
Cambiar entre entornos
```bash
terraform workspace select dev