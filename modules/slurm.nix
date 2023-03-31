{ config, pkgs, lib, ... }:

let
  cfg = config.biome.slurm;
in {
  options.biome.slurm = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    server = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    client = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    name = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
    controlMachine = lib.mkOption {
      type = lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable rec {
    services.munge = {
      enable = true;
      password = "/etc/munge/munge.key";
    };
    users.users.munge.extraGroups = ["keys"];
    systemd.services.munged.serviceConfig.ExecStart = lib.mkForce "${pkgs.munge}/bin/munged --syslog -f --key-file ${services.munge.password}";
    sops.secrets."munge" = {
      format = "binary";
      sopsFile = ../secrets/munge.key;
      owner = "munge";
      path = "/etc/munge/munge.key";
    };


    services.slurm = {
      client.enable = cfg.client;
      server.enable = cfg.server;
      enableStools = !cfg.client && !cfg.server;
      nodeName = cfg.name;
      controlMachine = cfg.controlMachine;
      partitionName = [
        "standard Nodes=triwizard Default=YES MaxTime=INFINITE State=Up"
      ];
    };
  };
}
