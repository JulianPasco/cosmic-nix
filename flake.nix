{
  description = "Julian's NixOS COSMIC Desktop Configuration";

  inputs = {
    # Use latest nixpkgs unstable for COSMIC
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # COSMIC desktop flake - use latest
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager for user-level configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Additional COSMIC applets (currently disabled due to build issues)
    cosmic-applets-collection = {
      url = "github:wingej0/ext-cosmic-applets-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-cosmic, home-manager, cosmic-applets-collection, ... }@inputs:
  let
    system = "x86_64-linux";
    
    # User configuration - loaded from generated file
    # This file is created by scripts/install.sh
    userConfig = import ./user-config.nix;

    # Common specialArgs passed to all modules
    specialArgs = {
      inherit inputs userConfig;
      inherit (inputs) cosmic-applets-collection;
    };

    # Common modules for all hosts
    commonModules = [
      # COSMIC desktop module
      nixos-cosmic.nixosModules.default
      
      # Home Manager integration
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = specialArgs;
          users.${userConfig.username} = import ./modules/user.nix;
        };
      }
      
      # Common system configuration
      ./modules/common.nix
      ./modules/cosmic.nix
    ];
  in
  {
    nixosConfigurations = {
      # Work machine configuration
      work = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = commonModules ++ [
          ./hosts/work.nix
          ./hosts/hardware-work.nix
        ];
      };

      # Home machine configuration
      home = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = commonModules ++ [
          ./hosts/home.nix
          ./hosts/hardware-home.nix
        ];
      };
    };
  };
}
