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
    pkgs.man-pages
    pkgs.man-pages-posix
  ];
  programs.niri.enable = true;
  environment.variables = {
    WEZTERM_CONFIG_FILE = "$HOME/nix/wezterm.lua";
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
      connection."wifi.powersave" = 2;
      device."wifi.iwd.autoconnect" = true;
    };
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/New_York";
  networking.firewall.enable = true;

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
    enable = true;
    completion.enable = true;
    promptInit = ''
      PS1='\W \$ '

      if [[ -n "$PROMPT_COMMAND" ]]; then PROMPT_COMMAND+="; history -a"
      else PROMPT_COMMAND="history -a"; fi
    '';
    shellAliases = {
      l = "lsd --icon=never";
      la = "lsd --almost-all";
      ll = "lsd --long";
      lla = "lsd --long --almost-all";
      lt = "lsd --tree";
      lta = "lsd --tree --almost-all";
      llt = "lsd --tree --long";
      llta = "lsd --tree --long --almost-all";
      sc = "systemctl";
      "cd.." = "cd ..";
    };
    interactiveShellInit = lib.mkAfter ''
      _completion_loader lsd
      complete -o bashdefault -o default -o nosort -F _lsd l la ll lla lt lta llt llta
      _completion_loader systemctl
      complete -F _systemctl sc
      . ${
        builtins.fetchurl {
          url = "https://raw.githubusercontent.com/wezterm/wezterm/refs/heads/main/assets/shell-integration/wezterm.sh";
          sha256 = "1b5rxq9lzqw5gf3islamgqwsilyiw9svhq51249lxgq72drq608r";
        }
      }
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

  # Enable some system services.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;
  programs.nix-ld.enable = true;
  hardware.bluetooth.enable = true;
  services.libinput.enable = true;
  hardware.fw-fanctrl.enable = true;
  services.udisks2.enable = true;

  # Enable (unfree) fingerprint reader.
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.type = "simple";
  };
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };
  nixpkgs.config.allowUnfreePredicate =
    pkg: builtins.elem (lib.getName pkg) [ "libfprint-2-tod1-goodix" ];

  # Allow fine-grained control of backlight level.
  boot.kernelParams = [ "amdgpu.dcdebugmask=0x40000" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="backlight", ENV{ID_BACKLIGHT_CLAMP}="0"
  '';

  # Enable documentation.
  documentation = {
    dev.enable = true;
    man = {
      man-db.enable = false;
      mandoc.enable = true;
      generateCaches = true;
    };
  };

  # Enable some basic hardening.
  services.logrotate.enable = true;
  services.journald = {
    storage = "volatile";
    upload.enable = false;
  };
  boot.kernel.sysctl = {
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.suid_dumpable" = false;
    "kernel.exec-shield" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.randomize_va_space" = 2;
    "kernel.sysrq" = 0;
    "net.core.default_qdisc" = "cake";
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.all.forwarding" = 0;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_rfc1337" = 1;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.forwarding" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "vm.mmap_rnd_bits" = 32;
  };
  users.groups.netdev = { };
  services.usbguard.enable = false;
  services.dbus.implementation = "broker";

  # Configure nix.
  system.stateVersion = "26.05";
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      use-xdg-base-directories = true;
      warn-dirty = false;
      download-buffer-size = 536870912;
      auto-optimise-store = true;
    };
  };
  programs.nh = {
    enable = true;
    flake = "/home/nathaniel/nix";
    clean = {
      enable = true;
      dates = "daily";
      extraArgs = "--keep 8 --optimise";
    };
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
