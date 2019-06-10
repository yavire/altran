#terraform init -backend-config="variables-backend.tfbackend"
#terraform plan -var-file="user.tfvars"
#terraform apply -var-file="user.tfvars"

resource "aws_key_pair" "key_pair" {
  key_name   = "mykey"
  public_key = "${file("${var.public_key}")}"
}

#Generación del servidor que hace de Load Balancer
resource "aws_instance" "ec2_loadbalancer" {
  
  ami           = "ami-03c242f4af81b2365"
  instance_type = "t2.micro"

  #Construimos el servidor en la subred pública. Se podría optar por la solución de sustituir este servidor por
  #un ELB que tenga como destino el grupo de seguridad asociado a los servidores con los microservicios.
  subnet_id      = "${element(data.terraform_remote_state.vpc.public_subnets,0)}"

  #Grupo de seguridad que solo acepta entradas por le puerto 443 y el 22 (este prescindible).
  vpc_security_group_ids = ["${module.security_group_loadbalancer.this_security_group_id}"]
  key_name = "${aws_key_pair.key_pair.key_name}"

  #Copiamos el script que se ejecutará posteriormente, también copiamos el certificado.
  provisioner "file" {
    source      = "files-loadbalancer/"
    destination = "/tmp"

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("${var.private_key}")}"
    }
  }

  #Enviamos el fichero de configuración del nginx, este contiene las direcciones privadas de los servidores que tienen
  #el microservicio springboot
  provisioner "file" {
    content     = "${data.template_file.nginx_loadbalancer.rendered}"
    destination = "/tmp/nginx.conf"

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("${var.private_key}")}"
    }
  }

  #Ejecutamos el script que construye un docker con nginx, que hará la vez de load balancer
  #y que escucha por el puerto 443, con su certificado autofirmado...
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/loadbalancer-docker.sh",
      "/tmp/loadbalancer-docker.sh",

    ]

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("${var.private_key}")}"
    }
  }
  
 tags = {
    Name          = "${var.project_name}-${var.account}-loadbalancer"
    Terraform     = "true"
    Project       = "${var.project_name}"
    Company       = "${var.company_name}"
    Account       = "${var.account}"
    Bucket-state  = "${var.company_name}-${var.account}-${var.aws_region}-tfdbstate"
  }
}

#Hacemos interpolación de las direcciones IP en el template de configuración del nginx de balanceo.
data "template_file" "nginx_loadbalancer" {
  template = "${file("templates-loadbalancer/nginx.tpl")}"
  vars = {
    springboot1_private_address = "${aws_instance.ec2_springboot1.private_ip}"
    springboot2_private_address = "${aws_instance.ec2_springboot2.private_ip}"
  }
}

#Generamos el primero de los microservicios, en la subred privada 0
resource "aws_instance" "ec2_springboot1" {
  
  ami           = "ami-03c242f4af81b2365"
  instance_type = "t2.micro"

  #Para este test, creo las instancias en la pública, en vez de la subred privada, para no tener que generar un NAT Gateway, que tiene coste -:)
  #subnet_id = "${element(data.terraform_remote_state.vpc.private_subnets,0)}"
  subnet_id = "${element(data.terraform_remote_state.vpc.public_subnets,0)}"
  vpc_security_group_ids = ["${module.security_group_springboot.this_security_group_id}"]
  key_name = "${aws_key_pair.key_pair.key_name}"
  
  #Copiamos el script que se ejecutará posteriormente, también copiamos el Dockerfile que permitirá construir nuestro microservicio
  provisioner "file" {
    source      = "files-springboot/"
    destination = "/tmp"

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("${var.private_key}")}"
    }
  }

  #Ejecutamos el script, que clona de git el repositorio de spring-boot, luego compila a través de un docker de maven y construue el jar.
  #El jar será utilizado por el docker que levantará el microservicio.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/springboot-docker.sh",
      "/tmp/springboot-docker.sh",

    ]

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("${var.private_key}")}"
    }
  }

 tags = {
    Name          = "${var.project_name}-${var.account}-springboot1"
    Terraform     = "true"
    Project       = "${var.project_name}"
    Company       = "${var.company_name}"
    Account       = "${var.account}"
    Bucket-state  = "${var.company_name}-${var.account}-${var.aws_region}-tfdbstate"
  }
}

#Generamos el primero de los microservicios, en la subred privada 1
resource "aws_instance" "ec2_springboot2" {
  
  ami           = "ami-03c242f4af81b2365"
  instance_type = "t2.micro"
  #Para este test, creo las instancias en la pública, en vez de la subred privada, para no tener que generar un NAT Gateway, que tiene coste -:)
  #subnet_id = "${element(data.terraform_remote_state.vpc.private_subnets,1)}"
  subnet_id = "${element(data.terraform_remote_state.vpc.public_subnets,0)}"
  vpc_security_group_ids = ["${module.security_group_springboot.this_security_group_id}"]
  key_name = "${aws_key_pair.key_pair.key_name}"
  
  
  provisioner "file" {
    source      = "files-springboot/"
    destination = "/tmp"

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("${var.private_key}")}"
    }
  }


  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/springboot-docker.sh",
      "/tmp/springboot-docker.sh",

    ]

    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file("${var.private_key}")}"
    }
  }

 tags = {
    Name          = "${var.project_name}-${var.account}-springboot2"
    Terraform     = "true"
    Project       = "${var.project_name}"
    Company       = "${var.company_name}"
    Account       = "${var.account}"
    Bucket-state  = "${var.company_name}-${var.account}-${var.aws_region}-tfdbstate"
    
  }
}




