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
        xwayland.enable = false;
        extraConfig = builtins.readFile ./configs/river.config;
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
