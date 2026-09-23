{
  description = "mudkip system configuration files";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager/trunk";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      plasma-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      allHosts = nixpkgs.lib.attrNames (builtins.readDir ./nixos/per-host);
      makeHostConfig =
        name:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./nixos/base-configuration
            ./nixos/per-host/${name}
            (
              { ... }:
              {
                networking.hostName = name;
              }
            )

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
              home-manager.users.naptime = import ./home/home.nix;
            }
          ];
        };
    in
    {
      devShell.${system} = pkgs.mkShell {
        packages = [
          # Provides a Nix LSP implementation.
          pkgs.nixd

          # Autoformats Nix files.
          pkgs.nixfmt
        ];
      };

      nixosConfigurations = builtins.listToAttrs (
        builtins.map (name: {
          name = name;
          value = makeHostConfig name;
        }) allHosts
      );
    };
}
