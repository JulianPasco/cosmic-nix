{
  description = "Julian's NixOS COSMIC Desktop Configuration";

  inputs = {
    # Use NixOS 25.05 - COSMIC is now in nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Home Manager for user-level configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    
    # User configuration - loaded from generated file
    # This file is created by scripts/install.sh
    userConfig = import ./user-config.nix;

    # Common specialArgs passed to all modules
    specialArgs = {
      inherit inputs userConfig;
    };

    # Common modules for all hosts
    commonModules = [
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
