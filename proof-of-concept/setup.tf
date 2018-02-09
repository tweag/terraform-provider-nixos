variable "hcloud_token" {}
variable "nixops_root" {}
variable "ssh_public_key" {}
variable "webnode_instances" { default = 5 }
variable "webnode_config" {
  type = "list"
  default = ["webnode"]
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = "${var.hcloud_token}"
}

resource "hcloud_ssh_key" "default" {
  name = "My Example SSH Key"
  public_key = "${file("${var.ssh_public_key}")}"
}

# Create a web server
resource "hcloud_server" "web" {
  name = "webnode-${count.index}"
  image = "debian-9"
  ssh_keys = [ "${hcloud_ssh_key.default.id}" ]
  server_type = "cx11"
  count = "${var.webnode_instances}"

  # Pretend this is:
  #
  # provisioner "nixos-kexec" {
  #   ip = "${hcloud_server.web.*.ipv4_address[count.index]}"
  #   public_key = "${file("${var.ssh_public_key}")}"
  #   count = 5
  # }
  #
  # For more, read: ./provisioner-nixos-kexec/README
  provisioner "local-exec" {
   command = "./provisioner-nixos-kexec/convert-to-nixos.sh '${self.ipv4_address}' '${var.ssh_public_key}'"
  }

  # This is the first half of the nixos-node resource,
  # for details please check out ./resource-nixos-node/README
  #
  # The second half is in stage-one.tf
  provisioner "local-exec" {
    command = "./resource-nixos-node/setup-nixops.sh  '${self.name}' '${self.ipv4_address}' '${var.nixops_root}'"
  }
}

# This is the second half of the nixos resource,
# for more, look at ./resource-nixos-node/README

data "local_file" "nixops_web_hardware_config_data" {
  count = "${var.webnode_instances}"
  filename = "./${var.nixops_root}/terraform/.cache/${hcloud_server.web.*.name[count.index]}/hardware-configuration.nix"
}

resource "local_file" "nixops-web-hardware-configuration" {
  count = "${var.webnode_instances}"
  filename = "${path.module}/${var.nixops_root}/terraform/${hcloud_server.web.*.name[count.index]}/hardware-configuration.nix"
  content = <<CONTENT
    ${data.local_file.nixops_web_hardware_config_data.*.content[count.index]}
  CONTENT
}



resource "local_file" "nixops-web-default-nix" {
  count = "${var.webnode_instances}"
  filename = "${path.module}/${var.nixops_root}/terraform/${hcloud_server.web.*.name[count.index]}/default.nix"
  content = <<CONTENT
    { imports = [ ./hardware-configuration.nix ./terraform.nix ];
      deployment.targetHost = "${hcloud_server.web.*.ipv4_address[count.index]}";
    }
  CONTENT
}

resource "local_file" "nixops-web-terraform-nix" {
  count = "${var.webnode_instances}"
  filename = "${path.module}/${var.nixops_root}/terraform/${hcloud_server.web.*.name[count.index]}/terraform.nix"
  content = <<NIX
    { terraform.roles.enabled = ${jsonencode(var.webnode_config)};
      terraform.name = "${hcloud_server.web.*.name[count.index]}";
      terraform.idx = ${count.index};
    }
  NIX
}
