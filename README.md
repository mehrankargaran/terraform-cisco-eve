📘 Terraform Cisco Multi Config with Eve-NG

This project automates the configuration of multiple Cisco routers and switches inside an EVE-NG topology using Terraform and SSH connections.

🧠 What It Does

Reads device details from cisco_devices.json

Uses null_resource and local-exec to SSH into each device

Configures:

Hostname

Interfaces (IP or VLAN)

OSPF routing for routers

VLANs for switches

📁 Files
File	Description
cisco_devices.json	Device definitions (IP, username, password, type, etc.)
cisco-multi-config.tf	Terraform configuration logic
README.md	This documentation

⚙️ Usage
terraform init --upgrade
terraform plan
terraform apply
