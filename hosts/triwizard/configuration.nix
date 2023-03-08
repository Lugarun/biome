{ config, pkgs, lib,  ... }:
{

  imports =
    [ 
      ./hardware-configuration.nix
      ../../common
      ../../modules/restic.nix
      ../../modules/syncthing.nix
      ../../modules/filestash.nix
      ../../modules/slurm.nix
    ];

  # Windows via virt-manager
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  biome.syncthing.enable = true;
  # biome.filestash.enable = true;
  biome.slurm = {
    enable = true;
    server = true;
    client = true;
    name = [ "triwizard" ];
    controlMachine = "triwizard";
  };


  # biome.restic = {
  #   enable = true;
  #   backupDirs = ["/mnt/storage" "/home/lukas/workspace" "/home/lukas/phone"];
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
    "/archive" = {
      device = "/dev/disk/by-id/ata-KINGSTON_SA400S37480G_50026B778321B815-part1";
      options = [ "rw" "users" ];
      fsType = "ext4";
    };
    "/mergerfs/disk1" = {
      device = "/dev/disk/by-id/ata-WDC_WD5000AAVS-22G9B1_WD-WCAUK0476639-part1";
      options = [ "rw" "users" ];
      fsType = "ext4";
    };
    "/mergerfs/disk2" = {
      device = "/dev/disk/by-id/ata-Hitachi_HTS545050B9SA02_100717PBL40017HT423V-part6";
      options = [ "rw" "users" ];
      fsType = "ext4";
    };
    "/mergerfs/merged" = {
      device = "/mergerfs/disk1:/mergerfs/disk2";
      fsType = "fuse.mergerfs";
      options = [
        "defaults"
        "nonempty"
        "allow_other"
        "use_ino"
        "cache.files=off"
        "dropcacheonclose=true"
        "category.create=mspmfs"
        "moveonenospc=true"
        "dropcacheonclose=true"
        "minfreespace=20G"
        "fsname=mergerfs 0 0"
      ];
    };
  };
}

