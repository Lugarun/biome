{
  network = {
    description = "Legacy Biome Secret Uploader";
  };
  "tanavast" = { config, pkgs, lib, ... }: {
      deployment = {
        targetUser = "root";
        targetHost = "100.73.30.58";
        secrets = {
          "matrix-telegram" = {
            source = "../secrets/matrix-registration-secret.nix";
            destination = "/etc/secrets/telegram.env";
            owner.user = "lukas";
            owner.group = "wheel";
          };
        };
      };
  };
  "triwizard" = { config, pkgs, lib, ... }: {
      deployment = {
        targetUser = "root";
        targetHost = "100.110.99.103";
        secrets = {
          "restic-password" = {
            source = "../secrets/restic/restic-password";
            destination = "/root/restic-keys/restic-password";
            owner.user = "root";
            owner.group = "root";
          };
          "miniflux-admin" = {
            source = "../secrets/miniflux-admin";
            destination = "/etc/secrets/miniflux";
            owner.user = "lukas";
            owner.group = "syncthing";
          };
          "restic-rclone-config" = {
            source = "../secrets/restic/uwonedrive-rclone-config";
            destination = "/root/restic-keys/uwonedrive-rclone-config";
            owner.user = "lukas";
            owner.group = "root";
          };
        };
      };
  };
  "jasnah" = { config, pkgs, lib, ... }: {
      deployment = {
        targetUser = "root";
        targetHost = "100.87.83.86";
        secrets = {
        };
      };
  };
  "beasty" = { config, pkgs, lib, ...}: {
      deployment = {
        targetUser = "root";
        targetHost = "100.67.175.75";
        secrets = {
        };
      };
  };
  "fiasco" = { config, pkgs, lib, ... }: {
      deployment = {
        targetUser = "root";
        targetHost = "100.98.155.47";
        secrets = {
          "restic-password" = {
            source = "../secrets/restic/restic-password";
            destination = "/root/restic-keys/restic-password";
            owner.user = "root";
            owner.group = "root";
          };
          "restic-rclone-config" = {
            source = "../secrets/restic/uwonedrive-rclone-config";
            destination = "/root/restic-keys/uwonedrive-rclone-config";
            owner.user = "lukas";
            owner.group = "root";
          };
        };
      };
  };
}
