{ pkgs, ... }:

{
  imports = [
    ./autostart.nix
    ./browser.nix
    ./direnv.nix
    ./editors.nix
    ./ffxiv.nix
    ./fish.nix
    ./git.nix
    ./music.nix
    ./nixpkgs.nix
    ./office.nix
    ./plasma
    ./ssh.nix
    ./terminal.nix
    ./utilities
    ./wm
  ];

  home = {
    username = "naptime";
    homeDirectory = "/home/naptime";

    # Specifies API compatibility version, do not change on Home Manager upgrade
    stateVersion = "24.05";
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "python3.11-youtube-dl-2021.12.17" ];
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    bash = {
      enable = true;
      initExtra = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };
  };
}
