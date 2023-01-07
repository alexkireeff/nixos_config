{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  CD = builtins.toString ./.;
in {
  imports = ["${CD}/gui.nix" "${CD}/laptop-hardware.nix"];

  boot.kernelParams = [
    "mem_sleep_default=deep"
    "nvme.noacpi=1"
  ];

  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver # for firefox hardware acceleration
  ];

  home-manager.users.user.services.swayidle.timeouts = [
    {
      timeout = 60 * 4;
      command = "[[ $(${pkgs.coreutils}/bin/cat /sys/class/power_supply/ACAD/online) -eq 0 ]] && ${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
    }
  ];

  networking.hostName = "laptop";

  services = {
    fwupd.enable = true;
    logind.extraConfig = ''
      HandlLidSwitch=hibernate
      HandlePowerKey=hibernate
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
    '';
  };

  swapDevices = [
    {
      device = "/swapfile";
      # NOTE RAM size + 1 GB
      size = (8 + 1) * 1024;
    }
  ];
}
