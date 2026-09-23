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
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      allHosts = nixpkgs.lib.attrNames (builtins.readDir ./hosts);

      makeHostConfig =
        hostname:
        let
          optionalModule =
            name:
            let
              path = ./hosts/${hostname}/${name};
            in
            nixpkgs.lib.optional (builtins.pathExists path) path;
          optionsModules = [
            ./options
            ./hosts/${hostname}
          ];
          nixosModules = [ ./nixos ] ++ optionalModule "nixos";
          homeManagerImports = [ ./home ] ++ optionalModule "home";
          homeManagerModules = [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = optionsModules;
              home-manager.users.naptime = {
                imports = homeManagerImports;
              };
            }
          ];
        in
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            hostname = hostname;
          };

          modules = optionsModules ++ nixosModules ++ homeManagerModules;
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
        map (name: {
          name = name;
          value = makeHostConfig name;
        }) allHosts
      );
    };
}
