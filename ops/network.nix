{
  network = {
    description = "Legacy Biome Secret Uploader";
  };
  "tanavast" = { config, pkgs, lib, ... }: {
      deployment = {
        targetUser = "root";
        targetHost = "100.73.30.58";
        secrets = {
        };
      };
  };
  "triwizard" = { config, pkgs, lib, ... }: {
      deployment = {
        targetUser = "root";
        targetHost = "100.110.99.103";
        secrets = {
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
