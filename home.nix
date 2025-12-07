{ pkgs, lib, ... }:
let
  enable = path: value: { enable = true; } // lib.setAttrByPath path value;
in
{
  # Configure desktop and utilities.
  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  home.packages = with pkgs; [
    mako
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    (writeShellApplication {
      name = "vol";
      runtimeInputs = [ sd ];
      text = ''
        NUMBERISH='^([[:digit:]]+(\.[[:digit:]]+)|\.[[:digit:]]+)[+-]$'
        if [[ $# -eq 0 ]]; then wpctl get-volume @DEFAULT_AUDIO_SINK@ | sd '^Volume: (\d+\.\d+)(?:( )\[(M)UTED\])?$' '$1$2$3'
        elif [[ "$1" =~ $NUMBERISH ]]; then wpctl set-volume @DEFAULT_AUDIO_SINK@ "$1"
        else
            case "$1" in
            "m") wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
            "M") wpctl set-mute @DEFAULT_AUDIO_SINK@ "1" ;;
            "U") wpctl set-mute @DEFAULT_AUDIO_SINK@ "0" ;;
            "+") wpctl set-volume @DEFAULT_AUDIO_SINK@ "0.1+" ;;
            "-") wpctl set-volume @DEFAULT_AUDIO_SINK@ "0.1-" ;;
            esac
        fi
      '';
      excludeShellChecks = [ "SC2016" ];
    })
    (writeShellScriptBin "bri" ''
      FILE=/sys/class/backlight/amdgpu_bl1/brightness
      PREV=$(<$FILE)
      NUMERIC='^[0-9]{1,5}$'
      if [[ $# -eq 0 ]]; then echo $PREV
      elif [[ "$1" =~ $NUMERIC ]]; then NEXT=$1
      else
        case "$1" in
        "+") NEXT=$((PREV + 1285)) ;;
        "-") NEXT=$((PREV - 1285)) ;;
        esac
      fi
      if [[ $NEXT =~ $NUMERIC ]]; then sudo tee $FILE <<<"$NEXT"; fi
    '')
    (writeShellScriptBin "pwr" ''
      cat /sys/class/power_supply/BAT1/capacity
    '')
    (writeShellScriptBin "now" ''
      date "+%I:%M:%S"
    '')
    trashy
    (writeShellScriptBin "tp" ''
      for file; do trash put "$file"; done
    '')
    (writeShellScriptBin "pt" ''
      RANGES=$(trash --color=always list | tac | fzf --multi --ansi | cut -d' ' -f2)
      [[ -n $RANGES ]] && trash restore --ranges "$RANGES"
    '')
    wl-clipboard
    (writeShellScriptBin "pdf" ''
      for file; do zathura "$file" 2>/dev/null & disown; done
    '')
    (writeShellScriptBin "ascii" ''
      printf "$(printf '\\x%x ' {32..126})\n" | fold --width=32
    '')
    (writeShellScriptBin "ns" ''
      nix-search-tv print | fzf \
          --preview='nix-search-tv preview {}' \
          --bind='ctrl-a:execute(nix-search-tv homepage {} | xargs xdg-open)' \
          --bind='ctrl-s:execute(nix-search-tv source {} | xargs xdg-open)' \
          --layout=reverse \
          --preview-window="wrap$(if [[ "$(tput cols)" -lt 90 ]]; then printf ",up"; fi)" \
          --header "open: homep[a]ge [s]ource" \
          --header-first
    '')
    clac
    libqalculate
    ffmpeg
    libreoffice-still
    mupdf-headless
    dust
    zip
    unzip
    brotli
    xan
    pulsemixer
    wf-recorder
    wev
    pandoc
    xh
    git-filter-repo
    (writeShellScriptBin "gl" ''
      git log --oneline "$@"
    '')
    (writeShellScriptBin "gs" ''
      git status --short "$@"
    '')
    (writeShellScriptBin "gd" ''
      git diff "$@"
    '')
    (writeShellScriptBin "ga" ''
      if [[ $# -eq 0 ]]; then git add --all
      else git add "$@"; fi
    '')
    (writeShellScriptBin "gc" ''
      if [[ $# -eq 0 ]]; then git commit
      else git commit --message "$*"; fi
    '')
    (writeShellScriptBin "gp" ''
      git push --quiet "$@"
    '')
    (writeShellScriptBin "gacp" ''
      if [[ $# -eq 0 ]]; then exit 1; fi
      git add --all
      git commit --message "$*"
      git push --quiet
    '')
    deno
    nodejs_latest
    bun
    esbuild
    gcc
    glibc
    libcxx
    python3
    sqlite
    rustc
    cargo
    (writeShellScriptBin "dnr" ''
      if [[ $# -eq 0 ]]; then deno repl --allow-all --unstable-raw-imports
      else deno run --allow-all --unstable-raw-imports "$@"; fi
    '')
    (writeShellScriptBin "dnl" ''
      deno lint --permit-no-files --compact "$@"
    '')
    (writeShellScriptBin "dnb" ''
      deno bench --unstable-raw-imports --unstable-bundle --unstable-tsgo --allow-all --no-check "$@"
    '')
    (writeShellScriptBin "dnt" ''
      deno test --allow-all --unstable-raw-imports --unstable-bundle --unstable-tsgo --no-check --permit-no-files --doc --parallel "$@"
    '')
    (writeShellScriptBin "dnj" ''
      deno task --unstable-raw-imports --unstable-bundle --unstable-tsgo --quiet --cwd=. "$@"
    '')
    clang-tools
    marksman
    nil
    nixd
    bash-language-server
    shfmt
    taplo
    superhtml
    typst
    tinymist
    typstyle
    ruff
    ty
    rust-analyzer
    rustfmt
    zls
    kdlfmt
    (writeShellScriptBin "minify" ''
      JS=$(esbuild --minify --bundle --format=esm "$@")
      printf "%s\n" "$JS"
      printf "minify\t%u\ngzip\t%u\nbrotli\t%u\n" \
          "$(wc --bytes <<<"$JS")" \
          "$(gzip --best <<<"$JS" | wc --bytes)" \
          "$(brotli --best <<<"$JS" | wc --bytes)"
    '')
  ];
  programs.bat = enable [ "config" "style" ] "numbers";
  programs.btop = enable [ "settings" ] {
    vim_keys = true;
    rounded_corners = false;
    update_ms = 1000;
    temp_scale = "fahrenheit";
    clock_format = "%X";
  };
  programs.chromium = enable [ "commandLineArgs" ] [ "--ozone-platform-hint=auto" ];
  programs.fd = enable [ ] {
    hidden = true;
    ignores = [ ".git/" ];
  };
  programs.fzf = enable [ ] {
    enableBashIntegration = true;
    defaultOptions = [ "--no-mouse" ];
  };
  programs.jq = enable [ ] { };
  programs.lsd = enable [ ] {
    enableBashIntegration = false;
    settings = {
      blocks = [
        "date"
        "permission"
        "size"
        "name"
      ];
      icons.separator = "  ";
      sorting.dir-grouping = "first";
    };
  };
  programs.mpv = enable [ ] { };
  programs.nix-search-tv = enable [ "settings" ] {
    indexes = [
      "nixpkgs"
      "home-manager"
      "nixos"
    ];
  };
  programs.ripgrep = enable [ "arguments" ] [ "--smart-case" ];
  programs.rtorrent = enable [ ] { };
  programs.tealdeer = enable [ "settings" "updates" "auto_update" ] true;
  programs.yt-dlp = enable [ ] { };
  programs.zathura = enable [ "options" "database" ] "sqlite";

  # Configure bash.
  programs.bash = enable [ ] {
    historyFile = "$HOME/all/histfile";
    historyControl = [ "ignoreboth" "erasedups" ];
    historyFileSize = 536870912;
    historySize = 1048576;
    sessionVariables = {
      LESSHISTFILE = "-";
    };
    shellOptions = [
      "autocd"
      "extglob"
      "globstar"
      "histappend"
      "histverify"
      "lithist"
      "nullglob"
    ];
  };

  # Configure git.
  programs.git = enable [ "settings" ] {
    user = {
      name = "Nathaniel Yoon";
      email = "nathanielyoon.expire025@slmails.com";
    };
    init.defaultBranch = "main";
    push.autoSetupRemote = true;
    column.ui = "auto";
    commit.verbose = true;
    diff.algorithm = "histogram";
    help.autocorrect = "prompt";
  };
  programs.delta = enable [ ] {
    enableGitIntegration = true;
    options = {
      features = "no-hunk-header";
      no-hunk-header.hunk-header-style = "omit";
    };
  };

  # Configure browser.
  programs.librewolf = enable [ ] {
    settings = {
      "webgl.disabled" = false;
      "identity.fxaccounts.enabled" = true;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.downloads" = true;
      "privacy.resistFingerprinting" = false;
      "privacy.fingerprintingProtection" = true;
      "privacy.fingerprintingProtection.overrides" = "+AllTargets,-JSDateTimeUTC";
    };
    profiles.default = {
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
      userChrome = builtins.readFile ./userChrome.css;
    };
    policies = {
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DefaultDownloadDirectory = "/home/nathaniel/all/downloads";
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisableMasterPasswordCreation = true;
      DisablePocket = true;
      DisableProfileImport = true;
      DisableTelemetry = true;
      DisplayBookmarksToolbar = "newtab";
      DontCheckDefaultBrowser = true;
      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
      };
      ExtensionUpdate = true;
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
      FirefoxSuggest = {
        WebSuggestions = true;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };
      HardwareAcceleration = true;
      HttpAllowList = [
        "http://localhost"
        "http://127.0.0.1"
        "http://0.0.0.0"
        "http://example.com"
      ];
      HttpsOnlyMode = "enabled";
      ManualAppUpdateOnly = true;
      OfferToSaveLogins = false;
      NetworkPrediction = true;
      NoDefaultBookmarks = true;
      PasswordManagerEnabled = false;
      PostQuantumKeyAgreementEnabled = true;
      Preferences = {
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
      PrimaryPassword = false;
      PrintingEnabled = true;
      PromptForDownloadLocation = true;
      SearchSuggestEnabled = true;
      ShowHomeButton = false;
      SkipTermsOfUse = true;
      UserMessaging = {
        WhatsNew = false;
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = false;
        MoreFromMozilla = false;
      };
    };
  };
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

  # Move XDG directories.
  xdg.userDirs = enable [ ] {
    desktop = "$HOME/all/Desktop";
    documents = "$HOME/all/Desktop/documents";
    download = "$HOME/all/downloads";
    music = "$HOME/all/Desktop/music";
    pictures = "$HOME/all/Desktop/pictures";
    publicShare = "$HOME/all/Desktop/public-share";
    templates = "$HOME/all/Desktop/templates";
    videos = "$HOME/save/Desktop/videos";
  };

  # Configure home-manager.
  programs.home-manager = enable [ ] { };
  home = {
    stateVersion = "25.11";
    username = "nathaniel";
    homeDirectory = "/home/nathaniel";
  };
}
