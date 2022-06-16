{ config, pkgs, lib, ... }:

let
  cfg = config.biome.calendar;
in {
  options.biome.calendar = {
    enableServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = (lib.mkMerge [
    (lib.mkIf cfg.enableServer rec {
      services.xandikos = {
        enable = true;
        port = 5232;
        extraOptions = [ "--defaults" ];
        routePrefix = "/calendar/";
        nginx = {
          enable = true;
          hostName = config.networking.hostName;
        };
      };
    })
  ]);
}
