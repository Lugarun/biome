{ pkgs, ... }:
let keys = builtins.readFile ../../config/authorizedSSHKeys.txt;
in builtins.filter (x: x != "") (pkgs.lib.strings.splitString "\n" keys)
