{ config, pkgs, lib, ... }:
let
  syncthinguser = if config.networking.hostName == "fiasco" then "nextcloud" else "lukas";
  syncthingdatadir = if config.networking.hostName == "fiasco" then "/home/nextcloud/data/" else "/home/${config.networking.hostName}";
in rec {
  services.syncthing =
    {
      enable = true;
      openDefaultPorts = true;
      user = syncthinguser;
      dataDir = "/home/${syncthinguser}/.sync";
      configDir = "/home/${syncthinguser}/.config/syncthing";
      guiAddress = "0.0.0.0:8384";
      declarative.devices = {
        jasnah.id = "SJOSL3J-I7SCE5D-5O6MARN-T5ZTE3U-B5IGX7A-IFUBSNJ-2DN3CVF-LNWB4AA";
        fiasco.id = "TZTESB5-PVIOPB6-YFRTLZW-LAVF3AV-55CYK2F-PG66NFT-AHT6VT6-LHH7CA2";
      };
      declarative.folders =
        let ifEnabledDevice = devices: lib.elem config.networking.hostName devices;
        in {
          current = rec {
            id = "current";
            devices = [ "fiasco" "jasnah" ];
            path = "${syncthingdatadir}/current";
            watch = false;
            rescanInterval = 7200;
            enable = ifEnabledDevice devices;
          };
          archive = rec {
            id = "archive";
            devices = [ "fiasco" "jasnah" ];
            path = "/${syncthinguser}/archive";
            watch = false;
            rescanInterval = 7200;
            enable = ifEnabledDevice devices;
          };
        };
      };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "${config.networking.hostName}.home" = {
        forceSSL = false;
        locations."/syncthing/" = {
          proxyPass = "http://localhost:8384/";
          extraConfig = "proxy_pass_header Authorization;";

        };
      };
    };
  };

  systemd.tmpfiles.rules = [
      # Make sure syncthing is able to read and enter every parent directory of
      # the torrents directory
      "d /home/${syncthinguser} 750 ${syncthinguser}"
      "d /home/${syncthinguser}/.sync 750 ${syncthinguser}"
      "d /home/${syncthinguser}/.config 750 ${syncthinguser}"
      "d /home/${syncthinguser}/.config/syncthing 750 ${syncthinguser}"
    ] ++ lib.lists.flatten (builtins.map (
      dir:
      [
        "d ${services.syncthing.declarative.folders.${dir}.path} 2770 ${syncthinguser}"
      ]
    )
      # TODO: Check whether additional folders should be added here for the
      # other transmission folders
      (builtins.attrNames services.syncthing.declarative.folders)
    );

}
