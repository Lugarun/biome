{
  network = {
    description = "Personal wireguard network";
  };

  "tanavast" = { config, pkgs, lib, ... }: {
      imports = [ ../../hosts/tanavast/configuration.nix ];
      deployment = {
        targetUser = "root";
        targetHost = "10.100.0.1";
        secrets = {
          source = "../../secrets/wireguard/tanavast";
          destination = "/root/wireguard-keys/private";
          owner.user = "root";
          owner.group = "root";
        };
      };
  };
  "jasnah" = { config, pkgs, lib, ... }: {
      imports = [ ../../hosts/jasnah/configuration.nix ];
      deployment = {
        targetUser = "root";
        targetHost = "10.100.0.2";
        secrets = {
          source = "../../secrets/wireguard/jasnah";
          destination = "/root/wireguard-keys/private";
          owner.user = "root";
          owner.group = "root";
        };
      };
  };
}
