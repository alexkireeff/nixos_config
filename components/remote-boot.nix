{
  config,
  pkgs,
  lib,
  impure-info,
  ...
}: let
  initrd_ca_cert_file = "/etc/ssl/certs/ca-certificates.crt";
  initrd_duckdns_file = "/etc/nixos/duckdns_url";
in {
  boot.initrd = {
    # copy programs to initrd
    extraUtilsCommands = ''
      copy_bin_and_libs ${pkgs.bash}/bin/bash
      copy_bin_and_libs ${pkgs.pkgsStatic.curl}/bin/curl
    '';

    network = {
      enable = true;

      # after initrd done, run this command
      postCommands = ''
        curl --cacert ${initrd_ca_cert_file} "$(cat ${initrd_duckdns_file})" > /dev/null
      '';

      # ssh setup
      ssh = {
        enable = true;
        authorizedKeys = config.users.users.user.openssh.authorizedKeys.keys;
        hostKeys = [impure-info.initrd_ssh_host_key_file_path_string];
      };

      # make sure we connect to network
      udhcpc.extraArgs = ["--retries" "100"];
    };

    # copy files to initrd
    secrets = {
      "${initrd_ca_cert_file}" = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      "${initrd_duckdns_file}" = impure-info.duckdns_url_file_path_string;
    };
  };

  # update ddns every minute once decrypted
  systemd.services = {
    ddns-updater = {
      path = [
        pkgs.bash
        pkgs.pkgsStatic.curl
      ];
      script = "curl --cacert ${initrd_ca_cert_file} \"$(cat ${initrd_duckdns_file})\" > /dev/null";
      startAt = "minutely";
    };
  };
}
