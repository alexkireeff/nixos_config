{ config, pkgs, lib, ... }:

{

  # TODO FUTURE remove udevmonConfig and plugins when error fixed
  services.interception-tools = {
    enable = true;
    plugins = [ pkgs.interception-tools-plugins.caps2esc ];
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };

  # TODO FUTURE bluetooth
  services.pipewire = {
    enable = true;
    alsa.enable = true; # low level soundcard interface
    pulse.enable = true; # pulseaudio interface

  };

  services.logind = {
    extraConfig = ''
      HandlLidSwitch=suspend-then-hibernate
      HandlePowerKey=suspend-then-hibernate
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
    '';

  };
}
