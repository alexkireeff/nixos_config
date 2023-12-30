{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  CD = builtins.toString ./.;
  # use precompiled firefox
  FIREFOX = pkgs.firefox-bin;
in {
  imports = ["${CD}/base.nix"];

  environment = {
    loginShellInit = ''[[ "$(tty)" == /dev/tty1 ]] && ${pkgs.sway}/bin/sway'';
    systemPackages = with pkgs; [
      pulseaudio
    ];
  };

  # alacritty requires opengl
  hardware.opengl.enable = true;

  home-manager = {
    users.user = {
      home.packages = with pkgs; [
        # sway
        swayidle # idle controller
        swaylock # lock screen
        wl-clipboard # clipboard
        i3status-rust # status for bar

        # gui programs
        speedcrunch # calculator
      ];

      # blue light filter
      services.gammastep = {
        enable = true;
        latitude = 38.897957;
        longitude = -77.036556;
        temperature = {
          day = 6500;
          night = 2000;
        };
      };

      services.swayidle = {
        enable = true;
        events = [
          {
            event = "before-sleep";
            command = "${pkgs.swaylock}/bin/swaylock";
          }
        ];
      };

      programs.alacritty = {
        enable = true;
        settings = {
          key_bindings = [
            {
              key = "N";
              mods = "Control|Shift";
              action = "SpawnNewInstance";
            }
          ];
          font = {
            bold = {
              family = "Roboto Mono Nerd Font";
              style = "Bold";
            };
            bold_italic = {
              family = "Roboto Mono Nerd Font";
              style = "Bold Italic";
            };
            italic = {
              family = "Roboto Mono Nerd Font";
              style = "Italic";
            };
            normal = {
              family = "Roboto Mono Nerd Font";
              style = "Regular";
            };
          };
        };
      };

      programs.firefox = {
        enable = true;
        package = FIREFOX;
        profiles.default = {
          extensions = with config.nur.repos.rycee.firefox-addons; [
            # privacy
            privacy-badger
            ublock-origin

            # dark mode
            darkreader

            # paywalls
            bypass-paywalls-clean

            # control video speed
            videospeed
          ];
          id = 0;
          name = "default";
          isDefault = true;
          bookmarks = {
            "google" = {
              keyword = "!g";
              url = "https://www.google.com/search?q=%s";
            };
            "google scholar" = {
              keyword = "!s";
              url = "https://scholar.google.com/scholar?q=%s";
            };
            "wikipedia" = {
              keyword = "!w";
              url = "https://en.wikipedia.org/wiki/%s";
            };
            "youtube" = {
              keyword = "!y";
              url = "https://www.youtube.com/results?search_query=%s";
            };
            "desmos" = {
              keyword = "!d";
              url = "https://www.desmos.com/calculator";
            };
          };
          settings = {
            # Go through about:preferences, changing what you want and compare that to about:config
            # General
            "browser.display.background_color" = "#000000";
            "browser.download.always_ask_before_handling_new_types" = true;
            "browser.download.viewableInternally.previousHandler.alwaysAskBeforeHandling.avif" = true;
            "browser.download.viewableInternally.previousHandler.alwaysAskBeforeHandling.webp" = true;
            "browser.download.viewableInternally.typeWasRegistered.avif" = true;
            "browser.download.viewableInternally.typeWasRegistered.webp" = true;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
            "layout.css.prefers-color-scheme.content-override" = 0;
            "media.eme.enabled" = true;
            "widget.gtk.overlay-scrollbars.enabled" = true;

            # Home
            "browser.newtabpage.enabled" = false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
            "browser.newtabpage.activity-stream.showSearch" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.startup.homepage" = "duckduckgo.com";

            # Search
            # NOTE have to manually:
            # delete unwanted search engines
            # change search engine
            # enable installed extensions
            # clear toolbar extensions and slots
            "browser.search.suggest.enabled" = false;
            "browser.urlbar.shortcuts.bookmarks" = false;
            "browser.urlbar.shortcuts.history" = false;
            "browser.urlbar.shortcuts.tabs" = false;
            "browser.urlbar.showSearchSuggestionsFirst" = false;
            "browser.urlbar.suggest.searches" = false;

            # Privacy
            "app.shield.optoutstudies.enabled" = false;
            "browser.discovery.enabled" = false;
            "browser.formfill.enable" = false;
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
            "browser.ping-centre.telemetry" = false;
            "browser.urlbar.suggest.bookmark" = false;
            "browser.urlbar.suggest.engines" = false;
            "browser.urlbar.suggest.history" = false;
            "browser.urlbar.suggest.openpage" = false;
            "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
            "browser.urlbar.suggest.quicksuggest.sponsored" = false;
            "browser.urlbar.suggest.topsites" = false;
            "datareporting.healthreport.uploadEnabled" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "dom.security.https_only_mode" = true;
            "dom.security.https_only_mode_ever_enabled" = true;
            "places.history.enabled" = false;
            "privacy.donottrackheader.enabled" = true;
            "privacy.history.custom" = true;
            "signon.autofillForms" = false;
            "signon.generation.enabled" = false;
            "signon.management.page.breach-alerts.enabled" = false;
            "signon.rememberSignons" = false;
            "extensions.formautofill.addresses.enabled" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            "security.protectionspopup.recordEventTelemetry" = false;
            "security.identitypopup.recordEventTelemetry" = false;
            "security.certerrors.recordEventTelemetry" = false;
            "security.app_menu.recordEventTelemetry" = false;
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.pioneer-new-studies-available" = false;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.updatePing.enabled" = false;

            # DOM Privacy
            "dom.battery.enabled" = false;

            # reading PDFs
            "pdfjs.defaultZoomValue" = "page-width";

            # enable userChrome.css
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

            # remove pocket
            "extensions.pocket.enabled" = false;

            # don't automatically hide toolbar when fullscreen
            "browser.fullscreen.autohide" = false;

            # warn when closing multiple
            "browser.tabs.warnOnClose" = true;
            "browser.tabs.warnOnCloseOtherTabs" = true;
            "browser.warnOnQuit" = true;

            # allow pasting in google docs
            "dom.event.clipboardevents.enabled" = true;

            # remove firefox view from toolbar
            "browser.tabs.firefox-view" = false;

            # remove picture in picture
            "media.videocontrols.picture-in-picture.enabled" = false;
          };
          userChrome = builtins.readFile "${CD}/configs/firefox.css";
        };
      };

      programs.i3status-rust = {
        bars.bottom = {
          blocks = [
            {
              block = "battery";
              empty_format = " BAT $percentage {$time|} ";
              format = " BAT $percentage {$time|} ";
              full_format = " BAT $percentage {$time|} ";
              interval = 60;
              not_charging_format = " BAT $percentage {$time|} ";
            }
            {
              block = "cpu";
              format = " CPU $utilization ";
              interval = 1;
            }
            {
              block = "disk_space";
              format = " DISK $used/$total ";
              path = "/";
            }
            {
              block = "memory";
              format = " MEM $mem_used/$mem_total ";
              format_alt = " SWP $swap_used/$swap_total ";
              interval = 5;
            }
            {
              block = "net";
              format = " {AP $ssid|LAN} {$ip|$ipv6}{ $signal_strength|} ";
              click = [{
                button = "left";
                cmd = "${pkgs.alacritty}/bin/alacritty -e nmtui";
              }];
            }
            {
              block = "sound";
              max_vol = 100;
              show_volume_when_muted = true;
              step_width = 1;
            }
            {
              block = "backlight";
              cycle = [1 100];
              device = "intel_backlight";
              maximum = 100;
              minimum = 1;
              step_width = 1;
            }
            {
              block = "time";
              format = " $timestamp.datetime(f:'%Y/%m/%d %H:%M:%S') ";
              interval = 1;
              timezone = "America/New_York";
            }
          ];

          settings.theme.theme = "plain";
        };

        enable = true;
      };

      programs.swaylock.settings = {
        show-failed-attempts = false;

        font-size = 0;

        color = "000000";

        ring-color = "ffffff";
        inside-color = "000000";
        line-color = "000000";
        text-color = "000000";

        ring-clear-color = "ffffff";
        inside-clear-color = "000000";
        line-clear-color = "000000";
        text-clear-color = "000000";

        ring-caps-lock-color = "ffffff";
        inside-caps-lock-color = "000000";
        line-caps-lock-color = "000000";
        text-caps-lock-color = "000000";

        ring-ver-color = "0061ff";
        inside-ver-color = "000000";
        line-ver-color = "000000";
        text-ver-color = "000000";

        ring-wrong-color = "ff0000";
        inside-wrong-color = "000000";
        line-wrong-color = "000000";
        text-wrong-color = "000000";

        indicator-radius = 10;
        indicator-idle-visible = true;
        indicator-caps-lock = false;

        disable-caps-lock-text = true;
      };

      wayland.windowManager.sway = let
        mod = "Mod1";
        term = "${pkgs.alacritty}/bin/alacritty";
      in {
        config = {
          bars = [{
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs config-bottom.toml";
          }];

          focus.forceWrapping = false;
          focus.followMouse = false;

          keybindings = lib.mkOptionDefault {
            "${mod}+a" = "exec ${pkgs.speedcrunch}/bin/speedcrunch";
            "${mod}+s" = "exec ${term}";
            "${mod}+d" = "exec ${FIREFOX}/bin/firefox";
          };

          modifier = mod;
          terminal = term;
        };

        enable = true;
      };
    };
  };

  # Control brightness
  programs.light.enable = true;

  # Allow swaylock to unlock computer after sleeping
  # If not the screen freezes
  security.pam.services.swaylock.text = "auth include login";

  services.pipewire = {
    enable = true;
    alsa.enable = true; # low level soundcard interface
    pulse.enable = true; # pulseaudio interface
  };
}
