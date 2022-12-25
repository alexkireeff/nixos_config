{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  CD = builtins.toString ./.;
  pub_ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLXQbVQIF1/DuPfoA3+YpLpjH1geOTmEff71wDhNgGN user";
  pub_git_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOt307aOiM2fsBlTPIpfvTDZWjA7v+7nN60f7IuCWNm1 user";
in {
  imports = ["${CD}/base.nix" ]; #"${CD}/remote-boot.nix"];

  # enable network card for remote-boot.nix
  # boot.initrd.availableKernelModules = ["r8169"]; # do we actually need this because at one point in time it worked without this but that could also be a symptom of the bug we've been fighting for months...

  # just using this to force reset initrd
  # ala https://github.com/NixOS/nixpkgs/issues/114594#issuecomment-1336514410
  # boot.initrd.luks.mitigateDMAAttacks = false;

  # TODO FUTURE remove this it sets up the ethernet interface
  # https://github.com/NixOS/nixpkgs/issues/157034
  networking.interfaces.enp34s0.useDHCP = lib.mkDefault true;

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
      forwardX11 = true; # gui applications
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
      user.extraGroups = ["git"];
      git = {
        createHome = true;
        group = "git";
        hashedPassword = ".";
        home = "/var/git";
        homeMode = "770";
        isSystemUser = true;
        openssh.authorizedKeys.keys = [pub_git_key];
        shell = "${pkgs.git}/bin/git-shell";
      };
      user.openssh.authorizedKeys.keys = [pub_ssh_key];
    };
  };
}
