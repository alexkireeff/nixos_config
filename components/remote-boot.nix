{
  config,
  pkgs,
  lib,
  ...
}: {
  # ssh setup
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 22;
    authorizedKeys = config.users.users.user.openssh.authorizedKeys.keys;
    # sudo ssh-keygen -t ed25519 -N "" -f /etc/nixos/initrd_ssh_host_key
    hostKeys = ["/etc/nixos/initrd_ssh_host_key"];
  };

  # copy files to initrd
  boot.initrd.secrets = {
    "/etc/nixos/duckdnsurl" = null;
    "/etc/ssl/certs/ca-certificates.crt" = builtins.toPath "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  # copy programs to initrd
  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${pkgs.bash}/bin/bash
    copy_bin_and_libs ${pkgs.pkgsStatic.curl}/bin/curl
  '';

  # run during boot process
  # https://www.duckdns.org/install.jsp
  boot.initrd.network.postCommands = ''
    curl --cacert /etc/ssl/certs/ca-certificates.crt "$(cat /etc/nixos/duckdnsurl)" > /dev/null
  '';

  systemd.services = {
    ddns-updater = {
      path = with pkgs; [
        bash
        pkgsStatic.curl
      ];
      script = "curl --cacert /etc/ssl/certs/ca-certificates.crt \"$(cat /etc/nixos/duckdnsurl)\" > /dev/null";
      startAt = "minutely";
    };
  };
}
