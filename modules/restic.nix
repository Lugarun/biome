{ config, pkgs, lib, ... }:

let
  cfg = config.biome.restic;
in {
  options.biome.restic = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    backupDirs = lib.mkOption {
      type = lib.types.listOf lib.types.string;
      default = [ "/mnt/storage/" ];
      description = ''
        The dirs that gets backed up.
      '';
    };
  };

  config = lib.mkIf cfg.enable rec {
    services.restic.backups = {
      uwonedrive = {
        user = "root";
        repository = "rclone:uwonedrive:backups";
        initialize = true;
        paths = cfg.backupDirs;
        timerConfig = {
          OnCalendar = "Mon,Wed,Fri 22:00";
          RandomizeDelaySec = "20m";
        };

        passwordFile = "/root/restic-keys/restic-password";
        rcloneConfigFile = "/root/restic-keys/uwonedrive-rclone-config";
      };
    };
  };
}
