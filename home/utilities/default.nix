{ lib, pkgs, ... }:

let
  makeCustomScript =
    { name, runtimeInputs }:
    pkgs.writeShellApplication {
      name = name;
      runtimeInputs = runtimeInputs;
      text = builtins.readFile (./. + "/${name}.sh");
    };

  makeCustomScripts =
    attrset:
    lib.attrsets.mapAttrsToList (
      name: arguments: makeCustomScript (arguments // { name = name; })
    ) attrset;

  customScripts = makeCustomScripts {
    backup-bg3 = {
      runtimeInputs = [
        pkgs.coreutils
        pkgs.gnutar
      ];
    };
    checksum-music = {
      runtimeInputs = [
        pkgs.coreutils
        pkgs.findutils
        pkgs.python3Packages.tqdm
      ];
    };
    notes = {
      runtimeInputs = [
        pkgs.neovim
      ];
    };
    sync-music-to-ios = {
      runtimeInputs = [
        pkgs.coreutils
        pkgs.ifuse
        pkgs.rsync
      ];
    };
  };
in
{
  home.packages = customScripts ++ [
    # Like cat, but prettier
    pkgs.bat

    # Useful when configuring Konsole/&c.
    pkgs.foot

    # Querying language for JSON; useful for miscellaneous JSON tasks
    pkgs.jq

    # Progress Viewer, useful for inspecting miscellaneous byte stream operations
    pkgs.pv
    # Useful for running one-off scripts.
    # Pinned to 3.14 now since the default is 3.12; we can move to default
    # on future versions, or continue to pin newer versions.
    pkgs.python314
    # Like grep, but nicer :-)
    pkgs.ripgrep

    # Miscellaneous shell conveniences
    pkgs.tree
    pkgs.zip
    pkgs.unzip
    pkgs.htop

    # Various networking utilities
    pkgs.dig
    pkgs.whois

    # Webcam viewer for convenience
    pkgs.kdePackages.kamoso

    pkgs.zotero
  ];
}
