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
  imports = ["${CD}/../components/gui.nix" "${CD}/hardware/laptop-hardware.nix"];

  boot.kernelParams = [
    "mem_sleep_default=deep"
    "nvme.noacpi=1"
  ];

  # for firefox hardware acceleration
  hardware.opengl.extraPackages = [
    pkgs.intel-media-driver
  ];

  home-manager.users.user.services.swayidle.timeouts = [
    {
      timeout = 4 * 60;
      command = "[[ $(${pkgs.coreutils}/bin/cat /sys/class/power_supply/ACAD/online) -eq 0 ]] && ${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
    }
  ];

  networking.hostName = "laptop";

  nix = {
    buildMachines = [
      {
        # NOTE: it uses the root user's config/settings, so we have to set it up there for this to work
        hostName = "user@${impure-info.desktop_dns}?ssh-key=${impure-info.ssh_key_path_string}";
        systems = ["x86_64-linux" "i686-linux"];
        maxJobs = 12;
        speedFactor = 2;
        supportedFeatures = ["benchmark" "big-parallel" "ca-derivations" "kvm" "nixos-test"];
        mandatoryFeatures = [];
      }
    ];
    distributedBuilds = true;

    extraOptions = ''
      builders-use-substitutes = true
    '';
  };

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
