{pkgs, ...}: {
  home.packages = [
    # Open source drum machine
    pkgs.hydrogen
    # Nice player for locally-stored files
    pkgs.lollypop
    # Open source Shazam client
    pkgs.songrec
    # Very handy tag editor that pulls in data from MusicBrainz; makes normalization
    # much easier
    pkgs.picard
  ];
}
