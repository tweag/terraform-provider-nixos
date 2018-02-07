{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.roles.webnode;
in {
  options = {
    roles.webnode = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enable rec {
    services.nginx.enable = true;
    services.nginx.virtualHosts.default.root = ./webroot;
  };
}
