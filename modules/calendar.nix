{ config, pkgs, lib, ... }:

let
  cfg = config.biome.calendar;
  cfgFile = pkgs.writeTextFile {
    name = "vdirsyncer.conf";
    text = ''
    [general]
    status_path = "~/.config/vdirsyncer"

    [pair cal_pair]
    a = "cal"
    b = "cal_remote"
    collections = ["from a", "from b"]

    [pair card_pair]
    a = "card"
    b = "card_remote"
    collections = ["from a", "from b"]

    [storage cal_remote]
    type = "caldav"
    url = "http://tanavast/radicale/"
    username = "..."
    password = "..."
    
    [storage card_remote]
    type = "carddav"
    url = "http://tanavast/radicale/"
    username = "..."
    password = "..."

    [storage cal]
    type = "filesystem"
    path = "~/.calendar"
    fileext = ".ics"

    [storage card]
    type = "filesystem"
    path = "~/.contacts"
    fileext = ".vcf"
    '';
  };
in {
  options.biome.calendar = {
    enableServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    enableClient = lib.mkOption {
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
      };
      services.nginx = {
        virtualHosts = {
          "${config.networking.hostName}" = {
            locations."/radicale/" = {
              proxyPass = "http://0.0.0.0:5232/";
              extraConfig = ''
                proxy_set_header Host $host;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Scheme $scheme;
                proxy_set_header X-Script-Name /radicale;
                proxy_http_version 1.1;
        
                client_max_body_size 0;    
              '';
            };
          };
        };
      };
    })
    (lib.mkIf cfg.enableClient rec {
      systemd.user.timers.vdirsyncer = {
        wantedBy = [ "timers.target" ];
        description = "Timer to synchronize calendars";
        timerConfig = {
          OnBootSec = "15min";
          OnUnitActiveSec = "30min";
        };
      };
      systemd.user.services.vdirsyncer = {
        wantedBy = [ "default.target" ];
        description = "Synchronize your calendars";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer -c ${cfgFile} sync";
          Restart = "on-failure";
          Type = "oneshot";
          RestartSec = 30;
        };
      };
    })
  ]);
}
