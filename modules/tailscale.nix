{ lib, pkgs, config, ... }:

let
  cfg = config.biome.tailscale;
in {
  options.biome.tailscale = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.tailscale ];
    services.tailscale.enable = true;
    networking.firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
