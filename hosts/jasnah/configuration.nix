# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../common
      ../../modules/syncthing.nix
      ../../modules/mail.nix
    ];

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  biome.syncthing = {
    enable = true;
    baseDir = /home/lukas;
    folders = lib.importJSON ../../config/syncthing.json;
  };

  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
  ];

  services.teamviewer.enable = true;

  programs.adb.enable = true;
  users.users.lukas.extraGroups = ["adbusers"];
  programs.steam.enable = true;
  programs.kdeconnect.enable = true;
  biome.mail.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "jasnah";
  time.timeZone = "America/Toronto";

  networking.enableIPv6 = false;
  networking.useDHCP = false;
  networking.interfaces.enp2s0f0.useDHCP = true;
  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;
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
  services.xserver.videoDrivers = [ "amdgpu" ];
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

  # change backlight
  programs.light.enable = true;
  services.actkbd = {
      enable = true;
      bindings = [
          { keys = [ (233 - 8) ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 5"; }
          { keys = [ (232 - 8) ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 5"; }
          { keys = [ (235 - 8) ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -s sysfs/leds/tpacpi::kbd_backlight -U 20"; }
          { keys = [ (246 - 8) ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -s sysfs/leds/tpacpi::kbd_backlight -A 20"; }
          ];
      };

  system.stateVersion = "20.09";
}
