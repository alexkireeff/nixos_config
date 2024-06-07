# ./overlays/default.nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {dwl = prev.dwl.overrideAttrs {configFile = "../components/configs/dwl.h";};})
  ];
}
