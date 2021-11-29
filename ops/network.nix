{
  network = {
    description = "Legacy Biome Secret Uploader";
  };
  "tanavast" = { config, pkgs, lib, ... }: {
      deployment = {
        targetUser = "root";
        targetHost = "104.152.208.10";
        # targetHost = "10.100.0.1";
        secrets = {
        };
      };
  };
  "jasnah" = { config, pkgs, lib, ... }: {
      deployment = {
        targetUser = "root";
        targetHost = "127.0.0.1";
        # targetHost = "10.100.0.2";
        secrets = {
        };
      };
  };
  "fiasco" = { config, pkgs, lib, ... }: {
      deployment = {
        targetUser = "root";
        targetHost = "192.168.0.16";
        #  targetHost = "10.100.0.4";
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
