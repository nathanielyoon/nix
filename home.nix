{ pkgs, lib, ... }@inputs:
let
  enable = path: value: { enable = true; } // lib.setAttrByPath path value;
in
{
  # Configure home-manager.
  programs.home-manager = enable [ ] { };
  home = {
    stateVersion = "25.11";
    username = "nathaniel";
    homeDirectory = "/home/nathaniel";
  };

  # Configure basic personalization.
  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
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

  # Enable browsers.
  programs.librewolf = enable [ ] { };
  programs.chromium = enable ["commandLineArgs"] [ "--ozone-platform-hint=auto" ];
}
