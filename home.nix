{ pkgs, lib, ... }:
let
  enable = path: value: { enable = true; } // lib.setAttrByPath path value;
in
{
  # Import other home configuration.
  imports = [
    ./browser.nix
    ./editor.nix
  ];

  # Add packages.
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
    wl-clipboard
    (writeShellScriptBin "unclip" ''
      cliphist list | fzf --no-sort | xargs -r cliphist decode | wl-copy
    '')
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
    hunspell
    hunspellDicts.en_US-large
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
  services.cliphist = enable [ "extraOptions" ] [ "-max-items" "16777216" ];
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
    historyControl = [
      "ignoreboth"
      "erasedups"
    ];
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
    # Limit pdf command to file extensions compatible with `mupdf` as per
    # <https://wiki.archlinux.org/title/Zathura>.
    initExtra = ''
      _pdf() {
          _init_completion || return
          _filedir '@(pdf|epub|xps)'
      }
      complete -F _pdf pdf
    '';
  };
  programs.readline = enable [ ] {
    bindings = {
      "\\C-p" = "history-search-backward";
      "\\C-n" = "history-search-forward";
    };
    variables = {
      blink-matching-paren = true;
      colored-stats = true;
      mark-symlinked-directories = true;
      match-hidden-files = false;
      page-completions = false;
      show-all-if-ambiguous = true;
      show-all-if-unmodified = true;
    };
  };

  # Configure git.
  programs.git = enable [ "settings" ] {
    user = {
      name = "Nathaniel Yoon";
      email = "nathanielyoon.expire025@slmails.com";
      useConfigOnly = true;
    };
    column.ui = "auto";
    commit.verbose = true;
    diff.algorithm = "minimal";
    fetch.parallel = 0;
    fetch.prune = true;
    help.autocorrect = "prompt";
    init.defaultBranch = "main";
    log.follow = true;
    push.autoSetupRemote = true;
    status.showStash = true;
  };
  programs.delta = enable [ ] {
    enableGitIntegration = true;
    options = {
      features = "no-hunk-header";
      no-hunk-header.hunk-header-style = "omit";
    };
  };
  programs.gh = enable [ ] {
    gitCredentialHelper.enable = true;
    settings.git_protocol = "ssh";
  };

  # Configure desktop.
  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  services.wpaperd = enable [ "settings" "default" "path" ] "/home/nathaniel/all/pictures/leo.jpeg";
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
