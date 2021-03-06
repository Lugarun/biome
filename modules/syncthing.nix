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
          triwizard = "TZTESB5-PVIOPB6-YFRTLZW-LAVF3AV-55CYK2F-PG66NFT-AHT6VT6-0000000";
        };
        archive = {
          jasnah = "SJOSL3J-I7SCE5D-5O6MARN-T5ZTE3U-B5IGX7A-IFUBSNJ-2DN3CVF-LNWB4AA";
          fiasco = "TZTESB5-PVIOPB6-YFRTLZW-LAVF3AV-55CYK2F-PG66NFT-AHT6VT6-LHH7CA2";
          triwizard = "TZTESB5-PVIOPB6-YFRTLZW-LAVF3AV-55CYK2F-PG66NFT-AHT6VT6-0000000";
        };
      };
    };
  };

  config = let
    hasAFolder = lib.elem config.networking.hostName (lib.flatten (lib.forEach (lib.attrValues cfg.folders) lib.attrNames));
  in
    lib.mkIf (cfg.enable && hasAFolder) rec {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:8384";
      user = "lukas";
      devices = lib.mapAttrs (name: value: {id = value;}) (lib.fold lib.recursiveUpdate { } (lib.attrValues cfg.folders));
      folders =
        let
          ifEnabledDevice = devices: lib.elem config.networking.hostName devices;
          createFolderConfig = folder: devices: lib.nameValuePair (builtins.toString (cfg.baseDir + "/${folder}")) {
            id = folder;
            devices = builtins.attrNames devices;
            path = builtins.toString (cfg.baseDir + "/${folder}");
            watch = false;
            rescanInterval = 7200;
            enable = ifEnabledDevice (builtins.attrNames devices);
          };
        in lib.mapAttrs' createFolderConfig cfg.folders;
    };

    systemd.tmpfiles.rules = lib.lists.flatten (builtins.map (
      dir:
      [
        "d ${dir} 2770 lukas syncthing"
        "a ${dir}/ - - - - group:syncthing:rwx,other::-"
        "a ${dir}/ - - - - default:group:syncthing:rwx,default:other::-"
      ]) ( ["/var/lib/syncthing"] ++ (builtins.attrNames services.syncthing.folders)));



    networking.firewall.interfaces.wg0.allowedTCPPorts = [ 80 ];
    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        "${config.networking.hostName}" = {
          forceSSL = false;
          locations."/syncthing/" = {
            proxyPass = "http://0.0.0.0:8384/";
          };
        };
      };
    };
  };
}
