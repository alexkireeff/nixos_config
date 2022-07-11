{
  config,
  pkgs,
  lib,
  ...
}: let
  config = {
    computerName = "laptop";
  };
  CD = builtins.toString ./.;
in {
  imports = ["${CD}/gui.nix"];

  services.logind.extraConfig = ''
    HandlLidSwitch=suspend-then-hibernate
    HandlePowerKey=suspend-then-hibernate
    HandleSuspendKey=ignore
    HandleHibernateKey=ignore
  '';
}
