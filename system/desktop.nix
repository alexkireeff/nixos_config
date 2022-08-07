{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  CD = builtins.toString ./.;
  pub_ssh_key = "";
  pub_git_key = "";
in {
  imports = ["${CD}/gui.nix"];

  home-manager.users.user.services.swayidle.timeouts = [
    {
      timeout = 60 * 4;
      command = "[[ $(${pkgs.coreutils}/bin/cat /sys/class/power_supply/ACAD/online) -eq 0 ]] && ${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
    }
  ];

  networking.hostName = "desktop";

  services = {
    fail2ban.enable = true;
    logind.extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
    '';
    openssh = {
      enable = true;
      allowSFTP = true; # sshfs
      forwardX11 = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      # NOTE RAM size + 1 GB
      size = (32 + 1) * 1024;
    }
  ];

  users = {
    groups.git = {};

    users = {
      git = {
        createHome = true;
        extraGroups = ["git"];
        hashedPassword = ".";
        home = "/git";
        isSystemUser = true;
        openssh.authorizedKeys.keys = [pub_git_key];
        shell = "${pkgs.git}/bin/git-shell";
      };
    };

    user.openssh.authorizedKeys.keys = [pub_ssh_key];
  };
}
