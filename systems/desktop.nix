{
  config,
  pkgs,
  lib,
  home-manager,
  impure-info,
  ...
}: let
  CD = builtins.toString ./.;
in {
  imports = ["${CD}/../components/base.nix" "${CD}/hardware/desktop-hardware.nix" "${CD}/../components/remote-boot.nix"];
  config = {
    # enable network card for remote-boot.nix
    boot.initrd.availableKernelModules = ["r8169"];

    # local network takes a while to connect to
    boot.initrd.network.udhcpc.extraArgs = ["--retries" "10"];

    environment.systemPackages = with pkgs; [];

    # nvidia driver
    hardware.opengl.enable = true;
    services.xserver.videoDrivers = ["nvidia"];

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

        settings = {
          X11Forwarding = true; # gui applications
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
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
        user.extraGroups = ["git"];
        git = {
          createHome = true;
          group = "git";
          hashedPassword = ".";
          home = "/var/git";
          homeMode = "770";
          isSystemUser = true;
          openssh.authorizedKeys.keys = [(lib.removeSuffix "\n" (builtins.readFile (impure-info.git_key_path_string + ".pub")))];
          shell = "${pkgs.git}/bin/git-shell";
        };
        user.openssh.authorizedKeys.keys = [(lib.removeSuffix "\n" (builtins.readFile (impure-info.ssh_key_path_string + ".pub")))];
      };
    };
  };
}
