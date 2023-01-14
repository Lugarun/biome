{ config, pkgs, lib, ... }:

let
  cfg = config.biome.rssReader;
in {
  options.biome.rssReader = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    domain = lib.mkOption {
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
        PORT = cfg.port;
      };
    };

    # For backups, note that miniflux writes to a postgresql database
    services.postgresqlBackup = {
      enable = true;
    };

    # Nginx
    services.nginx.virtualHosts."${cfg.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${cfg.port}/";
      };
    };
  };
}
