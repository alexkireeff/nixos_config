{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  CD = builtins.toString ./.;
in {
  imports = ["${CD}/gui.nix"];

  boot.kernelParams = [
    "mem_sleep_default=deep"
    "nvme.noacpi=1"
  ];

  environment.systemPackages = [];

  home-manager.users.user.services.swayidle.timeouts = [
    {
      timeout = 60 * 4;
      command = "[[ $(${pkgs.coreutils}/bin/cat /sys/class/power_supply/ACAD/online) -eq 0 ]] && ${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
    }
  ];

  networking.hostName = "laptop";

  services.logind.extraConfig = ''
    HandlLidSwitch=suspend-then-hibernate
    HandlePowerKey=suspend-then-hibernate
    HandleSuspendKey=ignore
    HandleHibernateKey=ignore
  '';

  swapDevices = [
    {
      device = "/swapfile";
      # NOTE RAM size + 1 GB
      size = (8 + 1) * 1024;
    }
  ];
}
