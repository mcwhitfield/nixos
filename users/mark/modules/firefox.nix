{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    {nixpkgs.overlays = [inputs.nur.overlay];}
  ];
  config = {
    programs.firefox = {
      enable = true;
      policies = {
        AppAutoUpdate = false;
        DisableSetDesktopBackground = true;
        DisplayBookmarksToolbar = true;
        DontCheckDefaultBrowser = true;
        EnableTrackingProtection = true;
        HardwareAcceleration = true;
        Homepage = {
          Locked = true;
          StartPage = "previous-session";
        };
        NetworkPrediciton = true;
        OfferToSaveLogins = false;
      };
      profiles.mark = {
        bookmarks = [
          {
            name = "GMail";
            keyword = "m";
            url = "https://mail.google.com";
          }
        ];

        containers = {
          Default = {
            id = 0;
            color = "toolbar";
          };
          "Google Account" = {
            id = 1;
            color = "blue";
            icon = "briefcase";
          };
        };

        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          clearurls
          decentraleyes
          privacy-badger
          ublock-origin
        ];

        id = 0;

        name = "Mark Whitfield";

        search = {
          default = "DuckDuckGo";
          force = true;
          engines = {
            Bing.metaData.hidden = true;
            eBay.metaData.hidden = true;
            Google.metaData.alias = "g";
            "Wikipedia (en)".metaData.alias = "wiki";

            Gmail = {
              urls = [{template = "https://mail.google.com/#search/{searchTerms}";}];
              definedAliases = ["m"];
            };
          };
        };

        settings = {
          gfx.webrender.all = true;
          media.ffmpeg.vaapi.enabled = true;
          reader.parse-on-load.force-enabled = true;
          widget.dmabuf.force-enabled = true;
        };
      };
    };
  };
}
