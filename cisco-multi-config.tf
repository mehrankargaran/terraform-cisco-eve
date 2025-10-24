terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Reading devices information from json file
locals {
  devices    = jsondecode(file("${path.module}/cisco_devices.json"))["devices"]
  interfaces = ["ethernet0/1", "ethernet0/2", "ethernet0/3"] # اینترفیس‌هایی که باید پیکربندی شوند
}

resource "null_resource" "configure_cisco_devices" {
  count = length(local.devices)

  provisioner "local-exec" {
    command = <<EOT
sshpass -p "${local.devices[count.index]["password"]}" ssh -tt \
  -o StrictHostKeyChecking=no \
  -o KexAlgorithms=+diffie-hellman-group1-sha1,diffie-hellman-group14-sha1 \
  -o HostKeyAlgorithms=+ssh-rsa \
  ${local.devices[count.index]["username"]}@${local.devices[count.index]["ip"]} << EOF
enable
${local.devices[count.index]["enable_password"]}
configure terminal
hostname ${local.devices[count.index]["name"]}

%{if local.devices[count.index]["type"] == "router"}
%{for iface in local.interfaces}
interface ${iface}
ip address 10.${count.index + 1}.${index(local.interfaces, iface) + 1}.1 255.255.255.0
no shutdown
exit
%{endfor}
router ospf 1
network 10.${count.index + 1}.0.0 0.0.0.255 area 0
exit
%{else}
%{for iface in local.interfaces}
interface ${iface}
switchport mode access
switchport access vlan 10
no shutdown
exit
%{endfor}
vlan 10
name Management
exit
%{endif}

do write memory
EOF
EOT
  }
}
