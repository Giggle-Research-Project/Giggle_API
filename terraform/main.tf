provider "aws" {
  region = "eu-north-1"
}

# Get all running instances with the specific tag
data "aws_instances" "existing" {
  filter {
    name   = "tag:Name"
    values = ["example-instance"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

# Output existing instance ID (if any)
output "existing_instance_id" {
  value = length(data.aws_instances.existing.ids) > 0 ? data.aws_instances.existing.ids[0] : "No instance found"
}

# Check if the key pair already exists
data "aws_key_pair" "existing" {
  key_name = "giggle-key-pair"
}

# Fetch the existing security group by name
data "aws_security_group" "existing_ssh" {
  name = "allow_ssh"
}

# Create the key pair only if it doesn't exist
resource "aws_key_pair" "example" {
  count      = data.aws_key_pair.existing.key_name == null ? 1 : 0
  key_name   = "giggle-key-pair"
  public_key = var.ssh_public_key
}

# Conditionally create the EC2 instance only if no running instance exists
resource "aws_instance" "example" {
  count         = length(data.aws_instances.existing.ids) == 0 ? 1 : 0
  ami           = "ami-0c2e61fdcb5495691"
  instance_type = "t3.medium"

  tags = {
    Name = "example-instance"
  }

  vpc_security_group_ids = [data.aws_security_group.existing_ssh.id]

  key_name = data.aws_key_pair.existing.key_name == null ? aws_key_pair.example[0].key_name : data.aws_key_pair.existing.key_name

   # Root volume configuration
  root_block_device {
    volume_size = 30 # Set volume size to 30GB
    volume_type = "gp3" # General-purpose SSD (optional)
  }
}

# Output the public IP of the EC2 instance (existing or new)
output "public_ip" {
  value = length(data.aws_instances.existing.ids) > 0 ? data.aws_instances.existing.public_ips[0] : aws_instance.example[0].public_ip
}

# Variable for the public key
variable "ssh_public_key" {
  type = string
}

# # Check if the inbound HTTP rule already exists
# locals {
#   http_rule_exists = contains(
#     [for rule in data.aws_security_group.existing_ssh.ingress : true if rule.from_port == 80 && rule.to_port == 80 && rule.protocol == "tcp"],
#     true
#   )
# }

# # Add the HTTP inbound rule only if it doesn't exist
# resource "aws_security_group_rule" "allow_http_inbound" {
#   count = local.http_rule_exists ? 0 : 1

#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"] # Allow HTTP access from any IP
#   security_group_id = data.aws_security_group.existing_ssh.id
# }