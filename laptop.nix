{
  config,
  pkgs,
  lib,
  ...
}: let
  CD = builtins.toString ./.;
in {
  imports = ["${CD}/gui.nix"];

  networking.hostName = "laptop";

  services.logind.extraConfig = ''
    HandlLidSwitch=suspend-then-hibernate
    HandlePowerKey=suspend-then-hibernate
    HandleSuspendKey=ignore
    HandleHibernateKey=ignore
  '';
}
