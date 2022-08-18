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

# TODO verify ducknsscript isn't saved
# start tor during boot process
boot.initrd.network.postCommands = ''
  bash /etc/duckdnsscript.sh
'';
}
