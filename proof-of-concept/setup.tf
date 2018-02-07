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
  # }
  #
  # For more, read: ./provisioner-nixos-kexec/README
  provisioner "local-exec" {
    command = "./convert-to-nixos.sh ${hcloud_server.web.ipv4_address}"
  }

  # This is the first half of the nixos-node resource,
  # for details please check out ./resource-nixos-node/README
  #
  # The second half is in stage-one.tf
  provisioner "local-exec" {
    command = "./setup-nixops.sh  '${hcloud_server.web.name}' '${hcloud_server.web.ipv4_address}' '${var.nixops_root}'"
  }
}
