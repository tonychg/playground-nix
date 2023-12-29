{
  description = "Basic NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
    };
    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs"; # override this repo's nixpkgs snapshot
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, flake-utils, ... }@inputs:
    let
      system = "x86_64-linux";
      overlays = [
        inputs.sops-nix.overlays.default
      ];
      defaultModules = [
        { _module.args = { inherit inputs; }; }
        inputs.sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
      mkPkgs = system:
        import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };
      mkSystem = extraModules:
        nixpkgs.lib.nixosSystem rec {
          inherit system;
          pkgs = mkPkgs system;
          modules = defaultModules ++ extraModules;
        };
      mkDeploy = deployment:
        {
          hostname = deployment.hostname;
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = inputs.deploy-rs.lib.${system}.activate.nixos
              self.nixosConfigurations.${deployment.config};
          };
        };
      pkgs = mkPkgs system;
    in
    {
      nixosConfigurations = {
        nixos = mkSystem [
          ./hosts/nixos/configuration.nix
        ];
        vm01 = mkSystem [
          ./hosts/vm01/configuration.nix
        ];
      };

      deploy.nodes = {
        nixos = mkDeploy {
          hostname = "192.168.122.238";
          config = "nixos";
        };
        vm01 = mkDeploy {
          hostname = "192.168.122.207";
          config = "vm01";
        };
      };

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        inputs.deploy-rs.lib;

      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            ssh-to-age
            sops
            go-task
          ];
        };
      };
    };
}
