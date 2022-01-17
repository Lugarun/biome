{ config, pkgs, ... }:

{

  imports =
    [ 
      ./hardware-configuration.nix
      ../../common
      ../../modules/mail.nix
    ];

  programs.steam.enable = true;
  biome.mail.enable = true;
  biome.syncthing.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;

  networking.hostName = "triwizard";
  time.timeZone = "America/Toronto";

  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;
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

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # 32 bit support for steam
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

  system.stateVersion = "20.03";

  environment.systemPackages = with pkgs; [
    fuse3 # for nofail option on mergerfs (fuse defaults to fuse2)
    mergerfs
    mergerfs-tools
  ];

  # hard drives
  fileSystems = {
    "/mnt/disk1" = {
      device = "/dev/disk/by-id/ata-WDC_WD5000AAVS-22G9B1_WD-WCAUK0476639-part1";
      fsType = "ext4";
    };
    "/mnt/disk2" = {
      device = "/dev/disk/by-id/ata-Hitachi_HTS545050B9SA02_100717PBL40017HT423V-part6";
      fsType = "ext4";
    };
    "/mnt/disk3" = {
      device = "/dev/disk/by-id/ata-Radeon_R7_A22MF061508000332-part1";
      fsType = "ext4";
    };
    "/mnt/storage" = {
      device = "/mnt/disk1:/mnt/disk2:/mnt/disk3";
      fsType = "fuse.mergerfs";
      options = [
        "defaults"
        "nonempty"
        "allow_other"
        "use_ino"
        "cache.files=off"
        "dropcacheonclose=true"
        "category.create=epmfs"
        "nofail"
        "moveonenospc=true"
        "dropcacheonclose=true"
        "minfreespace=200G"
        "fsname=mergerfs 0 0"
      ];
    };
  };
}

