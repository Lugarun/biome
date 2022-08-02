{ config, pkgs, ... }:
{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../common
      ../../modules/calendar.nix
      ../../modules/matrix.nix
    ];

  biome.calendar = {
    enableServer = true;
  };
  biome.matrix = {
    enable = true;
    address = "lutino.space";
  };

  virtualisation.oci-containers.containers = {
    pihole = {
      image = "pihole/pihole:latest";
      environment = {
        TZ = "America/Toronto";
        ServerIP = "100.73.30.58";
        VIRTUAL_HOST = "pihole.biome";
      };
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--dns=127.0.0.1"
        "--dns=1.1.1.1"
      ];
      workdir = "/var/lib/pihole/";
      ports = [
        "100.73.30.58:53:53/tcp"
        "100.73.30.58:53:53/udp"
        "30443:443"
        "3080:80"
      ];
      volumes = [
        "/var/lib/etc-pihole:/etc/pihole"
        "/var/lib/etc-dnsmasq.d:/etc/dnsmasq.d"
      ];
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "pihole.biome" = {
        default = true;
        forceSSL = false;
        locations."/" = {
          proxyPass = "http://0.0.0.0:3080/";
        };
      };
    };
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

