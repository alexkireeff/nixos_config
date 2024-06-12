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
  imports = ["${CD}/base.nix"];

  environment = {
    loginShellInit = ''[[ "$(tty)" == /dev/tty1 ]] && light -N 1 && ${pkgs.river}/bin/river'';
    systemPackages = with pkgs; [
      pulseaudio
      wlr-randr
    ];
  };

  # alacritty requires opengl
  hardware.opengl.enable = true;

  home-manager = {
    users.user = {
      home.packages = [
        pkgs.speedcrunch # calculator
      ];

      # blue light filter
      services.gammastep = {
        enable = true;
        dawnTime = "8:45-9:15";
        duskTime = "20:45-21:15";
        temperature = {
          day = 6500;
          night = 1500;
        };
      };

      services.swayidle = {
        enable = true;
        events = [
          {
            event = "before-sleep";
            command = "${pkgs.waylock}/bin/waylock -fork-on-lock -init-color 0x7F7F7F -input-color 0xFFFFFF -fail-color 0x7F0000";
          }
        ];
      };

      programs.alacritty = {
        enable = true;
        settings = {
          keyboard.bindings = [
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

      # TODO firefox has no riverwm border
      # debugging notes:
      # when we try to add a border it only adds the border to the top and left sides
      # this leads me to believe the window is somehow offcenter
      # NOTE have to manually:
      # delete unwanted search engines
      # enable installed extensions
      # clear toolbar extensions and slots
      programs.firefox = {
        enable = true;
        package = pkgs.firefox-bin;
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
          };
          search = {
            force = true;
            default = "Google";
            privateDefault = "Google";

            engines = {
              "Bing".metaData.hidden = true;
              "ebay".metaData.hidden = true;
              "Amazon.com".metaData.hidden = true;
              "DuckDuckGo".metaData.hidden = true;
              "Wikipedia (en)".metaData.hidden = true;
            };
          };
          settings = {
            # Go through about:preferences, changing what you want and compare that to about:config
            # https://kb.mozillazine.org/About:config_entries
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

            # Search
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
            "dom.forms.autocomplete.formautofill" = false;
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

            # startup page is blank by default
            "browser.startup.page" = 0;
          };
          userChrome = builtins.readFile "${CD}/configs/firefox.config";
        };
      };

      programs.yambar = {
        enable = true;
        settings = {
          bar = {
            location = "bottom";
            height = 25;
            background = "000000FF";
            font = "Roboto Mono Nerd Font:pixelsize=24";

            border = {
              width = 1;
              color = "FFFFFFFF";
              margin = 1;
            };

            left = [
              {
                river.content.map.conditions."id < 10".map = {
                  default.string.text = " {id} |";
                  conditions = {
                    "urgent".string.text = " {id}!|";
                    "visible".string.text = " {id}V|";
                    "focused".string.text = " {id}*|";
                    "occupied".string.text = " {id}O|";
                  };
                };
              }
            ];

            right = [
              {
                battery = {
                  name = "BAT1";
                  content.map = {
                    default.string.text = "BAT: {capacity}% {estimate}";
                    conditions = {
                      "(state == discharging || state == \"not charging\") && capacity < 10".string = {
                        text = "BAT: {capacity}% {estimate}";
                        foreground = "FF0000FF";
                      };
                      "state == unkown".string = {
                        text = "BAT: Unknown";
                        foreground = "FF0000FF";
                      };
                    };
                  };
                };
              }
              {
                cpu.content.map.conditions."id < 0".string.text = " | CPU {cpu}% | ";
              }
              {
                mem.content.string.text = "MEM {percent_used}% | ";
              }
              {
                network = {
                  content.map.conditions."name != lo".map.conditions = {
                    "state == unknown".string = {
                      text = "Unknown | ";
                      on-click.right = "${pkgs.alacritty}/bin/alacritty -e nmtui";
                    };
                    "state == \"not present\"".string = {
                      text = "Not Present | ";
                      on-click.right = "${pkgs.alacritty}/bin/alacritty -e nmtui";
                    };
                    "state == down".string = {
                      text = "Down | ";
                      on-click.right = "${pkgs.alacritty}/bin/alacritty -e nmtui";
                    };
                    "state == \"lower layers down\"".string = {
                      text = "Lower Layers Down | ";
                      on-click.right = "${pkgs.alacritty}/bin/alacritty -e nmtui";
                    };
                    "state == testing".string = {
                      text = "Testing | ";
                      on-click.right = "${pkgs.alacritty}/bin/alacritty -e nmtui";
                    };
                    "state == dormant".string = {
                      text = "Dormant | ";
                      on-click.right = "${pkgs.alacritty}/bin/alacritty -e nmtui";
                    };
                    "state == up && ipv4 != \"\"".string = {
                      text = "{ssid}: {ipv4} {quality}% | ";
                      on-click.right = "${pkgs.alacritty}/bin/alacritty -e nmtui";
                    };
                    "state == up && ipv6 != \"\"".string = {
                      text = "{ssid}: {ipv6} {quality}% | ";
                      on-click.right = "${pkgs.alacritty}/bin/alacritty -e nmtui";
                    };
                  };
                };
              }
              {
                pulse.content.map = {
                  default.string = {
                    text = "VOL {sink_percent}%";
                    on-click = {
                      right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
                      wheel-up = ''
                        sh -c "
                        current=$(pactl -- get-sink-volume @DEFAULT_SINK@ | awk -F'/' '{print $2}' | sed 's/[^0-9]*//g')
                        if [ $current -lt 100 ]; then
                          pactl set-sink-volume @DEFAULT_SINK@ +1%
                        fi
                        "
                      '';
                      wheel-down = "pactl -- set-sink-volume @DEFAULT_SINK@ -1%";
                    };
                  };
                  conditions."sink_muted".string = {
                    text = "VOL {sink_percent}%";
                    foreground = "ff0000ff";
                    on-click = {
                      right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
                      wheel-up = ''
                        sh -c "
                        current=$(pactl -- get-sink-volume @DEFAULT_SINK@ | awk -F'/' '{print $2}' | sed 's/[^0-9]*//g')
                        if [ $current -lt 100 ]; then
                          pactl set-sink-volume @DEFAULT_SINK@ +1%
                        fi
                        "
                      '';
                      wheel-down = "pactl -- set-sink-volume @DEFAULT_SINK@ -1%";
                    };
                  };
                };
              }
              {
                backlight = {
                  name = "intel_backlight";
                  content.string = {
                    text = "| BRIGHT {percent}% | ";
                    on-click = {
                      wheel-up = "light -A 1";
                      wheel-down = "light -U 1";
                    };
                  };
                };
              }
              {
                clock = {
                  content.string.text = "{date} {time}";
                  date-format = "%Y/%m/%d";
                  time-format = "%H:%M:%S";
                };
              }
            ];
          };
        };
      };

      wayland.windowManager.river = {
        enable = true;
        systemd.enable = true;
        xwayland.enable = false; # TODO window issue is because this is disabled, isn't it?

        settings = {
          background-color = "0x000000";
          border-color-focused = "0xFFFFFF";
          border-color-unfocused = "0x7F7F7F";
          border-color-urgent = "0xFF0000";
          map.normal = {
            "Super S" = "spawn alacritty";
            "Super D" = "spawn firefox";
            "Super A" = "spawn speedcrunch";

            "Super Q" = "close";
            "Super+Shift E" = "exit";

            "Super J" = "focus-view next";
            "Super K" = "focus-view previous";

            "Super Period" = "focus-output next";
            "Super Comma" = "focus-output previous";

            "Super+Shift Period" = "send-to-output next";
            "Super+Shift Comma" = "send-to-output previous";

            "Super+Return" = "zoom";

            "Super H" = "send-layout-cmd rivertile \"main-ratio -0.05\"";
            "Super L" = "send-layout-cmd rivertile \"main-ratio +0.05\"";

            "Super+Shift H" = "send-layout-cmd rivertile \"main-count +1\"";
            "Super+Shift L" = "send-layout-cmd rivertile \"main-count -1\"";

            "Super+Alt H" = "move left 100";
            "Super+Alt J" = "move down 100";
            "Super+Alt K" = "move up 100";
            "Super+Alt L" = "move right 100";

            "Supet+Alt+Control H" = "snap left";
            "Supet+Alt+Control J" = "snap down";
            "Supet+Alt+Control K" = "snap up";
            "Supet+Alt+Control L" = "snap right";

            "Super+Alt+Shift H" = "resize horizontal -100";
            "Super+Alt+Shift J" = "resize vertical 100";
            "Super+Alt+Shift K" = "resize vertical -100";
            "Super+Alt+Shift L" = "resize horizontal 100";

            # tags are set using individual bits

            "Super 1" = "set-focused-tags 1";
            "Super 2" = "set-focused-tags 2";
            "Super 3" = "set-focused-tags 4";
            "Super 4" = "set-focused-tags 8";
            "Super 5" = "set-focused-tags 16";
            "Super 6" = "set-focused-tags 32";
            "Super 7" = "set-focused-tags 64";
            "Super 8" = "set-focused-tags 128";
            "Super 9" = "set-focused-tags 256";

            "Super+Shift 1" = "set-view-tags 1";
            "Super+Shift 2" = "set-view-tags 2";
            "Super+Shift 3" = "set-view-tags 4";
            "Super+Shift 4" = "set-view-tags 8";
            "Super+Shift 5" = "set-view-tags 16";
            "Super+Shift 6" = "set-view-tags 32";
            "Super+Shift 7" = "set-view-tags 64";
            "Super+Shift 8" = "set-view-tags 128";
            "Super+Shift 9" = "set-view-tags 256";

            "Super+Control 1" = "toggle-focused-tags 1";
            "Super+Control 2" = "toggle-focused-tags 2";
            "Super+Control 3" = "toggle-focused-tags 4";
            "Super+Control 4" = "toggle-focused-tags 8";
            "Super+Control 5" = "toggle-focused-tags 16";
            "Super+Control 6" = "toggle-focused-tags 32";
            "Super+Control 7" = "toggle-focused-tags 64";
            "Super+Control 8" = "toggle-focused-tags 128";
            "Super+Control 9" = "toggle-focused-tags 256";

            "Super+Shift+Control 1" = "toggle-view-tags 1";
            "Super+Shift+Control 2" = "toggle-view-tags 2";
            "Super+Shift+Control 3" = "toggle-view-tags 4";
            "Super+Shift+Control 4" = "toggle-view-tags 8";
            "Super+Shift+Control 5" = "toggle-view-tags 16";
            "Super+Shift+Control 6" = "toggle-view-tags 32";
            "Super+Shift+Control 7" = "toggle-view-tags 64";
            "Super+Shift+Control 8" = "toggle-view-tags 128";
            "Super+Shift+Control 9" = "toggle-view-tags 256";

            "Super 0" = "set-focused-tags 2147483648";
            "Super+Shift 0" = "set-view-tags 2147483648";

            "Super Space" = "toggle-float";
            "Super F" = "toggle-fullscreen";

            "Super Left" = "send-layout-cmd rivertile \"main-location left\"";
            "Super Down" = "send-layout-cmd rivertile \"main-location bottom\"";
            "Super Up" = "send-layout-cmd rivertile \"main-location top\"";
            "Super Right" = "send-layout-cmd rivertile \"main-location right\"";
          };
          map-pointer.normal = {
            "Super BTN_LEFT" = "move-view";
            "Super BTN_RIGHT" = "resize-view";
            "Super BTN_MIDDLE" = "toggle-float";
          };
          set-repeat = "50 300";
          spawn = ["\"wlr-randr --output eDP-1 --scale 2\"" "\"yambar -b wayland\""];
        };

        extraConfig = ''
          riverctl default-layout rivertile
          rivertile &
        '';
      };
    };
  };

  # control brightness
  programs.light.enable = true;

  # allow waylock to unlock computer after sleeping
  security.pam.services.waylock = {};

  services.pipewire = {
    enable = true;
    alsa.enable = true; # low level soundcard interface
    pulse.enable = true; # pulseaudio interface
  };
}
