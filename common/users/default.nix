{ pkgs, ... }:
let
  authorizedSSHKeys = pkgs.callPackage ./authorizedSSHKeys.nix { inherit pkgs; };
in {

  users.mutableUsers = false;

  users.users.root.openssh.authorizedKeys.keys = authorizedSSHKeys;
  users.users.lukas.openssh.authorizedKeys.keys = authorizedSSHKeys;

  users.users.lukas = {
    isNormalUser = true;
    extraGroups = [ "video" "networkmanager" "docker" "wheel" ]; # Enable ‘sudo’ for the user.
    hashedPassword = "$6$QoMeQJwCG5Xh$PrTJgARgUCtHDu21ZPZVCxPe8pnB99o4GfjwdmhCmf8e1MsxhP4PtkuuLmqtemLw8g2.WNaZjKzyHExfJtsxj/";
  };
}
