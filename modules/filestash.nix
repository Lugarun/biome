{ config, pkgs, lib, ... }:
let
  cfg = config.biome.filestash;
in {
  options.biome.restic = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable rec {
    users.users.lukas.extraGroups = [ "docker" ];
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.containers = {
      filestash = {
        image = "machines/filestash:latest";
        volumes = [
          "/var/lib/filestash:/app/data/state"
        ];
        environment = {
        };
        ports = [
          "8334:8334"
        ];
      };
    };
  };
}
