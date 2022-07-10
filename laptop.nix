{
  config,
  pkgs,
  lib,
  ...
}: {
  environment.loginShellInit = ''[[ "$(tty)" == /dev/tty1 ]] && ${pkgs.sway}/bin/sway'';

  services.logind.extraConfig = ''
    HandlLidSwitch=suspend-then-hibernate
    HandlePowerKey=suspend-then-hibernate
    HandleSuspendKey=ignore
    HandleHibernateKey=ignore
  '';
}
