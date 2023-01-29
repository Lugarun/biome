{ config, pkgs, lib, ... }:

let
  cfg = config.biome.syncthing;
in {
  options.biome.syncthing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = /home/lukas;
      description = ''
        The dir that contains the syncthing config, data, and folders.
      '';
    };
  };

  config = lib.mkIf cfg.enable rec {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:8384";
      user = "lukas";
      dataDir = "/home/lukas";
      configDir = "/home/lukas/.config/syncthing";
      devices = {
        "jasnah" = {
          id = "PHJMFPO-KPWGSSE-SCFKV6D-EHLUGNK-4TOR2BU-XV2BTON-AHHEFE4-O5SKEQ2";
        };
        "triwizard" = {
          id = "7FJQ53I-3NQTO3C-D65GBXF-CZUZJS7-MRKUGB3-XS3MPYB-FMKLWIZ-R2PZFAG";
        };
      };
      folders = {
        "workspace" = {
          path = "/home/lukas/workspace";
          devices = [ "jasnah" "triwizard" ];
        };
      };
    };

    #networking.firewall.interfaces.wg0.allowedTCPPorts = [ 80 ];
    #    services.nginx = {
    #      enable = true;
    #
    #      recommendedGzipSettings = true;
    #      recommendedOptimisation = true;
    #      recommendedProxySettings = true;
    #      recommendedTlsSettings = true;
    #
    #      virtualHosts = {
    #        "${config.networking.hostName}" = {
    #          forceSSL = false;
    #          locations."/syncthing/" = {
    #            proxyPass = "http://0.0.0.0:8384/";
    #          };
    #        };
    #      };
    #    };
  };
}
