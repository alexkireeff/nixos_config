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
    hostKeys = ["/etc/nixos/initrd_ssh_host_key"];
  };

  # copy files to initrd
  boot.initrd.secrets = {
    "/etc/nixos/duckdnsurl" = null;
    "/etc/ssl/certs/ca-certificates.crt" = /nix/store/w22mgz86w3nqjc91xmcpngssnb0pj0k8-nss-cacert-3.86/etc/ssl/certs/ca-bundle.crt;
    # TODO file a bug report with initrd being unable to copy linked files
    # can view for debugging purposes in /.initrd-secrets/ during phase 1 boot
    # "/etc/ssl/certs/ca-certificates.crt" = null;
  };

  # copy programs to initrd
  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${pkgs.bash}/bin/bash
    copy_bin_and_libs ${pkgs.pkgsStatic.curl}/bin/curl
  '';

  # run during boot process
  boot.initrd.network.postCommands = ''
    curl --cacert /etc/ssl/certs/ca-certificates.crt \"$(cat /etc/nixos/duckdnsurl)\" > /dev/null
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
