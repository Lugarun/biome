{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../common
      ../../modules/restic.nix
    ];

  # biome config
  biome.restic.enable = true;
  biome.restic.backupDirs = [ "/home/syncthing/data" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "fiasco";

  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # 32 bit support for steam
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva  ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.libinput.enable = true;
  services.xserver.windowManager.xmonad.enable = true;

  # Prevent suspend
  services.logind.lidSwitch = "ignore";


  # change backlight
  programs.light.enable = true;
  services.actkbd = {
      enable = true;
      bindings = [
          { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 5"; }
          { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 5"; }
          { keys = [ 229 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -s sysfs/leds/smc::kbd_backlight -U 20"; }
          { keys = [ 230 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -s sysfs/leds/smc::kbd_backlight -A 20"; }
          { keys = [ 113 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/runuser -l lukas -c 'amixer -q set Master toggle'"; }
          { keys = [ 114 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/runuser -l lukas -c 'amixer -q set Master 5%- unmute'"; }
          { keys = [ 115 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/runuser -l lukas -c 'amixer -q set Master 5%+ unmute'"; }

          ];
      };

  system.stateVersion = "20.03";

}

