# terraform/vpc.tf

# --- Red Privada Virtual (VPC) ---
# Define el "vecindario" principal
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16" # Rango de direcciones IP privadas para nuestra red
  enable_dns_support   = true          # Permite que los recursos usen nombres DNS dentro de la VPC
  enable_dns_hostnames = true          # Permite asignar nombres DNS públicos si es necesario

  tags = {
    # Etiqueta para identificar fácilmente este recurso en la consola de AWS
    Name = "${var.project_name}-vpc" 
  }
}

# --- Subredes Públicas ---
# Zonas dentro del vecindario con acceso a internet.
# Creamos dos en diferentes Zonas de Disponibilidad (AZ) para alta disponibilidad.
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main_vpc.id # Pertenece a nuestra VPC
  cidr_block              = "10.0.1.0/24"       # Rango de IPs para esta subred
  availability_zone       = "${var.aws_region}a" # Ej: us-east-1a
  map_public_ip_on_launch = true                # Asigna IP pública automáticamente (necesario para IGW)

  tags = {
    Name = "${var.project_name}-public-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b" # Ej: us-east-1b
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-b"
  }
}

# --- Puerta de Internet (IGW) ---
# Permite la comunicación entre la VPC e internet.
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# --- Tabla de Rutas ---
# Define cómo el tráfico sale de las subredes públicas.
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  # Regla: Cualquier tráfico destinado fuera de la VPC (0.0.0.0/0)...
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id # ...debe ir a través de la Puerta de Internet.
  }

  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}

# --- Asociaciones de Rutas ---
# Conecta la tabla de rutas a nuestras subredes públicas.
resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# --- Grupo de Seguridad (Firewall) ---
# Controla el tráfico entrante y saliente para los recursos asociados (ej. Lambda).
resource "aws_security_group" "main_sg" {
  name        = "${var.project_name}-main-sg"
  description = "Permite tráfico HTTP/HTTPS y todo el tráfico saliente"
  vpc_id      = aws_vpc.main_vpc.id

  # Reglas de Entrada (Ingress): Quién puede contactar nuestros recursos
  ingress {
    description = "Permitir HTTP desde cualquier lugar"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite acceso desde cualquier IP (para API Gateway)
  }
   ingress {
    description = "Permitir HTTPS desde cualquier lugar"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite acceso desde cualquier IP (para API Gateway)
  }
  # Nota: Podríamos restringir más, pero para API Gateway + Lambda esto es común.
  # La Lambda no estará directamente expuesta.

  # Reglas de Salida (Egress): A dónde pueden conectarse nuestros recursos
  egress {
    description = "Permitir toda la salida"
    from_port   = 0           # Cualquier puerto
    to_port     = 0           # Cualquier puerto
    protocol    = "-1"        # Cualquier protocolo
    cidr_blocks = ["0.0.0.0/0"] # A cualquier destino (necesario para conectar a Supabase, internet, etc.)
  }

  tags = {
    Name = "${var.project_name}-main-sg"
  }
}