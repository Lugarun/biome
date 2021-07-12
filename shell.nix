let
  pkgs = import <nixpkgs> {};
in
pkgs.mkShell {
  buildInputs = [
    pkgs.morph
    pkgs.libqrencode
    pkgs.jq
    ];
}
