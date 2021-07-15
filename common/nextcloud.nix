{ config, pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "nextcloud.home" = {
        forceSSL = false;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    smbclient
  ];

  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.home";
    https = false;
    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "02:00:00";
    package = pkgs.nextcloud21;
    
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      dbpassFile = "/var/nextcloud-db-pass";

      adminpassFile = "/var/nextcloud-admin-pass";
      adminuser = "admin";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
    ];
  };

  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };
}
