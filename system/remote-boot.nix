{
  config,
  pkgs,
  lib,
  ...
}: {
# TODO current theory of errors:
# can't connect to initramfs bc incorrect ethernet module thingy

# ssh setup
boot.initrd.network.enable = true;
boot.initrd.network.ssh = {
  enable = true;
  port = 22;
  authorizedKeys = config.users.users.user.openssh.authorizedKeys.keys;
  hostKeys = [ "/home/user/.ssh/initrd_ssh_host_key" ];
};

# copy your onion folder
boot.initrd.secrets = {
  "/etc/duckdnsscript.sh" = /home/user/duckdnsscript.sh;
};

# copy tor to you initrd
boot.initrd.extraUtilsCommands = ''
  copy_bin_and_libs ${pkgs.bash}/bin/bash
  copy_bin_and_libs ${pkgs.bind}/bin/host
  copy_bin_and_libs ${pkgs.curl}/bin/curl
'';

# TODO verify ducknsscript isn't saved
# start tor during boot process
boot.initrd.network.postCommands = ''
  echo "updating duckdns ip"
  bash /etc/duckdnsscript.sh
'';
}
