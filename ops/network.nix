{
  network = {
    description = "Personal wireguard network";
  };

  "tanavast" = { config, pkgs, lib, ... }: {
      imports = [ ../hosts/tanavast/configuration.nix ];
      deployment = {
        targetUser = "root";
        # targetHost = "104.152.208.10";
        targetHost = "10.100.0.1";
        secrets = {
          "wireguard-key" = {
            source = "../secrets/wireguard/tanavast.pri";
            destination = "/root/wireguard-keys/private";
            owner.user = "root";
            owner.group = "root";
          };
        };
      };
  };
  "jasnah" = { config, pkgs, lib, ... }: {
      imports = [ ../hosts/jasnah/configuration.nix ];
      deployment = {
        targetUser = "root";
        # targetHost = "127.0.0.1";
        targetHost = "10.100.0.2";
        secrets = {
          "wireguard-key" = {
            source = "../secrets/wireguard/jasnah.pri";
            destination = "/root/wireguard-keys/private";
            owner.user = "root";
            owner.group = "root";
          };
        };
      };
  };
  "fiasco" = { config, pkgs, lib, ... }: {
      imports = [ ../hosts/fiasco/configuration.nix ];
      deployment = {
        targetUser = "root";
        # targetHost = "192.168.0.10";
        targetHost = "10.100.0.4";
        secrets = {
          "wireguard-key" = {
            source = "../secrets/wireguard/fiasco.pri";
            destination = "/root/wireguard-keys/private";
            owner.user = "root";
            owner.group = "root";
          };
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
