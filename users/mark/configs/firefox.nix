{
  config,
  nur,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  extensions = with config.nur.repos.rycee.firefox-addons; {
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = bitwarden;
    "{74145f27-f039-47ce-a470-a662b129930a}" = clearurls;
    "addon@darkreader.org" = darkreader;
    "jid1-BoFifL9Vbdl2zQ@jetpack" = decentraleyes;
    "jid1-MnnxcxisBPnSXQ@jetpack" = privacy-badger;
    "uBlock0@raymondhill.net" = ublock-origin;
    "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = vimium;
  };
  configDir = "${config.home.homeDirectory}/.mozilla";
in {
  imports = [
    nur.hmModules.nur
  ];
  config = {
    home.persistDirs = [configDir];
    xdg.configFile."mozilla".source = mkOutOfStoreSymlink configDir;
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

        id = 0;

        name = "Mark Whitfield";

        extensions = builtins.attrValues extensions;

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
          "gfx.webrender.all" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "reader.parse-on-load.force-enabled" = true;
          "widget.dmabuf.force-enabled" = true;
        };
      };
    };
  };
}
