# Altran KAS Devops

## ¿Que contiene este repositorio?

Este repositorio contiene unos scripts de terraform que despliegan una aplicación  [Spring Boot de ejemplo](https://github.com/spring-projects/spring-boot/tree/master/spring-boot-samples/spring-boot-sample-hateoas) sobre una cuenta de AWS. Para lograr esto, se ha programado la construcción de lo siguiente:

* Un bucket S3 donde se guardará los estados de las ejecuciones de Terrafom
* Construye una VPC con una subred pública y dos subredes privadas.
* Construye una servidor EC2 en la subred pública, y se desplegará un nginx que hara las veces de balanceador. El punto de acceso será el puerto 443. El nginx se levantará dentro de un contenedor Docker. Este servidor irá en un grupo de seguridad con el puerto 443 y el 22 abierto.
* Construye dos servidores EC2, donde cada uno irá en una de las subredes privadas. En estos servidores se desplegará la aplicación de ejemplo, que se levantará en un contenedor docker, con el puerto 9000. Iran en un grupo de seguridad que solo aceptará peticiones del grupo de segurodad del balanceador, y solo por los puertos 9000 y 22.
* Para desplegar la aplicación, y a manera de demostración, hemos optado por compilar en vuelo la aplicación, levantando un docker con maven, que dejará el fichero jar en un directorio que utilizaremos en un docker compose que construirá la imagén que levantará la aplicación.


### Pre-requisitos

- Cuenta de AWS
- Terraform instalado en el servidor donde se clone el proyecto


## Arquitectura

![Optional Text](/images/arquitectura.png)


## Despliegue

### Construcción del S3

```
cd $HOME/altran-global-account/eu-west-1/s3-for-development
```

 `terraform init -backend-config="variables-backend.tfbackend"`

 `terrafom apply -var-file="user.tfvars"`


![Optional Text](/images/s3-state.png)



### Construcción de la VPC

```
cd $HOME/altran-dev-account/eu-west-1/vpc-dev
```

 `terraform init -backend-config="variables-backend.tfbackend"`

 `terrafom apply -var-file="user.tfvars"`


![Optional Text](/images/vpc-subnets.png)


### Construcción de los servidores EC2

```
cd $HOME/altran-dev-account/eu-west-1/ec2-dev
```

 `terraform init -backend-config="variables-backend.tfbackend"`

 `terrafom apply -var-file="user.tfvars"`


![Optional Text](/images/ec2.png)


## Resultados

### Salida de terraform

```
Apply complete! Resources: 14 added, 0 changed, 0 destroyed.
Releasing state lock. This may take a few moments...

Outputs:

private_ip_loadbalancer = 10.0.0.196
private_ip_springboot1 = 10.0.0.145
private_ip_springboot2 = 10.0.0.145
private_key = mykey.pem
public_ip_loadbalancer = 34.242.152.153
vpc_id = vpc-04360755ffbf47c03
```

### Resultado en el navegador


![Optional Text](/images/resultado.png)

Nota: todo la infraestructura fue destruida a través del comando

`terrafom apply -var-file="user.tfvars"`


### FICHEROS DE DESPLIGUE KUBERNETES

En la carpeta kubernetes-files, dejamos los ficheros para desplegar la aplicación. Para esta ocasión no he creado en AWS un EKS para probar la aplicación, me ha faltado un poquito de tiempo. 



## Autor

* **Fernando Oliveros** 


