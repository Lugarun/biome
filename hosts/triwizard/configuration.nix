{ config, pkgs, lib,  ... }:
{

  imports =
    [ 
      ./hardware-configuration.nix
      ../../common
      ../../modules/restic.nix
      ../../modules/syncthing.nix
    ];

  # Windows via virt-manager
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  # biome.syncthing = {
  #   enable = true;
  #   baseDir = /home/lukas;
  #   folders = lib.importJSON ../../config/syncthing.json;
  # };
  # biome config
  # biome.syncthing.enable = true;
  # biome.syncthing.baseDir = lib.mkIf (config.networking.hostName == "fiasco") /home/syncthing/data;
  # biome.syncthing.folders = lib.importJSON ../config/syncthing.json;

  # biome.restic = {
  #   enable = true;
  #   backupDirs = ["/mnt/storage" "/home/lukas/workspace" "/home/lukas/phone"];
  # };



  # users.users.lukas.extraGroups = [ "docker" ];
  # virtualisation.docker.enable = true;
  # virtualisation.oci-containers.containers = {
  #   filestash = {
  #     image = "machines/filestash:latest";
  #     volumes = [
  #       "/var/lib/filestash:/app/data/state"
  #     ];
  #     environment = {
  #     };
  #     ports = [
  #       "8334:8334"
  #     ];
  #   };
  # };
  # services.nginx = {
  #   enable = true;
  #   recommendedGzipSettings = true;
  #   recommendedOptimisation = true;
  #   recommendedProxySettings = true;
  #   recommendedTlsSettings = true;
  #   virtualHosts = {
  #     "pihole.biome" = {
  #       default = true;
  #       forceSSL = false;
  #       locations."/" = {
  #         proxyPass = "http://0.0.0.0:3080/";
  #       };
  #     };
  #     "files.biome" = {
  #       forceSSL = false;
  #       locations."/" = {
  #         proxyPass = "http://0.0.0.0:8334/";
  #       };
  #     };
  #     "rss.biome" = {
  #       forceSSL = false;
  #       locations."/" = {
  #         proxyPass = "http://0.0.0.0:8080/";
  #       };
  #     };
  #     "photos.biome" = {
  #       forceSSL = false;
  #       locations."/" = {
  #         proxyPass = "http://0.0.0.0:3081/";
  #       };
  #     };
  #   };
  # };
  # virtualisation.oci-containers.containers = {
  #   pihole = {
  #     image = "pihole/pihole:latest";
  #     environment = {
  #       TZ = "America/Toronto";
  #       ServerIP = "100.110.99.103";
  #       VIRTUAL_HOST = "pihole.biome";
  #     };
  #     extraOptions = [
  #       "--cap-add=NET_ADMIN"
  #       "--dns=127.0.0.1"
  #       "--dns=1.1.1.1"
  #     ];
  #     workdir = "/var/lib/pihole/";
  #     ports = [
  #       "100.110.99.103:53:53/tcp"
  #       "100.110.99.103:53:53/udp"
  #       "30443:443"
  #       "3080:80"
  #     ];
  #     volumes = [
  #       "/var/lib/etc-pihole:/etc/pihole"
  #       "/var/lib/etc-dnsmasq.d:/etc/dnsmasq.d"
  #     ];
  #   };
  #   pigallery = {
  #     image = "bpatrik/pigallery2:latest";
  #     environment = {
  #       NODE_ENV = "production";
  #     };
  #     volumes = [
  #       "/var/lib/pigallery/config:/app/data/config"
  #       "/var/lib/pigallery/db-data:/app/data/db"
  #       "/var/lib/pigallery/tmp:/app/data/tmp"
  #       "/mnt/storage/photos:/app/data/images:ro"
  #     ];
  #     ports = [
  #       "3081:80"
  #     ];
  #   };
  # };

  programs.steam.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;

  networking.hostName = "triwizard";
  time.timeZone = "America/Toronto";

  # networking.useDHCP = false;
  # networking.interfaces.enp3s0.useDHCP = true;
  # networking.interfaces.wlp4s0.useDHCP = true;
  networking.networkmanager.enable = true;

  # Configure X11
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.libinput.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.windowManager.xmonad.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # 32 bit support for steam
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

  system.stateVersion = "22.11";

  environment.systemPackages = with pkgs; [
    fuse3 # for nofail option on mergerfs (fuse defaults to fuse2)
    mergerfs
    mergerfs-tools
    cudatoolkit
    libGLU
    libGL
    virt-manager
    rocket-league.rocket-league
  ];

  fileSystems = {
    "/backup" = {
      device = "/dev/disk/by-id/ata-ST2000DM008-2FR102_ZK301BBG-part1";
      options = [ "rw" "users" ];
      fsType = "ext4";
    };
    "/storage" = {
      device = "/dev/disk/by-id/ata-KINGSTON_SA400S37480G_50026B778321B815-part1";
      options = [ "rw" "users" ];
      fsType = "ext4";
    };
  };
}

