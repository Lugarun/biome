{ config, pkgs, lib, ... }:

let
  cfg = config.biome.rssReader;
in {
  options.biome.rssReader = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    baseURL = lib.mkOption {
      type = lib.types.string;
      default = "rss.lutino.space";
      description = ''
        The base url
      '';
    };
    port = lib.mkOption {
      type = lib.types.string;
      default = "5335";
      description = ''
        Internal port
      '';
    };
  };

  config = lib.mkIf cfg.enable rec {

    services.miniflux = {
      enable = true;
      adminCredentialsFile = "/etc/secrets/miniflux";
      config = {
        LISTEN_ADDR = cfg.port;
      };
    };

    # For backups, note that miniflux writes to a postgresql database
    services.postgresqlBackup = {
      enable = true;
    };

    # Nginx
    services.nginx.virtualHosts."${baseURL}" = {
          default = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://0.0.0.0:${cfg.port}/";
          };
        };
      };
    };
  };
}

