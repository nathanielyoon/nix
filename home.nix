{ pkgs, lib, ... }:
let
  enable = path: value: { enable = true; } // lib.setAttrByPath path value;
in
{
  imports = [ ./temp.nix ];
  # Configure home-manager.
  programs.home-manager = enable [ ] { };
  home = {
    stateVersion = "26.05";
    username = "nathaniel";
    homeDirectory = "/home/nathaniel";
  };

  # Include packages and scripts.
  home.packages = with pkgs; [
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
  ];

  # Enable utility programs.
  programs.bat = enable [ "config" "style" ] "numbers";
  programs.btop = enable [ "settings" ] {
    vim_keys = true;
    rounded_corners = false;
    update_ms = 1000;
    temp_scale = "fahrenheit";
    clock_format = "%X";
  };
  programs.chromium = enable [ "commandLineArgs" ] [ "--ozone-platform-hint=auto" ];
  programs.fd = enable [ ] { };
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

  # Configure basic personalization.
  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  xdg.userDirs = enable [ ] {
    desktop = "$HOME/all";
    documents = "$HOME/all/documents";
    download = "$HOME/all/downloads";
    music = "$HOME/all/music";
    pictures = "$HOME/all/pictures";
    publicShare = "$HOME/all/public-share";
    templates = "$HOME/all/templates";
    videos = "$HOME/save/videos";
  };

  # Configure bash.
  programs.bash = enable [ ] {
    sessionVariables = {
      LESSHISTFILE = "-";
      HISTFILE = "$HOME/all/histfile";
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
  };

  # Configure git.
  programs.git = enable [ "settings" ] {
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
  programs.delta = enable [ ] {
    enableGitIntegration = true;
    options = {
      features = "no-hunk-header";
      no-hunk-header.hunk-header-style = "omit";
    };
  };
}
