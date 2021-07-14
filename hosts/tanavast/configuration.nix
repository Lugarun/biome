{ config, pkgs, ... }:
{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../common
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/xvda";
  boot.initrd.checkJournalingFS = false;

  networking.hostName = "tanavast"; # Define your hostname.
  time.timeZone = "America/Toronto";

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = false;


  networking.interfaces.eth0.ipv4.addresses = [ {
    address = "104.152.208.10";
    prefixLength = 24;
  } ];
  networking.defaultGateway = "104.152.208.1";
  networking.nameservers = ["8.8.8.8"];

  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 51820 ];
  }; # Open wireguard port in the firewall

  system.stateVersion = "21.05";
}

