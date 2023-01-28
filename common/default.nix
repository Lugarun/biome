{ config, pkgs, lib, ... }:
{
  imports = [
    ./users
    ../modules/tailscale.nix
  ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };

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
  nix.settings.allowed-users = [ "@wheel" ];

  # Tailscale
  biome.tailscale.enable = true;

  # Nix garbage collection
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.gc.dates = "weekly";
}
