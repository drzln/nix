{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.blackmatter.components.desktop.chrome;

  preferences = {
    browser = {
      check_default_browser = false;
      custom_chrome_frame = true;
      enabled_labs_experiments = "reader-mode";
      window_placement = {
        bottom = 1070;
        left = "-8";
        maximized = false;
        right = 1920;
        top = "-8";
      };
    };
    distribution = {
      import_bookmarks = false;
      import_history = false;
      import_home_page = false;
      import_search_engine = false;
      make_chrome_default = false;
      suppress_first_run_bubble = true;
      suppress_first_run_default_browser_prompt = true;
      suppress_first_run_notification = true;
      suppress_first_run_toolbar_hint = true;
    };
    dns_prefetching = {
      enabled = false;
    };
    search = {
      default_search_provider_data = {
        favicon_url = "https://duckduckgo.com/favicon.ico";
        id = "-1";
        name = "SUPERPRIVATEBRO";
        prepopulated_id = -1;
        search_url = "https://duckduckgo.com/";
        template_url = "https://duckduckgo.com/?q={searchTerms}";
      };
      disable_search_geolocation = true;
    };
    sync_promo = {
      user_skipped = true;
    };
    webkit = {
      webprefs = {
        allow_displaying_insecure_content = false;
        default_fixed_font_size = 18;
        default_font_size = 18;
        dns_prefetching_enabled = false;
        enable_do_not_track = true;
        enable_spellchecking_service = false;
        enable_spellchecking = false;
        maximum_decoded_image_size = 16777216;
        minimum_font_size = 14;
        minimum_logical_font_size = 14;
        plugins = {
          plugins_list = [{
            enabled = false;
            name = "Chrome PDF Viewer";
            path = "/opt/google/chrome/libpdf.so";
          }];
        };
      };
    };
  };

in
{
  options = {
    blackmatter = {
      components = {
        desktop = {
          chrome = {
            enable = mkEnableOption " enable chrome";
          };
        };
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable)
      {
        programs.chromium.enable = true;
        programs.chromium.package = pkgs.ungoogled-chromium;
        # programs.chromium.package = pkgs.chromium.overrideAttrs (oldAttrs: {
        #   postInstall = ''
        #     echo '$(echo ${preferences} | jq -c .)' | tr -d '\n' > $out/Preferences
        #     chmod 600 $out/Preferences
        #     # Copy the modified "Preferences" file to the user's profile directory
        #     cp $out/Preferences $HOME/.config/google-chrome/Default/Preferences
        #   '';
        # });
        programs.chromium.extensions = [
          # nord theme
          { id = "honjmojpikfebagfakclmgbcchedenbo"; }
          # 1password
          { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; }
        ];
      })
  ];
}
