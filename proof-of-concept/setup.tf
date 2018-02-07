variable "hcloud_token" {}
variable "nixops_root" {}
variable "ssh_public_key" {}

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
  name = "webnode"
  image = "debian-9"
  ssh_keys = [ "${hcloud_ssh_key.default.id}" ]
  server_type = "cx11"

  # Pretend this is:
  #
  # provisioner "nixos-kexec" {
  #   ip = "${hcloud_server.web.ipv4_address}"
  #   public_key = "${file("${var.ssh_public_key}")}"
  # }
  #
  # For more, read: ./provisioner-nixos-kexec/README
  provisioner "local-exec" {
    command = "./provisioner-nixos-kexec/convert-to-nixos.sh '${hcloud_server.web.ipv4_address}' '${var.ssh_public_key}'"
  }

  # This is the first half of the nixos-node resource,
  # for details please check out ./resource-nixos-node/README
  #
  # The second half is in stage-one.tf
  provisioner "local-exec" {
    command = "./resource-nixos-node/setup-nixops.sh  '${hcloud_server.web.name}' '${hcloud_server.web.ipv4_address}' '${var.nixops_root}'"
  }
}

# This is the second half of the nixos resource,
# for more, look at ./resource-nixos-node/README

data "local_file" "nixops_web_hardware_config_data" {
  filename = "./${var.nixops_root}/terraform/.cache/${hcloud_server.web.name}/hardware-configuration.nix"
}

resource "local_file" "nixops-web-hardware-configuration" {
  filename = "${path.module}/${var.nixops_root}/terraform/${hcloud_server.web.name}/hardware-configuration.nix"
  content = <<CONTENT
    ${data.local_file.nixops_web_hardware_config_data.content}
  CONTENT
}

resource "local_file" "nixops-web-default-nix" {
  filename = "${path.module}/${var.nixops_root}/terraform/${hcloud_server.web.name}/default.nix"
  content = <<CONTENT
    { imports = [ ./hardware-configuration.nix ./terraform.nix ];
      deployment.targetHost = "${hcloud_server.web.ipv4_address}";
    }
  CONTENT
}

resource "local_file" "nixops-web-terraform-nix" {
  filename = "${path.module}/${var.nixops_root}/terraform/${hcloud_server.web.name}/terraform.nix"
  content = <<CONTENT
    {
      roles.webnode.enable = true;
    }
  CONTENT
}
