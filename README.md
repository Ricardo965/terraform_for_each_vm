# Proyecto Terraform - Infraestructura con VMs y Webhook de GitHub

Este es un proyecto donde estoy utilizando Terraform para levantar infraestructura en la nube de forma automatizada. El objetivo principal es provisionar múltiples máquinas virtuales usando un `for_each`, y configurar un webhook de GitHub apuntando a la IP pública de una VM que utilizo como servidor Jenkins.

## 🏗️ Estructura del Proyecto

```bash
.
├── main.tf                     # Archivo principal donde orquesto los módulos
├── modules                    # Contiene los módulos reutilizables
│   ├── gh                     # Módulo para manejar el webhook de GitHub
│   │   ├── main.tf
│   │   └── variables.tf
│   └── vm                     # Módulo para crear máquinas virtuales
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf                 # Definición de outputs globales
├── providers.tf               # Configuración de proveedores de Terraform
├── README.md                  # Este archivo :)
├── secrets.tfvars             # Variables sensibles (no se sube al repo)
├── terraform.sh               # Script para automatizar comandos terraform
└── variables.tf               # Variables globales
```

## 🚀 ¿Qué hace este proyecto?

1. **Provisionamiento de VMs**  
   Utilizo un módulo (`modules/vm`) para levantar múltiples máquinas virtuales. Uso un `for_each` para iterar sobre una lista/mapa de configuraciones y así evitar repetir código.

2. **Servidor Jenkins**  
   Entre las máquinas que levanto, una de ellas está etiquetada como `jenkins`. A esta le asigno una IP pública, ya que la necesito para que sea accesible desde GitHub.

3. **Webhook de GitHub**  
   Con otro módulo (`modules/gh`) creo un webhook en un repositorio de GitHub. Este webhook apunta a la IP pública de la VM `jenkins`, lo que me permite automatizar tareas CI/CD desde GitHub hacia Jenkins.

## ⚙️ Cómo usarlo

### 1. Configurá tus variables

En el archivo `secrets.tfvars` deberías definir tus credenciales y configuraciones privadas, como tokens de GitHub, claves SSH, etc.

Dado que el proyecto corre en mi maquina donde estoy logeado en GitHub, por defecto usa esas credenciales para poder crear el webhook. En caso de que la maquina donde correría el proyecto no se esté logeado en github, se recomienda incluir el token PAT en las variables.

```hcl
subscription_id = "sub_id_az"

# Configuraciones adicionales
prefix_name = "project-tsaj"
region      = "eastus"

# Configuraciones de credenciales de la VM
user     = "adminuser"
password = "SecretPassword1234!"
# servers  = ["jenkins"]
servers = ["jenkins", "nginx"]
```

### 2. Ejecutá Terraform

Todo el despliegue está automatizado en el script terraform.sh

```bash
chmod +x terraform.sh
```

```bash
./terraform.sh
```

O manualmente:

```bash
terraform init
terraform fmt
terraform validate
terraform plan -var-file="secrets.tfvars"
terraform apply -var-file="secrets.tfvars -auto-approve"
```

### 3. Despliegue

Una vez desplegado, se cuenta con las VM para jenkins y para nginx.
El script automatiza el despliegue y la creación de un archivo .txt llamado `ips.txt`. Este archivo de usa para almacenar las ips de las maquinas virtuales en el formato:

```bash
jenkins: dir_ip
nginx: dir_ip
```

El script crea el archivo al mismo nivel que la carpeta padre de este proyecto

```
.
├── terraform_for_each_vm/
├── ips.txt

```

Esto es para usarse de manera simultánea con el proyecto [ansible-pipeline](https://github.com/Ricardo965/ansible-pipeline) que cuenta con los scripts restantes para manipular y aprovisionar la infraestructura con nginx y las configuraciones de Sonar y Jenkins en la VM correspondiente.

La estructura recomendada del conjunto de proyectos para el correcto funcionamiento del despliegue es la siguiente:

```
.
├── ansible-pipeline
├── deploy.sh
├── ips.txt
├── KeyboardDeploy
├── terraform_for_each_vm
└── update_hosts.sh

```
