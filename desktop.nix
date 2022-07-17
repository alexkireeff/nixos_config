{
  config,
  pkgs,
  lib,
  ...
}: let
  CD = builtins.toString ./.;
in {
  imports = ["${CD}/gui.nix"];

  home-manager.users.user.services.swayidle.timeouts = [
    {
      timeout = 60 * 4;
      command = "[[ $(${pkgs.coreutils}/bin/cat /sys/class/power_supply/ACAD/online) -eq 0 ]] && ${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
    }
  ];

  networking = {
    firewall.allowedTCPPorts = [22];
    hostName = "desktop";
  };

  services = {
    fail2ban.enable = true;
    logind.extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
    '';
    sshd.enable = true;
  };

  swapDevices = [
    {
      device = "/swapfile";
      # NOTE RAM size + 1 GB
      size = (32 + 1) * 1024;
    }
  ];


}
