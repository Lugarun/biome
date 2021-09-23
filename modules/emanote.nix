{ config, pkgs, lib, ... }:

let
  cfg = config.biome.emanote;
  emanote = import (fetchTarball "https://github.com/srid/emanote/archive/refs/heads/master.tar.gz");
in {
  options.biome.emanote = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    noteDir = lib.mkOption {
      type = lib.types.string;
      default = "/home/lukas/projects/zettelkasten";
      description = ''
        The root dir of the emanote notes.
      '';
    };
  };

  config =  lib.mkIf cfg.enable rec {
    systemd.services.emanoteSession = {
      wantedBy = [ "multi-user.target" ];
      description = "Start the emanote server.";
      serviceConfig = {
        User = "lukas";
        ExecStart = "${emanote.outputs.defaultPackage.x86_64-linux}/bin/emanote --layers ${cfg.noteDir}";
      };
    };
  };
}
