{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  CD = builtins.toString ./.;
  # TODO builtins.readFile
  pub_ssh_key = "";
  pub_git_key = "";
in {
  imports = ["${CD}/gui.nix"];

  # dual boot # TODO doesn't work
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;

  # TODO install cuda + cudnn ? so i think cudatoolkit
  # TODO use cachix?
  environment.systemPackages = with pkgs; [
    #cudaPackages.cudatoolkit
    #cudaPackages.cudnn
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
        group = "git";
        hashedPassword = ".";
        home = "/var/git";
        isSystemUser = true;
        openssh.authorizedKeys.keys = [pub_git_key];
        shell = "${pkgs.git}/bin/git-shell";
      };
      user.openssh.authorizedKeys.keys = [pub_ssh_key];
    };
  };
}
