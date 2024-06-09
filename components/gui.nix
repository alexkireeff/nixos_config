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
    loginShellInit = ''[[ "$(tty)" == /dev/tty1 ]] && ${pkgs.river}/bin/river &; ${pkgs.yambar}/bin/yambar'';
    systemPackages = with pkgs; [
      pulseaudio
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
            command = "${pkgs.swaylock}/bin/swaylock";
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
          userChrome = builtins.readFile "${CD}/configs/firefox.config";
        };
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

            # TODO WIP
            # left = [
            #   river.anchors.base.map.conditions = {
            #     "id == 1".string.text = "1";
            #     "id == 2".string.text = "2";
            #     "id == 3".string.text = "3";
            #     "id == 4".string.text = "4";
            #     "id == 5".string.text = "5";
            #     "id == 6".string.text = "6";
            #     "id == 7".string.text = "7";
            #     "id == 8".string.text = "8";
            #     "id == 9".string.text = "9";
            #   };
            # ];

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
                # TODO onclick open nmtui
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
                      wheel-up = "pactl set-sink-volume @DEFAULT_SINK@ +1%"; # TODO max volume limit?
                      wheel-down = "pactl -- set-sink-volume @DEFAULT_SINK@ -1%";
                    };
                  };
                  conditions."sink_muted".string = {
                    text = "VOL {sink_percent}%";
                    foreground = "ff0000ff";
                    on-click = {
                      right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
                      wheel-up = "pactl set-sink-volume @DEFAULT_SINK@ +1%"; # TODO max volume limit?
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
                      wheel-up = ""; # TODO
                      wheel-down = ""; # TODO
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
