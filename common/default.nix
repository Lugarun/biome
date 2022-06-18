{ config, pkgs, lib, ... }:
{
  imports = [
    ./users
    ../modules/tailscale.nix
  ];

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    kakoune
    nethogs
    vim
    wget
    docker
    wireguard-tools
    bashmount
    nvtop
    git
    fasd
    htop
    bpytop
    arandr
    networkmanagerapplet
  ];

  virtualisation.docker.enable = true ;

  nixpkgs.config.allowUnfree = true;
  nix.allowedUsers = [ "@wheel" ];

  # This is needed by wpgtk
  programs.dconf.enable = true;


  # biome config
  # biome.syncthing.enable = true;
  # biome.syncthing.baseDir = lib.mkIf (config.networking.hostName == "fiasco") /home/syncthing/data;
  # biome.syncthing.folders = lib.importJSON ../config/syncthing.json;

  biome.tailscale.enable = true;

  # Nix garbage collection
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.gc.dates = "weekly";
}
