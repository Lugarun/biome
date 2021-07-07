{
  network = {
    description = "Personal wireguard network";
  };

  "tanavast" = { config, pkgs, lib, ... }: {
      imports = [ ../../hosts/tanavast/configuration.nix ];
      deployment.targetUser = "root";
      deployment.targetHost = "10.100.0.1";
  };
  "jasnah" = { config, pkgs, lib, ... }: {
      imports = [ ../../hosts/jasnah/configuration.nix ];
      deployment.targetUser = "root";
      deployment.targetHost = "10.100.0.2";
  };
}
