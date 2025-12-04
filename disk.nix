{
  disko.devices.disk.main = {
    device = "/dev/nvme0n1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "zroot";
          };
        };
      };
    };
  };
  disko.devices.zpool.zroot = {
    type = "zpool";
    rootFsOptions = {
      # https://wiki.archlinux.org/title/Install_Arch_Linux_on_ZFS
      acltype = "posixacl";
      atime = "on";
      relatime = "on";
      compression = "lz4";
      mountpoint = "none";
      xattr = "sa";
    };
    options.ashift = "12";

    datasets = {
      "local" = {
        type = "zfs_fs";
        options.mountpoint = "none";
      };
      "local/nix" = {
        type = "zfs_fs";
        mountpoint = "/nix";
        options."com.sun:auto-snapshot" = "false";
      };
      "local/persist" = {
        type = "zfs_fs";
        mountpoint = "/persist";
        options."com.sun:auto-snapshot" = "false";
      };
      "local/root" = {
        type = "zfs_fs";
        mountpoint = "/";
        options."com.sun:auto-snapshot" = "false";
        # Create a blank snapshot.
        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot/local/root@blank$' || zfs snapshot zroot/local/root@blank";
      };
    };
  };
}
