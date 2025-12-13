{ pkgs, config, ... }:
{
  # Enable librewolf browser.
  programs.librewolf.enable = true;
  xdg.desktopEntries.librewolf = {
    name = "LibreWolf";
    exec = "${pkgs.librewolf}/bin/librewolf";
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };
  };

  # Set librewolf-specific settings.
  programs.librewolf.settings = {
    "webgl.disabled" = false;
    "identity.fxaccounts.enabled" = true;
    "privacy.clearOnShutdown.history" = false;
    "privacy.clearOnShutdown.downloads" = true;
    "privacy.resistFingerprinting" = false;
    "privacy.fingerprintingProtection" = true;
    "privacy.fingerprintingProtection.overrides" = "+AllTargets,-JSDateTimeUTC";
  };

  programs.librewolf.policies = {
    # Nix handles this.
    AppAutoUpdate = false;
    ManualAppUpdateOnly = true;
    DisableSystemAddonUpdate = true;
    DontCheckDefaultBrowser = true;

    # Disable credential management.
    AutofillAddressEnabled = false;
    AutofillCreditCardEnabled = false;
    DisableMasterPasswordCreation = true;
    OfferToSaveLogins = false;
    PasswordManagerEnabled = false;
    PrimaryPassword = false;

    # Disable telemetry.
    DisableFeedbackCommands = true;
    DisableFirefoxStudies = true;
    DisableTelemetry = true;

    # Clear Firefox Home.
    FirefoxHome = {
      Search = false;
      TopSites = false;
      SponsoredTopSites = false;
      Highlights = false;
      Pocket = false;
      Stories = false;
      SponsoredPocket = false;
      SponsoredStories = false;
      Snippets = false;
    };

    # Disable features and integrations.
    DisableMenuBar = "never";
    DisablePocket = true;
    DisableProfileImport = true;
    DisableSetDesktopBackground = true;
    FirefoxSuggest = {
      WebSuggestions = true;
      SponsoredSuggestions = false;
      ImproveSuggest = false;
    };
    GenerativeAI.Enabled = false;
    NoDefaultBookmarks = true;
    ShowHomeButton = false;
    SkipTermsOfUse = true;
    UserMessaging = {
      WhatsNew = false;
      ExtensionRecommendations = false;
      FeatureRecommendations = false;
      UrlbarInterventions = false;
      SkipOnboarding = true;
      MoreFromMozilla = false;
      FirefoxLabs = false;
    };
    VisualSearchEnabled = false;

    # Enable features and integrations.
    SearchSuggestEnabled = true;
    HardwareAcceleration = true;
    NetworkPrediction = true;
    PostQuantumKeyAgreementEnabled = true;
    PrintingEnabled = true;

    # Set defaults.
    DefaultDownloadDirectory = "/home/nathaniel/use/downloads";
    DisplayBookmarksToolbar = "newtab";
    PromptForDownloadLocation = true;
    ExtensionUpdate = true;
    OverrideFirstRunPage = "";
    OverridePostUpdatePage = "";
    StartDownloadsInTempDirectory = true;

    # Enable tracking protection with exceptions.
    EnableTrackingProtection = {
      Value = true;
      Cryptomining = true;
      Fingerprinting = true;
      EmailTracking = true;
      SuspectedFingerprinting = true;
      BaselineExceptions = true;
      ConvenienceExceptions = true;
    };

    # Use HTTPS with exceptions.
    HttpAllowlist = [
      "http://localhost"
      "http://127.0.0.1"
      "http://0.0.0.0"
      "http://example.com"
    ];
    HttpsOnlyMode = "enabled";
  };
  programs.librewolf.policies.Preferences = {
    # Disable warning on `about:config` page.
    "browser.aboutConfig.showWarning" = false;
    # `Reject-all if possible, otherwise accept-all.`
    "cookiebanners.service.mode" = 2;
    "cookiebanners.service.mode.privateBrowsing" = 2;
    # Allow more caching.
    "browser.cache.disk.enable" = true;
    "browser.cache.disk.metadata_memory_limit" = 256 * 1024;
    "browser.cache.disk.smart_size.enabled" = true;
    "browser.cache.disk.preload_chunk_count" = 16;
    # Enable compact mode.
    "browser.compactmode.show" = true;
    "browser.uidensity" = 1;
    # Put tabs in titlebar.
    "browser.tabs.inTitleBar" = true;
    # Don't save zoom-in/out settings for a given site.
    "browser.zoom.siteSpecific" = false;
    # Disable new tab page.
    "browser.newtabpage.enabled" = false;
    # Keep scrollbars visible.
    "layout.testing.overlay-scrollbars.always-visible" = true;
    "widget.gtk.overlay-scrollbars.enabled" = false;
    # Use thinner scrollbar style (from Android).
    "widget.non-native-theme.scrollbar.style" = 3;
    # Allow `userChrome.css` customization.
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    # Turn off swipe for history back-and-forth.
    "widget.disable-swipe-tracker" = true;
    # Disable AI features.
    "browser.ml.enable" = false;
    "browser.ml.chat.enabled" = false;
    "browser.ml.chat.hideFromLabs" = true;
    "browser.ml.chat.hideLabsShortcuts" = true;
    "browser.ml.chat.page" = false;
    "browser.ml.chat.page.footerBadge" = false;
    "browser.ml.chat.page.menuBadge" = false;
    "browser.ml.chat.menu" = false;
    "browser.ml.linkPreview.enabled" = false;
    "browser.ml.pageAssist.enabled" = false;
    "browser.tabs.groups.smart.enabled" = false;
    "browser.tabs.groups.smart.userEnable" = false;
    "extensions.ml.enabled" = false;
    # Limit suggestions.
    "browser.urlbar.showSearchSuggestionsFirst" = false;
    "browser.urlbar.suggest.addons" = false;
    "browser.urlbar.suggest.amp" = false;
    "browser.urlbar.suggest.bookmark" = false;
    "browser.urlbar.suggest.engines" = false;
    "browser.urlbar.suggest.history" = false;
    "browser.urlbar.suggest.openpage" = false;
    "browser.urlbar.suggest.quickactions" = false;
    "browser.urlbar.suggest.topsites" = false;
    "browser.urlbar.suggest.trending" = false;
    "browser.urlbar.suggest.weather" = false;
    "browser.urlbar.suggest.yelp" = false;
    "browser.urlbar.suggest.yelpRealtime" = false;
    # Disable tab groups.
    "browser.tabs.groups.enabled" = false;
    # Disable some drag-and-drop interactions.
    "browser.tabs.dragDrop.pinInteractionCue.delayMS" = 600000;
    "browser.tabs.dragDrop.selectTab.delayMS" = 600000;
    # Disable tab hover preview.
    "browser.tabs.hoverPreview.enabled" = false;
    # Use better file picker.
    "widget.use-xdg-desktop-portal.file-picker" = true;
    # Only show bookmarks on new tab.
    "browser.toolbars.bookmarks.visibility" = "newtab";
    # Open tabs at the end.
    "browser.tabs.insertAfterCurrent" = false;
    "browser.tabs.insertRelatedAfterCurrent" = false;
    # Open files in `/tmp`.
    "browser.download.start_downloads_in_tmp_dir" = true;
    # Keep more history.
    "places.history.expiration.max_pages" = 2147483647;
    # Speed up network stuff.
    "network.prefetch-next" = true;
    "network.http.max-connections" = 2048;
    "network.http.max-persistent-connections-per-server" = 16;
  };

  # Configure profile.
  programs.librewolf.profiles.default = {
    search = {
      force = true;
      engines = {
        nixos-wiki = {
          name = "NixOS Wiki";
          urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
          iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
          definedAliases = [ "@nw" ];
        };
        league-of-legends-wiki = {
          name = "League of Legends Wiki";
          urls = [ { template = "https://wiki.leagueoflegends.com/en-us/?search={searchTerms}"; } ];
          iconMapObj."16" = "https://wiki.leagueoflegends.com/favicon.ico";
          definedAliases = [ "@lol" ];
        };
        scryfall = {
          name = "Scryfall";
          urls = [ { template = "https://scryfall.com/search?q={searchTerms}"; } ];
          iconMapObj."16" = "https://scryfall.com/favicon.ico";
          definedAliases = [ "@sf" ];
        };
        hn = {
          name = "Hacker News";
          urls = [ { template = "https://hn.algolia.com/?q={searchTerms}"; } ];
          iconMapObj."16" = "https://news.ycombinator.com/favicon.ico";
          definedAliases = [ "@hn" ];
        };
        google.metaData.hidden = true;
        bing.metaData.hidden = true;
        "policy-DuckDuckGo Lite".metaData.hidden = true;
        "policy-SearXNG - searx.be".metaData.hidden = true;
        "policy-MetaGer".metaData.hidden = true;
        "policy-StartPage".metaData.hidden = true;
        "policy-Mojeek".metaData.hidden = true;
      };
      default = "ddg";
      privateDefault = "ddg";
      order = [ "ddg" ];
    };
  };
  home.file.".librewolf/default/chrome/userChrome.css".source =
    config.lib.file.mkOutOfStoreSymlink "/home/nathaniel/nix/userChrome.css";
}
