# This allows a user to run nix-shell in the tech repo and then all
# of their system dependencies will be handled. More info on NixOS:
#  https://nixos.org/
#  http://nixos.org/nix/manual/#sec-nix-shell

{ systemNixpkgs ? import <nixpkgs> {}
}:

let
  inherit (systemNixpkgs) stdenv fetchzip;
    version = import ./etc/version.nix;
    getUrl = name: channels:
        "${channels.${name}.baseUrl}/${channels.${name}.version}/nixexprs.tar.xz";
    getSha = name: channels: channels.${name}.sha256;
    getVer = name: channels: channels.${name}.version;
    fetchChannel = url: sha256: name:
        fetchzip { inherit url sha256 name; };
    channelPath = name: channels: fetchChannel
        (getUrl name channels)
        (getSha name channels)
        "${name}-${getVer name channels}";
    nixpkgsPath = builtins.toPath (channelPath "nixpkgs" version.channels);
    nixpkgs = import nixpkgsPath {
      config.allowUnfree = true;
    };
    nixos = import "${nixpkgsPath}/nixos" {};

in stdenv.mkDerivation {
    name = "e-tech";

    buildInputs = with nixpkgs; [
        # build
        git
        gnumake
        erlangR18
        linuxHeaders
    ];
    shellHook = ''
        export NIX_PATH="nixpkgs=${nixpkgsPath}"
        export NIX_PATH="$NIX_PATH:nixos=${nixpkgsPath}/nixos"

    '';
}

