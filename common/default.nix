{ config, pkgs, lib, ... }:
let
  wireguardConfig = pkgs.callPackage ./wireguard.nix { inherit config pkgs lib; };
in
{
  imports = [
    ./users
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
  ];

  virtualisation.docker.enable = true ;

  nixpkgs.config.allowunfree = true;
  nix.allowedUsers = [ "@wheel" ];
  networking.wireguard.interfaces.tst = wireguardConfig.createInterface config.networking.hostName;

  # This is needed by wpgtk
  programs.dconf.enable = true;

}
