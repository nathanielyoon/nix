{ lib, pkgs, ... }@inputs:
{
  # NIX
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
    # Replace duplicate files with hard links to a single copy.
    auto-optimise-store = true;
    # Change location of Nix symlinks to reduce clutter in home directory.
    use-xdg-base-directories = true;
    # Ensure relative path literals start with `./` or `../`.
    warn-short-path-literals = true;
  };
  # Copy NixOS configuration file and link from resulting system.
  system.copySystemConfiguration = true;
  # DO NOT EDIT!
  system.stateVersion = "25.05";

  # IMPERMANENCE
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/fprint"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [ "/etc/machine-id" ];
  };

  # BOOT
  boot = {
    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Use tmpfs for /tmp.
    tmp.useTmpfs = true;
    # Set kernel modules.
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [ "kvm-amd" ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };
  # Set default host platform.
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # Inherit hardware configuration.
  imports = [ "${inputs.modulesPath}/installer/scan/not-detected.nix" ];
  swapDevices = [ ];
  hardware.cpu.amd.updateMicrocode = lib.mkDefault inputs.config.hardware.enableRedistributableFirmware;
  # Enable updater.
  services.fwupd.enable = true;
  # Enable some minor hardening.
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
  services.logrotate.enable = true;
  services.journald = {
    storage = "volatile";
    upload.enable = false;
  };

  # ENVIRONMENT
  environment.systemPackages = with pkgs; [
    # Required for managing the nix repository.
    inputs.helix.packages."${stdenv.hostPlatform.system}".helix
    git
    gh
    # For reading.
    man-pages
    man-pages-posix
    # NixOS helper.
    nh
  ];
  # Enable dynamic linking.
  programs.nix-ld.enable = true;
  # Set BASH prompt and completion.
  programs.bash = {
    promptInit = "PS1='\\W \\$ '";
    completion.enable = true;
    # Add documentation.
    documentation = {
      dev.enable = true;
      # Use mandoc instead of man-db.
      man = {
        man-db.enable = false;
        mandoc.enable = true;
      };
    };
    shellAliases = {
      "cd.." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "l" = "lsd --icon=never";
      "la" = "lsd --almost-all";
      "ll" = "lsd --long --almost-all";
      "lt" = "lsd --tree";
      "sc" = "systemctl";
    };
  };
  # Use auto-cpufreq to manage power.
  services.auto-cpufreq.enable = true;
  services.power-profiles-daemon.enable = false;

  # NETWORK
  networking.hostName = "fw";
  networking.useDHCP = lib.mkDefault true;
  # Configure NetworkManager.
  networking.networkmanager = {
    enable = true;
  };
  # Use systemd but reduce startup time.
  systemd.network = {
    enable = true;
    wait-online.enable = false;
  };
  networking.useNetworkd = true;
  systemd.services.systemd-user-sessions.enable = false;
  # Enable firewall.
  networking.firewall.enable = true;
  # Enable bluetooth.
  hardware.bluetooth.enable = true;

  # USERS
  users.mutableUsers = false;
  users.users.nathaniel = {
    isNormalUser = true;
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
    # Use generated password hash.
    hashedPassword = "$y$j9T$vUPrxkism.uCG9xvzQtgW/$.Mq9C2WCJi7uAgaOWVZ8vmgmVbtkL4MrraN8vRgGRa/";
  };
  # Make sudo easier.
  security.sudo.extraRules = [
    {
      users = [ "nathaniel" ];
      commands = [
        {
          command = "ALL";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];

  # LOCALE
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/New_York";
  # Add fonts.
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.zed-mono
      noto-fonts
      noto-fonts-monochrome-emoji
    ];
  };
  # Set console font.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # INPUT
  services.libinput.enable = true;
  # Swap escape and capslock.
  services.xserver.xkb.options = "caps:escape";
  console.useXkbConfig = true;
  # Enable fingerprint reader.
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };
  # Allow use of fingerprint reader driver despite its unfree-ness.
  nixpkgs.config.allowUnfreePredicate =
    pkg: builtins.elem (lib.getName pkg) [ "libfprint-2-tod1-goodix" ];
  # Enable fprintd service.
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.type = "simple";
  };
  # Enable udisks to manage external USB drives.
  services.udisks2.enable = true;
  # Enable clipboard monitor.
  services.ringboard.wayland.enable = true;

  # OUTPUT
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  # Allow pipewire to acquire realtime priority.
  security.rtkit.enable = true;
  # Allow fine-grained control of backlight level.
  boot.kernelParams = [ "amdgpu.dcdebugmask=0x40000" ];
  services.udev.extraRules = ''SUBSYSTEM=="backlight", ENV{ID_BACKLIGHT_CLAMP}="0"'';
  # Enable fan control package.
  hardware.fw-fanctrl.enable = true;
}
