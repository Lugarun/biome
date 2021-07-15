{ config, pkgs, lib, ... }:

let
  cfg = config.biome.syncthing;
in {
  options.biome.syncthing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    baseDir = lib.mkOption {
      type = lib.types.path;
      default = /home/lukas;
      description = ''
        The dir that contains the syncthing config, data, and folders.
      '';
    };

    folders = lib.mkOption {
      type = lib.types.attrs;
      default = {
        projects = {
          jasnah = "SJOSL3J-I7SCE5D-5O6MARN-T5ZTE3U-B5IGX7A-IFUBSNJ-2DN3CVF-LNWB4AA";
          fiasco = "TZTESB5-PVIOPB6-YFRTLZW-LAVF3AV-55CYK2F-PG66NFT-AHT6VT6-LHH7CA2";
        };
        archive = {
          jasnah = "SJOSL3J-I7SCE5D-5O6MARN-T5ZTE3U-B5IGX7A-IFUBSNJ-2DN3CVF-LNWB4AA";
          fiasco = "TZTESB5-PVIOPB6-YFRTLZW-LAVF3AV-55CYK2F-PG66NFT-AHT6VT6-LHH7CA2";
        };
      };
    };
  };

  config = let
    hasAFolder = lib.elem config.networking.hostName (lib.flatten (lib.forEach (lib.attrValues cfg.folders) lib.attrNames));
  in
    lib.mkIf (cfg.enable && hasAFolder) {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "lukas";
      group = "wheel";
      dataDir = cfg.baseDir + /.sync;
      configDir = cfg.baseDir + /.config/syncthing;
      guiAddress = "0.0.0.0:8384";
      declarative.devices = lib.mapAttrs (name: value: {id = value;}) (lib.fold lib.recursiveUpdate { } (lib.attrValues cfg.folders));
      declarative.folders =
        let
          ifEnabledDevice = devices: lib.elem config.networking.hostName devices;
          createFolderConfig = folder: devices: {
            id = folder;
            devices = builtins.attrNames devices;
            path = builtins.toString (cfg.baseDir + "/${folder}");
            watch = false;
            rescanInterval = 7200;
            enable = ifEnabledDevice (builtins.attrNames devices);
          };
        in lib.mapAttrs createFolderConfig cfg.folders;
    };

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        "${config.networking.hostName}.biome" = {
          forceSSL = false;
          locations."/syncthing/" = {
            proxyPass = "http://localhost:8384/";
            extraConfig = "proxy_pass_header Authorization;";
          };
        };
      };
    };
  };
}
