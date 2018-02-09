{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.terraform;

  isRole = role: builtins.elem role cfg.roles.enabled;
in {
  options = {
    terraform = {
      roles.enabled = mkOption {
        type = types.listOf types.string;
        default = [];
      };

      name = mkOption {
        type = types.string;
      };

      idx = mkOption {
        type = types.int;
      };
    };
  };

  config = mkIf (isRole "webnode") rec {
    services.nginx.enable = true;
    services.nginx.virtualHosts.default.root = ./webroot;
  };
}
