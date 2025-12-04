{
  # DISKS
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions.ESP = {
        priority = 1;
        name = "ESP";
        start = "1M";
        end = "128M";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          mountOptions = [ "umask=0077" ];
        };
      };
      partitions.root = {
        size = "100%";
        content = {
          type = "btrfs";
          extraArgs = [
            # Override existing partition.
            "-f"
            # Label partition.
            "-L"
            "nixos"
          ];
          subvolumes = {
            "/root" = {
              mountpoint = "/";
              mountOptions = [ "compress=zstd" ];
            };
            "/nix" = {
              mountpoint = "/nix";
              mountOptions = [ "compress=zstd" ];
            };
            "/persist" = {
              mountpoint = "/persist";
              mountOptions = [ "compress=zstd" ];
            };
          };
        };
      };
    };
  };
  fileSystems = {
    "/nix".neededForBoot = true;
    "/persist".neededForBoot = true;
  };
  swapDevices = [ ];

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
      "/var/lib/NetworkManager"
      "/etc/nixos"
    ];
    files = [ "/etc/machine-id" ];
    users.nathaniel = {
      directories = [
        "nix"
        "tmp"
        "all"
        ".ssh"
      ];
    };
  };

  # BOOT
  boot = {
    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
    };
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [ "kvm-amd" ];
    # Erase old volumes.
    initrd.postResumeCommands = {
      _type = "order";
      priority = 1500;
      content = ''
        mkdir /btrfs_tmp

        mount /dev/nvme0n1 /btrfs_tmp
        if [[ -e /btrfs_tmp/root ]]; then
            mkdir -p /btrfs_tmp/old_roots
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%dT%H:%M:%S")"
        fi

        delete_subvolume_recursively() {
            IFS=$'\n'
            for name in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "/btrfs_tmp/$name"
            done
            btrfs subvolume delete "$1"
        }
        for name in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
            delete_subvolume_recursively "$name"
        done

        btrfs subvolume create /btrfs_tmp/root
        umount /btrfs_tmp
      '';
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };
}
