{ lib, pkgs, ... }@inputs:
{
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

  # Configure networking.
  networking.hostName = "fw";
  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=US
  '';
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
    curl
    helix
  ];

  # Swap escape/capslock, in console too.
  services.xserver.xkb.options = "caps:escape";
  console.useXkbConfig = true;

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
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault inputs.config.hardware.enableRedistributableFirmware;
}
