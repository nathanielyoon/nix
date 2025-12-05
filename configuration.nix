{ pkgs, lib, ... }@inputs:
{
  programs.niri.enable = true;

  # Configure nix itself.
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      # Replace duplicate files with hard links to a single copy.
      auto-optimise-store = true;
      # Change location of Nix symlinks to reduce clutter in home directory.
      use-xdg-base-directories = true;
    };
    # Clean up automatically.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than=14d";
    };
    optimise = {
      automatic = true;
      dates = "weekly";
      persistent = true;
    };
  };
  system.stateVersion = "26.05";

  # Configure networking.
  networking.hostName = "fw";
  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;
  # networking.networkmanager = {
  #   enable = true;
  #   wifi.backend = "iwd";
  # };
  # networking.wireless.iwd.enable = true;
  # networking.wireless.enable = true;

  # Set locale.
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
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Configure boot.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  services.fwupd.enable = true;
  services.logrotate.enable = true;
  services.journald = {
    storage = "volatile";
    upload.enable = false;
  };

  # Manage power.
  services.auto-cpufreq.enable = true;
  services.power-profiles-daemon.enable = false;
  hardware.fw-fanctrl.enable = true;

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

  # Add system-wide packages.
  environment.systemPackages = with pkgs; [
    git
    gh
    curl
    wget
    lsd
    helix
  ];

  # Configure bash.
  programs.bash = {
    enable = true;
    completion.enable = true;
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

  # Reduce startup time.
  # systemd.services = {
  #   systemd-user-sessions.enable = false;
  #   wait-online.enable = false;
  #   NetworkManager.wait-online.enable = false;
  #   systemd-udev-settle.enable = false;
  # };

  # Enable dynamic linking.
  programs.nix-ld.enable = true;

  # Enable bluetooth.
  hardware.bluetooth.enable = true;

  # Configure keyboard input.
  services.libinput.enable = true;
  # Swap escape/capslock, in console too.
  services.xserver.xkb.options = "caps:escape";
  console.useXkbConfig = true;

  # Enable (unfree) fingerprint reader.
  # systemd.services.fprintd = {
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig.type = "simple";
  # };
  # services.fprintd = {
  #   enable = true;
  #   tod = {
  #     enable = true;
  #     driver = pkgs.libfprint-2-tod1-goodix;
  #   };
  # };
  # nixpkgs.config.allowUnfreePredicate =
  #   pkg: builtins.elem (lib.getName pkg) [ "libfprint-2-tod1-goodix" ];

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # Allow fine-grained control of backlight level.
  boot.kernelParams = [ "amdgpu.dcdebugmask=0x40000" ];
  services.udev.extraRules = ''SUBSYSTEM=="backlight", ENV{ID_BACKLIGHT_CLAMP}="0"'';

  # `hardware-configuration.nix`
  imports = [ "${inputs.modulesPath}/installer/scan/not-detected.nix" ];
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    # Enable external storage devices.
    "usb_storage"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault inputs.config.hardware.enableRedistributableFirmware;
}
