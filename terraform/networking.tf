# ========================================
# NETWORKING PARA ALB
# ========================================
# El ALB necesita:
# - Una VPC (red privada virtual)
# - 2 subnets públicas en diferentes AZs (para alta disponibilidad)
# - Internet Gateway (para acceso público)
# - Security Groups (firewall)

# 1. VPC - Red privada virtual en AWS
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"  # Rango de IPs: 10.0.0.0 a 10.0.255.255
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# 2. Internet Gateway - Permite acceso a Internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 3. Subnet Pública 1 (Zona de Disponibilidad A)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"  # IPs: 10.0.1.0 a 10.0.1.255
  availability_zone       = "${var.aws_region}a"  # us-east-1a
  map_public_ip_on_launch = true  # Asigna IP pública automáticamente

  tags = {
    Name = "${var.project_name}-public-subnet-1"
  }
}

# 4. Subnet Pública 2 (Zona de Disponibilidad B)
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"  # IPs: 10.0.2.0 a 10.0.2.255
  availability_zone       = "${var.aws_region}b"  # us-east-1b
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-2"
  }
}

# 5. Route Table - Tabla de rutas para tráfico
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"  # Todo el tráfico de Internet
    gateway_id = aws_internet_gateway.main.id  # Va por el Internet Gateway
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# 6. Asociar Route Table con Subnet 1
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# 7. Asociar Route Table con Subnet 2
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# 8. Security Group para ALB - Firewall del Load Balancer
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group para Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # Regla de entrada: Permitir HTTP desde Internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Cualquier IP puede acceder
    description = "Allow HTTP from Internet"
  }

  # Regla de salida: Permitir todo el tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Todos los protocolos
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# 9. Outputs - Para usar en otros archivos
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID de la VPC creada"
}

output "public_subnet_ids" {
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  description = "IDs de las subnets públicas"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "ID del security group del ALB"
}
