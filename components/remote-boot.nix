{
  config,
  pkgs,
  lib,
  impure-info,
  ...
}: let
  duckdns_url_file_path = "/etc/nixos/duckdns_url";
in {
  boot.initrd = {
    # copy programs to initrd
    extraUtilsCommands = ''
      copy_bin_and_libs ${pkgs.bash}/bin/bash
      copy_bin_and_libs ${pkgs.pkgsStatic.curl}/bin/curl
    '';

    network = {
      enable = true;

      # run during boot process
      # https://www.duckdns.org/install.jsp
      postCommands = ''
        curl --cacert /etc/ssl/certs/ca-certificates.crt "$(cat /etc/nixos/duckdns_url)" > /dev/null
      '';

      # ssh setup
      ssh = let
        initrd_ssh_host_key_file_path = "/etc/nixos/initrd_ssh_host_key";
      in {
        enable = true;
        authorizedKeys = config.users.users.user.openssh.authorizedKeys.keys;
        hostKeys =
          if (builtins.pathExists initrd_ssh_host_key_file_path)
          then [(builtins.toPath initrd_ssh_host_key_file_path)]
          else
            throw ''
              missing initrd ssh host key file
              Do:
                sudo ssh-keygen -t ed25519 -a 100 -N "" -C "initrd_ssh_key" -f ${initrd_ssh_host_key_file_path}
                sudo chown user:users ${initrd_ssh_host_key_file_path} ${initrd_ssh_host_key_file_path}.pub
                chmod 600 ${initrd_ssh_host_key_file_path}
                chmod 644 ${initrd_ssh_host_key_file_path}.pub
            '';
      };
    };

    # copy files to initrd
    secrets = {
      "/etc/nixos/duckdns_url" =
        if (builtins.pathExists duckdns_url_file_path)
        then duckdns_url_file_path
        else
          throw ''
            missing duckdns url file
            Do:
              https://www.duckdns.org/install.jsp?tab=hardware
              get the domain and token
              echo "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip=" | sudo tee ${duckdns_url_file_path}
              sudo chmod 400 ${duckdns_url_file_path}
          '';

      "/etc/ssl/certs/ca-certificates.crt" = builtins.toPath "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    };
  };

  systemd.services = {
    ddns-updater = {
      path = with pkgs; [
        bash
        pkgsStatic.curl
      ];
      script = "curl --cacert /etc/ssl/certs/ca-certificates.crt \"$(cat /etc/nixos/duckdns_url)\" > /dev/null";
      startAt = "minutely";
    };
  };
}
