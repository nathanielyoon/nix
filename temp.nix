{ pkgs, config, ... }@inputs:
{
  home.packages = with pkgs; [
    vscode-langservers-extracted
    clang-tools
    marksman
    nil
    nixd
    bash-language-server
    shfmt
    taplo
    superhtml
    nixfmt-rfc-style
    typst
    tinymist
    typstyle
    ruff
    ty
    rust-analyzer
    rustfmt
    zls
    zig
    deno
    xh
  ];
  programs.helix.enable = true;
  programs.helix.settings = {
    theme = "base16_transparent";
    editor = {
      scrolloff = 0;
      scroll-lines = 1;
      line-number = "relative";
      idle-timeout = 0;
      completion-timeout = 0;
      completion-trigger-len = 0;
      completion-replace = true;
      auto-completion = true;
      color-modes = true;
      trim-final-newlines = true;
      jump-label-alphabet = "jfkdlsarueiwoqptynvmcxbz";
      end-of-line-diagnostics = "warning";
      gutters = [
        "line-numbers"
        "diff"
      ];
      soft-wrap.enable = true;
      inline-diagnostics.cursor-line = "warning";
    };
    editor.statusline = {
      left = [
        "total-line-numbers"
        "file-name"
        "read-only-indicator"
        "file-modification-indicator"
      ];
      center = [ "mode" ];
      right = [
        "diagnostics"
        "register"
        "selections"
        "primary-selection-length"
        "position"
      ];
    };
    editor.lsp = {
      auto-signature-help = false;
      display-inlay-hints = false;
    };
    editor.cursor-shape = {
      normal = "block";
      insert = "bar";
      select = "underline";
    };
    keys = {
      normal = {
        "C-v" = "signature_help";
        "Y" = "yank_joined";
        "H" = [
          "select_mode"
          "ensure_selections_forward"
          "flip_selections"
          "goto_first_nonwhitespace"
        ];
        "L" = [
          "select_mode"
          "ensure_selections_forward"
          "goto_line_end"
        ];
        "a" = [
          "append_mode"
          "collapse_selection"
        ];
        "i" = [
          "insert_mode"
          "collapse_selection"
        ];
        "~" = "switch_to_lowercase";
        "`" = "switch_case";
        "x" = "extend_line";
        "C-h" = ":toggle-option lsp.display-inlay-hints";
      };
      select = {
        "C-v" = "signature_help";
        "Y" = "yank_joined";
        "H" = [
          "ensure_selections_forward"
          "flip_selections"
          "goto_first_nonwhitespace"
        ];
        "L" = [
          "ensure_selections_forward"
          "goto_line_end"
        ];
        "a" = [
          "append_mode"
          "collapse_selection"
        ];
        "i" = [
          "insert_mode"
          "collapse_selection"
        ];
        "~" = "switch_to_lowercase";
        "`" = "switch_case";
        "x" = "extend_line";
        "C-h" = ":toggle-option lsp.display-inlay-hints";
      };
      insert = {
        "C-v" = "signature_help";
        "C-h" = ":toggle-option lsp.display-inlay-hints";
      };
    };
  };
  programs.helix.languages.language-server = {
    deno-lsp = {
      command = "deno";
      args = [ "lsp" ];
      environment.NO_COLOR = "1";
      config.deno = {
        enable = true;
        lint = false;
        unstable = true;
        maxTsServerMemory = 24576;
        cacheOnSave = true;
        disablePaths = [ "./dist" ];
        typescript.preferences = {
          useAliasesForRenames = false;
          importModuleSpecifierPreference = "project-relative";
          diagnostics.ignoredCodes = [
            2581
            2582
          ];
        };
      };
    };
    ruff = {
      command = "ruff";
      args = [ "server" ];
    };
    tinymist.command = "tinymist";
    superhtml = {
      commmand = "superhtml";
      args = [ "lsp" ];
    };
    nil = {
      command = "nil";
      config.nil.nix.flake.autoArchive = true;
    };
    nixd.command = "nixd";
    vscode-json = {
      command = "vscode-json-language-server";
      args = [ "--stdio" ];
      config.json.schemas = [
        {
          fileMatch = [ "deno.json" ];
          url = "https://raw.githubusercontent.com/denoland/deno/main/cli/schemas/config-file.v1.json";
        }
        {
          fileMatch = [ "wrangler.json" ];
          url = "https://unpkg.com/wrangler@latest/config-schema.json";
        }
      ];
    };
  };
  programs.helix.languages.language =
    let
      deno-fmt = extension: {
        command = "deno";
        args = [
          "fmt"
          "-"
          "--ext"
          extension
        ];
      };
    in
    [
      {
        name = "nix";
        formatter.command = "nixfmt";
        language-servers = [
          "nixd"
          "nil"
        ];
        auto-format = true;
      }
      {
        name = "bash";
        indent = {
          tab-width = 4;
          unit = "    ";
        };
        formatter = {
          command = "shfmt";
          args = [
            "-i"
            "4"
          ];
        };
        auto-format = true;
      }
      {
        name = "typst";
        language-servers = [ "tinymist" ];
        formatter = {
          command = "typstyle";
          args = [ "--wrap-text" ];
        };
        auto-format = true;
      }
      {
        name = "toml";
        formatter = {
          command = "taplo";
          args = [
            "fmt"
            "-"
          ];
        };
        auto-format = true;
      }
      {
        name = "html";
        language-servers = [ "superhtml" ];
        formatter = {
          command = "superhtml";
          args = [
            "fmt"
            "--stdin"
          ];
        };
        auto-format = true;
      }
      {
        name = "typescript";
        shebangs = [ "deno" ];
        roots = [
          "deno.json"
          "deno.jsonc"
          "package.json"
          "tsconfig.json"
        ];
        file-types = [
          "ts"
          "mts"
          "cts"
        ];
        language-servers = [ "deno-lsp" ];
        formatter = deno-fmt "ts";
        auto-format = true;
      }
      {
        name = "javascript";
        shebangs = [ "node" ];
        roots = [
          "deno.json"
          "deno.jsonc"
          "package.json"
          "tsconfig.json"
        ];
        file-types = [
          "js"
          "mjs"
          "cjs"
        ];
        language-servers = [ "deno-lsp" ];
        formatter = deno-fmt "js";
        auto-format = true;
      }
      {
        name = "json";
        formatter = deno-fmt "json";
        language-servers = [ "vscode-json" ];
        auto-format = true;
      }
      {
        name = "jsonc";
        scope = "source.json";
        injection-regex = "jsonc";
        file-types = [
          "jsonc"
          { glob = "{deno,bun}.lock"; }
        ];
        formatter = deno-fmt "jsonc";
        language-servers = [ "vscode-json" ];
        auto-format = true;
      }
      {
        name = "markdown";
        formatter = deno-fmt "md";
        language-servers = [ "marksman" ];
        auto-format = true;
      }
      {
        name = "css";
        formatter = deno-fmt "css";
        auto-format = true;
      }
      {
        name = "c";
        auto-format = true;
      }
      {
        name = "cpp";
        auto-format = true;
      }
      {
        name = "python";
        auto-format = true;
      }
    ];

  programs.ghostty.enable = true;
  programs.ghostty.enableBashIntegration = true;
  programs.ghostty.settings = {
    font-family = "ZedMono Nerd Font";
    font-feature = [
      "-calt"
      "-liga"
      "-dlig"
    ];
    background-opacity = 0.875;
    font-size = 15;
    cursor-style = "block";
    cursor-style-blink = false;
    cursor-click-to-move = true;
    confirm-close-surface = true;
    scrollback-limit = 16777216;
    window-decoration = "none";
    clipboard-read = "allow";
    clipboard-write = "allow";
    shell-integration-features = "no-cursor";
    window-inherit-working-directory = true;
    unfocused-split-opacity = 1;
    link-url = false;
    quick-terminal-autohide = false;
  };
  programs.ghostty.clearDefaultKeybinds = true;
  programs.ghostty.settings.keybind = [
    "ctrl+zero=reset_font_size"
    "ctrl+minus=decrease_font_size:1"
    "ctrl+plus=increase_font_size:1"
    "ctrl+equal=increase_font_size:1"

    "ctrl+shift+a=select_all"
    "ctrl+shift+c=copy_to_clipboard"
    "ctrl+shift+v=paste_from_clipboard"
    "ctrl+shift+i=inspector:toggle"
    "shift+left=adjust_selection:left"
    "shift+right=adjust_selection:right"
    "shift+down=adjust_selection:down"
    "shift+up=adjust_selection:up"

    "ctrl+shift+h=scroll_to_top"
    "ctrl+shift+l=scroll_to_bottom"
    "ctrl+shift+j=jump_to_prompt:1"
    "ctrl+shift+k=jump_to_prompt:-1"

    "alt+h=goto_split:left"
    "alt+l=goto_split:right"
    "alt+j=goto_split:down"
    "alt+k=goto_split:up"
    "alt+space=new_split:auto"
    "ctrl+alt+h=new_split:left"
    "ctrl+alt+l=new_split:right"
    "ctrl+alt+j=new_split:down"
    "ctrl+alt+k=new_split:up"
    "alt+shift+h=resize_split:left,10"
    "alt+shift+l=resize_split:right,10"
    "alt+shift+j=resize_split:down,10"
    "alt+shift+k=resize_split:up,10"

    "ctrl+tab=next_tab"
    "ctrl+shift+t=new_tab"
    "ctrl+shift+tab=previous_tab"
    "ctrl+shift+w=close_tab"

    "ctrl+shift+semicolon=toggle_command_palette"
    "ctrl+alt+shift+semicolon=toggle_split_zoom"

    "global:ctrl+super+space=toggle_quick_terminal"
  ];
  programs.librewolf = {
    enable = true;
    settings = {
      "webgl.disabled" = false;
      "identity.fxaccounts.enabled" = true;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.downloads" = false;
      "privacy.resistFingerprinting" = false;
      "privacy.fingerprintingProtection" = true;
      "privacy.fingerprintingProtection.overrides" = "+AllTargets,-JSDateTimeUTC";
    };
  };
  programs.librewolf.profiles.default = {
    search = {
      force = true;
      engines = {
        nix-packages = {
          name = "Nix Packages";
          urls = [ { template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; } ];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@np" ];
        };
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
  programs.librewolf.policies = {
    AutofillAddressEnabled = false;
    AutofillCreditCardEnabled = false;
    DefaultDownloadDirectory = "/home/nathaniel/temp/downloads";
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
    ExtensionSettings = {
      "uBlock0@raymondhill.net" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        private_browsing = true;
      };
      "{963aa3d4-c342-4dfe-872e-76be742d1bea}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4308468/youtube_disable_number_seek-1.4.xpi";
      };
      "idcac-pub@guus.ninja" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4216095/istilldontcareaboutcookies-1.1.4.xpi";
      };
      "myallychou@gmail.com" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4263531/youtube_recommended_videos-1.6.7.xpi";
      };
      "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4526031/old_reddit_redirect-2.0.9.xpi";
      };
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
      "browser.cache.disk.metadata_memory_limit" = 256 * 1024;
      "browser.cache.disk.free_space_soft_limit" = 1024 * 1024;
      "browser.cache.disk.free_space_hard_limit" = 1024 * 4096;
      "browser.cache.disk.preload_chunk_count" = 16;
      "browser.compactmode.show" = true;
      "browser.history.collectWireframes" = true;
      "browser.newtabpage.enabled" = false;
      "browser.taskbarTabs.enabled" = false;
      "cookiebanners.service.mode" = 2;
      "layout.testing.overlay-scrollbars.always-visible" = true;
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "widget.disable-swipe-tracker" = true;
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

  imports = [ inputs.niri.homeModules.niri ];
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri-unstable;
  programs.niri.settings = {
    environment = {
      QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      BROWSER = "librewolf";
      OFFICE = "libreoffice";
    };
    spawn-at-startup = [
      {
        command = [
          "wl-paste"
          "--watch"
          "cliphist"
          "store"
        ];
      }
    ];
    gestures.hot-corners.enable = false;
    hotkey-overlay.skip-at-startup = true;
    input = {
      workspace-auto-back-and-forth = true;
      keyboard = {
        repeat-delay = 250;
        repeat-rate = 40;
        xkb.options = "caps:escape_shifted_capslock";
      };
      power-key-handling.enable = false;
      touchpad.dwt = true;
      touchpad.natural-scroll = false;
    };
    layout = {
      empty-workspace-above-first = true;
      focus-ring.enable = false;
      gaps = 0;
      tab-indicator = {
        place-within-column = true;
        gap = 0;
        length.total-proportion = 1.0;
      };
    };
    outputs."eDP-1".scale = 1.0;
    prefer-no-csd = true;
    screenshot-path = "~/home/pictures/screenshots/%Y-%m-%dT%H:%M:%S.png";
    window-rules = [
      {
        matches = [ { app-id = "floating"; } ];
        open-floating = true;
      }
      {
        matches = [ { app-id = "ghostty"; } ];
        default-column-width.fixed = 893;
      }
      {
        matches = [ { app-id = "librewolf"; } ];
        default-column-width.fixed = 1034;
      }
    ];
  };
  programs.niri.settings.binds = with config.lib.niri.actions; {
    "Mod+Shift+E".action = quit { skip-confirmation = false; };
    "Mod+Tab".action = toggle-overview;

    "Mod+H".action = focus-column-or-monitor-left;
    "Mod+L".action = focus-column-or-monitor-right;
    "Mod+J".action = focus-window-down;
    "Mod+K".action = focus-window-up;

    "Ctrl+Mod+H".action = move-column-left-or-to-monitor-left;
    "Ctrl+Mod+L".action = move-column-right-or-to-monitor-right;
    "Ctrl+Mod+J".action = move-window-down-or-to-workspace-down;
    "Ctrl+Mod+K".action = move-window-up-or-to-workspace-up;

    "Shift+Mod+H".action = set-column-width "-47";
    "Shift+Mod+L".action = set-column-width "+47";
    "Shift+Mod+J".action = set-window-height "+47";
    "Shift+Mod+K".action = set-window-height "-47";

    "Ctrl+Shift+Mod+H".action = consume-or-expel-window-left;
    "Ctrl+Shift+Mod+L".action = consume-or-expel-window-right;
    "Ctrl+Shift+Mod+J".action = focus-workspace-down;
    "Ctrl+Shift+Mod+K".action = focus-workspace-up;

    "Mod+semicolon".action = switch-focus-between-floating-and-tiling;
    "Shift+Mod+semicolon".action = toggle-window-floating;
    "Ctrl+Mod+Semicolon".action = maximize-column;
    "Ctrl+Shift+Mod+Semicolon".action = fullscreen-window;

    "Mod+Space".action = spawn "ghostty";
    "Shift+Mod+Space".action = spawn "librewolf";
    "Ctrl+Shift+Mod+Space".action = close-window;

    "XF86AudioRaiseVolume".action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
    "XF86AudioLowerVolume".action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
    "XF86AudioMute".action = spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    "Shift+XF86MonBrightnessDown".action = spawn-sh "backlight \"* 0\"";
    "XF86MonBrightnessDown".action = spawn-sh "backlight \"- 1285\"";
    "XF86MonBrightnessUp".action = spawn-sh "backlight \"+ 1285\"";
    # "Print".action = screenshot { show-pointer = false; };
  };
}
