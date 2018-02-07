# /network.nix
{
  defaults = {
    networking.firewall.enable = false;
    services.openssh.enable = true;

    imports = [ ./roles.nix ];
  };
} // (import ./terraform/network.nix)
