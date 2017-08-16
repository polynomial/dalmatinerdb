{ bootFetchgit ? (import <nixpkgs> {}).fetchgit }:
let
  pkgs = import (bootFetchgit (import ./version.nix)) {};
  inherit (pkgs) stdenv;

  appRoot = builtins.toPath ./.;
  version = "0.1.0";
in stdenv.mkDerivation {
  inherit version;
  name = "dalmatinerdb-${version}";

  builtInputs = with pkgs; [ erlang stdenv.cc ];
}
