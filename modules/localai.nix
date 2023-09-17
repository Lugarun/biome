{ config, pkgs, lib, ... }:
let
  cfg = config.biome.localai;
in {
  options.biome.localai = {
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
        image = "quay.io/go-skynet/local-ai:latest";
        volumes = [
          "/var/lib/localai:/models"
        ];
        environment = {
          "MODELS_PATH" = "/models";
        };
        ports = [
          "8000:8000"
        ];
        command = "/user/bin/local-ai";
      };
    };
  };
}
