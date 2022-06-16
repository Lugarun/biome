{ config, pkgs, lib, ... }:

let
  cfg = config.biome.photoprism;
in {
  options.biome.photoprism = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = /home/lukas/archive/pictures;
      description = ''
        The dir that contains the syncthing config, data, and folders.
      '';
    };
  };

  config = lib.mkIf cfg.enable rec {
    #sops.secrets."services/photoprism/password" = {
    #  owner = "photoprism";
    #  #keyFiles: PHOTOPRISM_ADMIN_PASSWORD=<yourpassword>
    #  path = "/var/lib/photoprism/keyFile";
    #};

    users.users.photoprism.extraGroups = [ "syncthing" "users" ];
    services.photoprism = {
      enable = true;
      originalsDir = "/home/lukas/pictures";
      group = "users";
      openFirewall = true;
      host = "0.0.0.0";
      
      #mysql = true;
      # sops support
      #keyFile = true;
      #port = 9999;
      #host = "127.0.0.1";
      #adminPasswordFile = "/home/lukas/archive/pictures/photoprismpwd.txt";
    };
  };
}
