{ pkgs, lib, ... }@inputs:
let
  enable =
    path: value:
    {
      enable = true;
    }
    // (if path == null then value else lib.setAttrByPath (lib.strings.splitString "." path) value);
in
{
  imports = [ inputs.niri.homeModules.niri ];
  home.packages = with pkgs; [
    # SYSTEM
    xdg-desktop-portal-gtk
    (writeShellScriptBin "bri" ''
      FILE=/sys/class/backlight/amdgpu_bl1/brightness
      PREV=$(<$FILE)
      case "$1" in
      "+") NEXT=$((PREV + 1285)) ;;
      "-") NEXT=$((PREV - 1285)) ;;
      "0") NEXT=0 ;;
      *) echo $PREV ;;
      esac
      if [[ $NEXT ]]; then sudo tee $FILE <<<"$NEXT"; fi
    '')
    (writeShellApplication {
      name = "vol";
      runtimeInputs = [ sd ];
      text = ''
        NUMBERISH='^([[:digit:]]+(\.[[:digit:]]+)|\.[[:digit:]]+)?[+-]$'
        if [[ "$1" =~ $NUMBERISH ]]; then wpctl set-volume @DEFAULT_AUDIO_SINK@ "$1"
        else
            case "$1" in
            "m") wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
            "M") wpctl set-mute @DEFAULT_AUDIO_SINK@ "1" ;;
            "U") wpctl set-mute @DEFAULT_AUDIO_SINK@ "0" ;;
            "+") wpctl set-volume @DEFAULT_AUDIO_SINK@ "0.1+" ;;
            "-") wpctl set-volume @DEFAULT_AUDIO_SINK@ "0.1-" ;;
            *) wpctl get-volume @DEFAULT_AUDIO_SINK@ | sd '^Volume: (\d+\.\d+)(?:( )\[(M)UTED\])?$' '$1$2$3' ;;
            esac
        fi
      '';
      excludeShellChecks = [ "SC2016" ];
    })
    (writeShellScriptBin "pwr" ''
      cat /sys/class/power_supply/BAT1/capacity
    '')
    (writeShellScriptBin "now" ''
      date "+%I:%M:%S"
    '')

    # SCRIPTS
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
    (writeShellScriptBin "rfc" ''
      FILE="$HOME/save/rfc/rfc$1.txt"
      if [[ -f "$FILE" ]]; then hx "$FILE"
      else printf "%s ??\n" "$FILE"; fi
    '')
    (writeShellScriptBin "minify" ''
      JS=$(esbuild --minify --bundle --format=esm "$@")
      printf "%s\nminify\t%u\ngzip\t%u\nbrotli\t%u\n" \
          "$JS" \
          "$(wc --bytes <<<"$JS")" \
          "$(gzip --best <<<"$JS" | wc --bytes)" \
          "$(brotli --best <<<"$JS" | wc --bytes)"
    '')
    (writeShellScriptBin "mp4" ''
      if [[ $# -ne 0 ]]; then exit 1; fi
      ffmpeg -i "$1" -codec copy "$2"
    '')

    # GIT
    git-filter-repo
    (writeShellScriptBin "gl" ''
      git log --oneline "$@"
    '')
    (writeShellScriptBin "gs" ''
      git status --oneline "$@"
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
      git add --all && git commit --message "$*" && git push
    '')

    # ENV
    xh
    deno
    nodejs_latest
    bun
    esbuild
    gcc
    glibc
    libcxx
    uv
    python3
    sqlite
    rustc
    cargo
    wrangler

    # DENO
    (writeShellScriptBin "dnr" ''
      if [[ $# -eq 0 ]]; then deno repl --allow-all --unstable-raw-imports
      else deno run --allow-all --unstable-raw-imports "$@"; fi
    '')
    (writeShellScriptBin "dnl" ''
      deno lint --permit-no-files --compact "$@"
    '')
    (writeShellScriptBin "dnb" ''
      deno bench --unstable-raw-imports --allow-all --no-check "$@"
    '')
    (writeShellScriptBin "dnt" ''
      deno test --allow-all --unstable-raw-imports --unstable-bundle --no-check --permit-no-files --doc --parallel "$@"
    '')
    (writeShellScriptBin "dnj" ''
      deno task --unstable-raw-imports --quiet --cwd=. "$@"
    '')

    # HELIX
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
  ];

  # HOME
  programs.home-manager.enable = true;
  home = {
    # Same state version.
    stateVersion = "25.05";
    # Configure user.
    username = "nathaniel";
    homeDirectory = "/home/nathaniel";
    # Use basic cursor icons.
    file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  };
  # Set wallpaper.
  services.wpaperd = enable "settings.default.path" "/home/nathaniel/save/pictures/wallpaper/2017-06-12T18_26_00_leo_on_table.jpg";
  xdg = {
    # Enable desktop portal.
    portal = enable "extraPortals" [ pkgs.xdg-desktop-portal-gtk ];
    # Create librewolf desktop entry.
    desktopEntries.librewolf = {
      name = "LibreWolf";
      exec = "${pkgs.librewolf}/bin/librewolf";
    };
    # Use librewolf as default application.
    mimeApps = enable "defaultApplications" {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };
    # Set user directories.
    userDirs = enable null {
      desktop = "$HOME";
      documents = "$HOME/save/documents";
      download = "$HOME/temp/downloads";
      music = "$HOME/save/music";
      pictures = "$HOME/save/pictures";
      publicShare = "$HOME/temp/public-share";
      templates = "$HOME/temp/templates";
      videos = "$HOME/save/videos";
    };
  };

  # BASH
  programs.bash = enable null {
    sessionVariables = {
      LESSHISTFILE = "-";
      HISTFILE = "$HOME/save/histfile";
      HISTSIZE = 1048576;
      HISTFILESIZE = 536870912;
      DENO_COVERAGE_DIR = "/tmp/deno-coverage";
    };
    shellOptions = [
      "autocd"
      "extglob"
      "globstar"
      "histappend"
      "histreedit"
      "histverify"
      "nullglob"
    ];
    initExtra = ''
      [[ -n "$PROMPT_COMMAND" ]] && PROMPT_COMMAND+="; history -a" || PROMPT_COMMAND="history -a"
      awk 'NR==FNR && !/^#/{lines[$0]=FNR;next} lines[$0]==FNR' "$HISTFILE" "$HISTFILE" >>"$HISTFILE.compressed" && mv --force "$HISTFILE.compressed" "$HISTFILE"

      _completion_loader lsd
      for command in l la ll lt; do
          complete -o bashdefault -o default -o nosort -F _lsd "$command"
      done
      _completion_loader systemctl
      complete -F _systemctl sc
    '';
  };

  # HELIX
  programs.helix = enable null {
    package = inputs.helix.packages."${pkgs.stdenv.hostPlatform.system}".helix;
    settings = {
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
    languages.language-server = {
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
            fileMatch = [
              "deno.json"
              "deno.jsonc"
            ];
            url = "https://raw.githubusercontent.com/denoland/deno/main/cli/schemas/config-file.v1.json";
          }
          {
            fileMatch = [
              "wrangler.json"
              "wrangler.jsonc"
            ];
            url = "https://unpkg.com/wrangler@latest/config-schema.json";
          }
        ];
      };
    };
    languages.language =
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
      ];
  };

  # GIT
  programs.git = enable "settings" {
    user = {
      name = "Nathaniel Yoon";
      email = "nathanielyoon.expire025@slmails.com";
    };
    init.defaultBranch = "main";
    push.autoSetupRemote = true;
    credential = {
      "https://github.com".helper = "!/run/current-system/sw/bin/gh auth git-credential";
      "https://gist.github.com".helper = "!/run/current-system/sw/bin/gh auth git-credential";
    };
    column.ui = "auto";
    commit.verbose = true;
    diff.algorithm = "histogram";
    help.autocorrect = "prompt";
  };
  programs.delta = enable null {
    enableGitIntegration = true;
    options = {
      features = "no-hunk-header";
      no-hunk-header.hunk-header-style = "omit";
    };
  };

  # UTILITIES
  programs = {
    bat = enable "config.style" "numbers";
    btop = enable "settings" {
      vim_keys = true;
      rounded_corners = false;
      update_ms = 1000;
      temp_scale = "fahrenheit";
      clock_format = "%X";
    };
    chromium = enable "commandLineArgs" [ "--ozone-platform-hint=auto" ];
    fd = enable null { };
    fzf = enable null {
      enableBashIntegration = true;
      defaultOptions = [ "--no-mouse" ];
    };
    jq = enable null { };
    lsd = enable null {
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
    mpv = enable null { };
    nix-search-tv = enable "settings.indexes" [
      "nixpkgs"
      "home-manager"
      "nixos"
    ];
    ripgrep = enable "arguments" [ "--smart-case" ];
    rtorrent = enable null { };
    tealdeer = enable "settings.updates.auto_update" true;
    yt-dlp = enable null { };
    zathura = enable "options.database" "sqlite";
  };

  # NIRI
  programs.niri = enable null {
    package = pkgs.niri-unstable;
    settings =
      let
        # Divisor of built-in display dimensions.
        unit = 47;
      in
      {
        # Disable hotkey overlay display.
        hotkey-overlay.skip-at-startup = true;
        # Keep power key on shutdown duty.
        input.power-key-handling.enable = false;
        environment = {
          # Set defaults.
          BROWSER = "librewolf";
          OFFICE = "libreoffice";
          # Set Wayland flags.
          QT_QPA_PLATFORM = "wayland";
          GDK_BACKEND = "wayland";
          SDL_VIDEODRIVER = "wayland";
          MOZ_ENABLE_WAYLAND = "1";
          NIXOS_OZONE_WL = "1";
        };
        spawn-at-startup = [
          {
            # Track clipboard history.
            command = [
              "wl-paste"
              "--watch"
              "ringboard"
              "add"
            ];
          }
        ];
        # Disable hot corners.
        gestures.hot-corners.enable = false;
        input = {
          # Configure keyboard.
          keyboard = {
            # Modify keyboard key-repeating.
            repeat-delay = 256;
            repeat-rate = 32;
            # Copy xkb options.
            xkb.options = "caps:escape";
          };
          touchpad = {
            # Disable touchpad while typing.
            dwt = true;
            # Scroll regularly.
            natural-scroll = false;
          };
        };
        # Keep empty workspace.
        layout.empty-workspace-above-first = true;
        # Maximize space.
        outputs."eDP-1".scale = 1.0;
        prefer-no-csd = true;
        layout = {
          focus-ring.enable = false;
          gaps = 0;
          tab-indicator = {
            place-within-column = true;
            gap = 0;
            length.total-proportion = 1.0;
          };
        };
        window-rules = [
          # Open some windows as floating.
          {
            matches = [ { app-id = "floating"; } ];
            open-floating = true;
          }
          # Fix terminal width.
          {
            matches = [ { app-id = "ghostty"; } ];
            default-column-width.fixed = unit * 19;
          }
          # Fix browser width.
          {
            matches = [ { app-id = "librewolf"; } ];
            default-column-width.fixed = unit * 22;
          }
        ];
      };
    binds = with inputs.config.lib.niri.actions; {
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

      "Shift+Mod+H".action = set-column-width "-${unit}";
      "Shift+Mod+L".action = set-column-width "+${unit}";
      "Shift+Mod+J".action = set-window-height "+${unit}";
      "Shift+Mod+K".action = set-window-height "-${unit}";

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

      "XF86AudioMute".action = spawn "vol" "m";
      "XF86AudioLowerVolume".action = spawn "vol" "-";
      "XF86AudioRaiseVolume".action = spawn "vol" "+";
      "Shift+XF86MonBrightnessDown".action = spawn "bri" "0";
      "XF86MonBrightnessDown".action = spawn "bri" "-";
      "XF86MonBrightnessUp".action = spawn "bri" "+";
    };
  };

  programs.ghostty = enable null {
    package = inputs.ghostty.packages."${pkgs.stdenv.hostPlatform.system}".default;
    enableBashIntegration = true;
    clearDefaultKeybinds = true;
    settings = {
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
      keybind = [
        "ctrl+zero=reset_font_size"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+plus=increase_font_size:1"
        "ctrl+equal=increase_font_size:1"

        "ctrl+shift+a=select_all"
        "shift+left=adjust_selection:left"
        "shift+right=adjust_selection:right"
        "shift+down=adjust_selection:down"
        "shift+up=adjust_selection:up"

        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"

        "ctrl+shift+i=inspector:toggle"

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

        "ctrl+alt+shift+semicolon=toggle_split_zoom"

        "ctrl+tab=next_tab"
        "ctrl+shift+t=new_tab"
        "ctrl+shift+tab=previous_tab"
        "ctrl+shift+w=close_tab"

        "ctrl+shift+semicolon=toggle_command_palette"
        "global:ctrl+super+space=toggle_quick_terminal"
      ];
    };
  };

  # LIBREWOLF
  programs.librewolf = enable null {
    settings = {
      "webgl.disabled" = false;
      "identity.fxaccounts.enabled" = true;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.downloads" = false;
      "privacy.resistFingerprinting" = false;
      "privacy.fingerprintingProtection" = true;
      "privacy.fingerprintingProtection.overrides" = "+AllTargets,-JSDateTimeUTC";
    };
    policies = {
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
  };
}
