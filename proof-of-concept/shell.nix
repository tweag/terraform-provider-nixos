{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation rec {
  name = "test";

  buildInputs = with pkgs; [
    terraform_0_11
    nixops
  ];

  terraformPlugins = pkgs.runCommand "terraform-plugins" {
    plugins = [
      (pkgs.fetchzip {
        url = "https://github.com/hetznercloud/terraform-provider-hcloud/releases/download/v1.0.0/terraform-provider-hcloud_v1.0.0_linux_386.zip";
        stripRoot = false;
        sha256 = "0g7r52v56fdkfwzlxfhi00hjrxkpdgriccr7g1y5j4r7pyx1svkr";
      })
      (pkgs.fetchzip {
        url = "https://github.com/terraform-providers/terraform-provider-local/archive/v1.1.0.zip";
        stripRoot = false;
        sha256 = "0fb27lq95fa4ss6c325bx58m77773ff5hvb316qpgwliig1ng0wb";
      })
    ];
  } ''
    mkdir -p $out
    for p in $plugins; do
      ln -s $p/terraform-provider-* $out/
    done
  '';

  shellHook = ''
    rm -rf ./.fake-home
    mkdir ./.fake-home
    (
      cd ./.fake-home
      mkdir ./.ssh
      cp ~/.ssh/id_rsa.pub ./.ssh/
      mkdir ./.terraform.d/
      ln -s $terraformPlugins ./.terraform.d/plugins
    )
    export HOME=$(pwd)/.fake-home

    cat README
  '';
}
