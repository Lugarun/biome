{ config, pkgs, lib, ... }:
{
  imports = [
    ./users
    ../modules/wireguard.nix
    ../modules/syncthing.nix
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    kakoune
    vim
    wget
    docker
    wireguard
    bashmount
  ];

  virtualisation.docker.enable = true ;

  nixpkgs.config.allowUnfree = true;
  nix.allowedUsers = [ "@wheel" ];

  # This is needed by wpgtk
  programs.dconf.enable = true;


  # biome config
  biome.syncthing.enable = true;
  biome.syncthing.folders = lib.importJSON ../config/syncthing.json;

  biome.wireguard.enable = true;
  biome.wireguard.networkInfo = lib.importJSON ../config/wireguard.json;

}
