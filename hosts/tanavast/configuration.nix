{ config, pkgs, ... }:
{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../common
      ../../modules/calendar.nix
    ];

  biome.calendar = {
    enableServer = true;
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "lfschmidt.me@gmail.com";

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/xvda";
  boot.initrd.checkJournalingFS = false;

  networking.hostName = "tanavast"; # Define your hostname.
  networking.domain = "lutino.space";
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
    allowedTCPPorts = [ 53 80 443];
    allowedUDPPorts = [ 53 51820 ];
  }; # Open wireguard port in the firewall

  system.stateVersion = "21.05";
}

