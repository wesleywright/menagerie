{inputs, ...}: {
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    settings = {
      download-buffer-size = 1073741824; # One gibibyte
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs.config = import ../nixpkgs-config.nix;
}
