{ ... }:

let
  # Constants for storage devices.
  mudkipBootDevice = "/dev/disk/by-label/MUDKIP_BOOT";
  mudkipEncryptedDevice = "/dev/disk/by-label/mudkip.luks";
  mudkipBtrfsDevice = "/dev/disk/by-label/mudkip.btrfs";
  storage1EncryptedDevice = "/dev/disk/by-label/storage1.luks";
  storage1BtrfsDevice = "/dev/disk/by-label/storage1.btrfs";
  storage2EncryptedDevice = "/dev/disk/by-label/storage2.luks";
  storage2BtrfsDevice = "/dev/disk/by-label/storage2.btrfs";

  # Convenience functions for specifying btrfs subvolume mounts.
  btrfsSubvolume =
    {
      device,
      subvolume,
      extraOptions ? [ ],
    }:
    {
      device = device;
      fsType = "btrfs";
      options = [ "subvol=${subvolume}" ] ++ extraOptions;
    };
  primarySubvolume =
    subvolume: extraOptions:
    btrfsSubvolume {
      device = mudkipBtrfsDevice;
      subvolume = subvolume;
      extraOptions = extraOptions;
    };
  storage1Subvolume =
    subvolume: extraOptions:
    btrfsSubvolume {
      device = storage1BtrfsDevice;
      subvolume = subvolume;
      # Since this storage is only used for media and not for critical system
      # components, we don't want to fail the boot if it fails to mount.
      extraOptions = extraOptions ++ [ "nofail" ];
    };
  storage2Subvolume =
    subvolume: extraOptions:
    btrfsSubvolume {
      device = storage2BtrfsDevice;
      subvolume = subvolume;
      extraOptions = extraOptions ++ [ "nofail" ];
    };

  mkSnapperConfig = mountPoint: {
    SUBVOLUME = mountPoint;
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 24 * 7;
    TIMELINE_LIMIT_DAILY = 14;
    TIMELINE_LIMIT_WEEKLY = 8;
    TIMELINE_LIMIT_MONTHLY = 12;
  };
in
{
  # Each encrypted device needs to be listed here so that it can be decrypted
  # on bootup.
  boot.initrd.luks.devices."mudkip".device = mudkipEncryptedDevice;
  boot.initrd.luks.devices."storage1".device = storage1EncryptedDevice;
  boot.initrd.luks.devices."storage2".device = storage2EncryptedDevice;

  fileSystems = {
    "/boot" = {
      device = mudkipBootDevice;
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    "/" = primarySubvolume "root" [ ];
    "/home" = primarySubvolume "home" [ ];
    "/nix" = primarySubvolume "nix" [ "noatime" ];

    # A properly developed game *should* keep all of its assets compressed on disc by default.
    # However, the game industry doesn't seem to see this as a priority (see, for example, the
    # massive data duplication present in the initial version of Helldivers 2), and there tends
    # to be a decent opportunity for space savings by applying compression to game files. The
    # default ZSTD configuration should be a good tradeoff.
    "/mnt/games" = storage1Subvolume "games" [ "compress=zstd" ];

    # Audiobooks and music generally use formats like FLAC that are difficult to compress any
    # further, so we don't bother with enabling ZSTD for them.
    "/mnt/music" = storage2Subvolume "music" [ ];
    "/mnt/audiobooks" = storage2Subvolume "audiobooks" [ ];
  };

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [
      "/"
      "/mnt/audiobooks"
      "/mnt/games"
      "/mnt/music"
    ];
  };
  services.snapper = {
    configs = {
      home = mkSnapperConfig "/home";

      audiobooks = mkSnapperConfig "/mnt/audiobooks";
      music = mkSnapperConfig "/mnt/music";
    };
    persistentTimer = true;
  };

  swapDevices = [ ];
}
