{
  network = {
    description = "Personal wireguard network";
  };

  "tanavast" = { config, pkgs, lib, ... }: {
      imports = [ ../hosts/tanavast/configuration.nix ];
      deployment = {
        targetUser = "root";
        targetHost = "104.152.208.10";
        # targetHost = "10.100.0.1";
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
        targetHost = "127.0.0.1";
        # targetHost = "10.100.0.2";
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
        targetHost = "192.168.0.26";
        # targetHost = "10.100.0.4";
        secrets = {
          "wireguard-key" = {
            source = "../secrets/wireguard/fiasco.pri";
            destination = "/root/wireguard-keys/private";
            owner.user = "root";
            owner.group = "root";
          };
          "nextcloud-db-pass-key" = {
            source = "../secrets/nextcloud/nextcloud-db-pass";
            destination = "/var/nextcloud-db-pass";
            owner.user = "nextcloud";
            owner.group = "nextcloud";
            permissions = "770";
          };
          "nextcloud-admin-pass-key" = {
            source = "../secrets/nextcloud/nextcloud-admin-pass";
            destination = "/var/nextcloud-admin-pass";
            owner.user = "nextcloud";
            owner.group = "nextcloud";
            permissions = "770";
          };
        };
      };
  };
}
