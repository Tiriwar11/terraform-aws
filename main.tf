############# VPC ##############
resource "aws_vpc" "VPC_LaboratorioITM_Terraform" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "VPC_LaboratorioITM_Terraform"
  }
}

############# Subnets #############

resource "aws_subnet" "SUBNET_LaboratorioITM_Public" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
  cidr_block = "${var.subnet_public_cidr}"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "SUBNET_LaboratorioITM_Public"
    "Env" = "LAB"
  }
  depends_on = [
    aws_vpc.VPC_LaboratorioITM_Terraform
  ]
}

resource "aws_subnet" "SUBNET_LaboratorioITM_Public2" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
  cidr_block = "${var.subnet_public2_cidr}"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "SUBNET_LaboratorioITM_Public2"
    "Env" = "LAB"
  }
  depends_on = [
    aws_vpc.VPC_LaboratorioITM_Terraform
  ]
}

resource "aws_subnet" "SUBNET_LaboratorioITM_Private" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
  cidr_block = "${var.subnet_private_cidr}"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "SUBNET_LaboratorioITM_Private"
    "Env" = "LAB"
  }
  depends_on = [
    aws_vpc.VPC_LaboratorioITM_Terraform
  ]
}

resource "aws_subnet" "SUBNET_LaboratorioITM_Private2" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
  cidr_block = "${var.subnet_private2_cidr}"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "SUBNET_LaboratorioITM_Private2"
    "Env" = "LAB"
  }
  depends_on = [
    aws_vpc.VPC_LaboratorioITM_Terraform
  ]
}

############# Public Subnet Network ACL #############

resource "aws_network_acl" "NACL_Public_Subnet_Terraform" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
  subnet_ids = [aws_subnet.SUBNET_LaboratorioITM_Public.id,aws_subnet.SUBNET_LaboratorioITM_Public2.id]

  egress {
    rule_no      = 100
    action       = "allow"
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_block   = "0.0.0.0/0"
  }

  ingress {
    rule_no      = 100
    action       = "allow"
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_block   =  "${var.vpc_cidr}" # IP local de la vpc
  }

    ingress {
    rule_no      = 200
    action       = "allow"
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_block   = "0.0.0.0/0"  # trafico http desde cualquier lugar en puerto 80
  }

  ingress {
    rule_no      = 300
    action       = "allow"
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_block  = "${var.public_ip}" # ip publica para tener acceso a la instancia EC2
  }

  ingress {
    rule_no      = 400
    action       = "allow"
    from_port    = 1025
    to_port      = 65535
    protocol     = "tcp"  # trafico TCP
    cidr_block   = "0.0.0.0/0"
  }

  tags = {
    Name = "NACL_Public_Subnet"
  }
}

############# Private Subnet Network ACL #############
resource "aws_network_acl" "NACL_Private_Subnet_Terraform" {
  vpc_id     = aws_vpc.VPC_LaboratorioITM_Terraform.id
  subnet_ids = [aws_subnet.SUBNET_LaboratorioITM_Private.id,aws_subnet.SUBNET_LaboratorioITM_Private2.id]

  egress {
    rule_no      = 100
    action      = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
  }

  ingress {
    rule_no      = 100
    action      = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "${var.vpc_cidr}" # IP local de la vpc
  }

  ingress {
    rule_no      = 200
    action      = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "${var.public_ip}" # ip publica para tener acceso a la RDS
  }

  tags = {
    Name = "NACL_Private_Subnet"
  }
}





############# Webserver Security Group #############

resource "aws_security_group" "SG_WebServer_Terraform" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id

    ingress {
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_blocks   = ["0.0.0.0/0"]
  }

    ingress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["${var.public_ip}"]
  }

ingress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks   =  ["${var.vpc_cidr}"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG_Webserver_Terraform"
  }
}

############# RDS Security Group #############

resource "aws_security_group" "SG_RDS_Terraform" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id

    ingress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["${var.public_ip}"]
  }

ingress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks   =  ["${var.vpc_cidr}"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG_RDS_Terraform"
  }
}


############# Internet Gateway #############

resource "aws_internet_gateway" "IG_ITMLab_Terraform" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id

    tags = {
    Name = "IG_ITMLab_Terraform"
  }
}

############# Route Table #############
resource "aws_route_table" "RT_ITMIaC_VSCode" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG_ITMLab_Terraform.id
  }
 depends_on = [aws_internet_gateway.IG_ITMLab_Terraform]

     tags = {
    Name = "RT_ITMLab_Terraform"
  }
}

resource "aws_main_route_table_association" "RT_Asociation" {
  route_table_id = aws_route_table.RT_ITMIaC_VSCode.id
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
}


############# RDS Subnet Group #############

resource "aws_db_subnet_group" "SNG_TerraformDB" {
  name       = var.rds_db_subnet_group_name
  subnet_ids = [
    aws_subnet.SUBNET_LaboratorioITM_Private.id, aws_subnet.SUBNET_LaboratorioITM_Private2.id
  ]
    tags = {
    Name = "TerraformDBSubnetGroup"
  }
}


############# RDS MySQL #############

resource "aws_db_instance" "RDS_TerraformDB" {
  identifier           = "${var.rds_identifier}"
  allocated_storage    = "${var.rds_allocated_storage}"
  engine               = "${var.rds_engine}"
  engine_version       = "${var.rds_engine_version}"
  instance_class       = "${var.rds_instance_class}"
  username             = "${var.rds_username}"
  password             = "${var.rds_password}"
  db_subnet_group_name = aws_db_subnet_group.SNG_TerraformDB.name
  vpc_security_group_ids = [aws_security_group.SG_RDS_Terraform.id]
  multi_az             = "${var.rds_multi_az}"
  publicly_accessible  = "${var.rds_publicly_accessible}"
  skip_final_snapshot  = true
}


############# EC2 Joomla Instance #############

resource "aws_instance" "EC2_Terraform_Lab_1_VSCode" {
  ami = "${var.ec2_terraform_ami}"
  instance_type = "${var.ec2_joomla_instance_type}"
  count = "${var.ec2_terraform_instance_quantity}"
  subnet_id = aws_subnet.SUBNET_LaboratorioITM_Public.id
  key_name = "${var.aws_keypair}"
  security_groups = [aws_security_group.SG_WebServer_Terraform.id]
  tags = {
    Name = "${var.ec2_terraform_instance_name}"
  }
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
amazon-linux-extras enable php8.1
yum clean metadata
yum install -y php php-common php-pear
yum install -y php-{cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip}
mkdir /var/www/html/myapp
cd /var/www/html/myapp
   echo ' <!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solicitud de Préstamo Bancario</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }

        header {
            background-color: #007BFF;
            color: #fff;
            text-align: center;
            padding: 1em 0;
        }

        form {
            max-width: 600px;
            margin: 2em auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
        }

        input, select {
            width: 100%;
            padding: 10px;
            margin-bottom: 16px;
            box-sizing: border-box;
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        textarea {
            width: 100%;
            padding: 10px;
            margin-bottom: 16px;
            box-sizing: border-box;
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        button {
            background-color: #28A745;
            color: #fff;
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }

        button:hover {
            background-color: #218838;
        }
    </style>
</head>
<body>

    <header>
        <h1>Solicitud de Préstamo Bancario</h1>
    </header>

    <form>
        <label for="nombre">Nombre completo:</label>
        <input type="text" id="nombre" name="nombre" required>

        <label for="dni">DNI/NIF:</label>
        <input type="text" id="dni" name="dni" required>

        <label for="telefono">Teléfono:</label>
        <input type="tel" id="telefono" name="telefono" required>

        <label for="email">Correo electrónico:</label>
        <input type="email" id="email" name="email" required>

        <label for="monto">Monto solicitado:</label>
        <input type="number" id="monto" name="monto" required>

        <label for="plazo">Plazo de devolución (en meses):</label>
        <input type="number" id="plazo" name="plazo" required>

        <label for="ingresos">Ingresos mensuales:</label>
        <input type="number" id="ingresos" name="ingresos" required>

        <label for="proposito">Propósito del préstamo:</label>
        <select id="proposito" name="proposito">
            <option value="vivienda">Compra de vivienda</option>
            <option value="educacion">Educación</option>
            <option value="negocio">Inicio de negocio</option>
            <option value="otros">Otros</option>
        </select>

        <label for="comentarios">Comentarios adicionales:</label>
        <textarea id="comentarios" name="comentarios" rows="4"></textarea>

        <button type="submit">Enviar Solicitud</button>
    </form>

</body>
</html>
' > /var/www/html/myapp/index.html
chown -R apache:apache /var/www/html/myapp
chmod -R 755 /var/www/html/myapp
chmod -R 777 /var/www/
systemctl restart httpd
EOF
}
