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

  # TODO install cuda + cudnn ? so i think cudatoolkit
  # TODO use cachix?
  # how to get ml working:
  # 1.) get driver installed
  # 2.) get driver running
  # 3.) get library installed (cuda/cudnn/etc.)
  # 4.) verify working with pytorch
  services.xserver.videoDrivers = [ "nvidia" ];
  #environment.systemPackages = with pkgs; [
  #  linuxPackages.nvidia_x11 # make this start?
  #  ];

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
