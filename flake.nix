{
  description = "ArchibaldOS ARM Robust – Orange Pi 5";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    musnix.url = "github:musnix/musnix";
    musnix.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    nixos-rk3588.url = "github:gnull/nixos-rk3588";
    nixos-rk3588.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, flake-parts, nixpkgs, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      perSystem = { system, pkgs, ... }: let
        lib = pkgs.lib;

        board = builtins.getEnv "BOARD";
        targetBoard = if board != "" then board else "orange-pi-5";

        mkSystem = board: 
          let
            # Get the board module name
            boardName = 
              if board == "orange-pi-5" then "orangepi5"
              else if board == "orange-pi-5-plus" then "orangepi5plus"
              else if board == "orange-pi-5b" then "orangepi5b"
              else if board == "rock-5a" then "rock5a"
              else throw "Unsupported board: ${board}";
            
            # Get the board module attrset
            boardModule = inputs.nixos-rk3588.nixosModules.boards.${boardName};
            
            # Create pkgs for cross-compilation from x86_64 to aarch64
            targetPkgs = import inputs.nixpkgs {
              system = system;  # Build system (x86_64-linux)
              crossSystem = lib.systems.elaborate "aarch64-linux";
            };
          in
          nixpkgs.lib.nixosSystem {
            # Target ARM64
            system = "aarch64-linux";
            specialArgs = { 
              inherit inputs board;
              # Provide the full rk3588 argument that the modules expect
              rk3588 = {
                nixpkgs = inputs.nixpkgs;
                pkgs = targetPkgs;
                pkgsKernel = targetPkgs;
              } // inputs.nixos-rk3588.packages.${system};
            };
            modules = [
              # Import the core board configuration
              boardModule.core
              
              # Import the SD image format
              boardModule.sd-image

              # Enable cross-compilation
              ({ config, lib, ... }: {
                nixpkgs.buildPlatform = system;
                nixpkgs.hostPlatform = "aarch64-linux";
              })

              ./configuration.nix
              inputs.musnix.nixosModules.musnix
              inputs.hyprland.nixosModules.default

              # Load our custom hardware config if it exists
              (if builtins.pathExists (./hardware + "/${board}.nix")
               then import (./hardware + "/${board}.nix")
               else { })

              # Override SD image settings
              ({ config, lib, ... }: {
                sdImage = {
                  imageName = lib.mkForce "archibaldos-${board}.img";
                  compressImage = lib.mkDefault true;
                };
              })
            ];
          };

        built = mkSystem targetBoard;

      in {
        # Main package: SD card image
        packages.default = built.config.system.build.sdImage;
        
        # Also expose the raw system for debugging
        packages.system = built.config.system.build.toplevel;
      };
    };
}
