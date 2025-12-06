{ lib, pkgs, ... }@inputs:
{
  # Add system-wide packages.
  nixpkgs.overlays = [ inputs.zig.overlays.default ];
  environment.systemPackages = with pkgs; [
    git
    curl
    lsd
    ripgrep
    fd
    choose
    sd
    fzf
    helix
    zigpkgs.master
    zig-shell-completions
    wezterm
  ];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
  };
  programs.niri.enable = true;
  environment.variables = {
    WEZTERM_CONFIG_FILE = "$HOME/nix/wezterm.lua";
    MYVIMRC = "$HOME/nix/vim.lua";
    NIRI_CONFIG = "$HOME/nix/niri.kdl";
  };

  # Configure networking.
  networking.hostName = "fw";
  networking.useDHCP = lib.mkDefault true;
  networking.wireless.iwd.enable = true;
  # Set region for wifi. See <https://community.frame.work/t/42901/21>.
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=US
  '';
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
    settings = {
      wifi.powersave = 2;
    };
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Configure console.
  services.xserver.xkb.options = "caps:escape";
  console.useXkbConfig = true;
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.zed-mono
      noto-fonts
      noto-fonts-monochrome-emoji
    ];
  };
  programs.bash = {
    completion.enable = true;
    promptInit = ''
      PS1='\W \$ '
    '';
    shellAliases = {
      l = "lsd --icon=never";
      la = "lsd --almost-all";
      ll = "lsd --long";
      lt = "lsd --tree";
      sc = "systemctl";
    };
    interactiveShellInit = ''
      _completion_loader lsd
      for command in l la ll lt; do
          complete -o bashdefault -o default -o nosort -F _lsd "$command"
      done
      _completion_loader systemctl
      complete -F _systemctl sc
    '';
  };

  # Define user.
  users.mutableUsers = false;
  users.users.nathaniel = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$vUPrxkism.uCG9xvzQtgW/$.Mq9C2WCJi7uAgaOWVZ8vmgmVbtkL4MrraN8vRgGRa/";
    extraGroups = [
      # Allow sudo.
      "wheel"
      # Allow output configuration.
      "video"
      # Allow storage access.
      "storage"
      # Allow network configuration without sudo.
      "networkmanager"
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  # Allow fine-grained control of backlight level.
  boot.kernelParams = [ "amdgpu.dcdebugmask=0x40000" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="backlight", ENV{ID_BACKLIGHT_CLAMP}="0"
  '';

  # Configure nix.
  system.stateVersion = "25.11";
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      use-xdg-base-directories = true;
      warn-dirty = false;
    };
  };
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 10";
    };
    flake = "/home/nathaniel/nix";
  };

  # `hardware-configuration.nix`
  imports = [ "${inputs.modulesPath}/installer/scan/not-detected.nix" ];
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    # Enable external storage devices.
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault inputs.config.hardware.enableRedistributableFirmware;
}
