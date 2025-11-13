{
  description = "Lean RT Audio ArchibaldOS: Minimal Oligarchy NixOS variant for real-time audio with Musnix, Plasma KDE (ARM64 version)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    musnix.url = "github:musnix/musnix";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, musnix, disko }: let
    system-x86 = "x86_64-linux";
    system-arm = "aarch64-linux";
    pkgs-x86 = import nixpkgs {
      system = system-x86;
      config.allowUnfree = true;
    };
    pkgs-arm = import nixpkgs {
      system = system-arm;
      config.allowUnfree = true;
    };

    wallpaperSrc = ./modules/assets/wallpaper.jpg;

  in {
    nixosConfigurations = {
      # Original x86 configuration (unchanged)
      archibaldOS = nixpkgs.lib.nixosSystem {
        system = system-x86;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
          musnix.nixosModules.musnix
          ./modules/audio.nix
          ./modules/desktop.nix
          ./modules/users.nix
          ./modules/branding.nix
          ({ config, pkgs, lib, ... }: {
            nixpkgs.config.permittedInsecurePackages = [ "qtwebengine-5.15.19" ]; # Allow insecure qtwebengine for build

            environment.systemPackages = with pkgs; [
              usbutils libusb1 alsa-firmware alsa-tools
              dialog disko mkpasswd networkmanager # For partitioning and utils
            ];

            hardware.graphics.enable = true;
            hardware.graphics.extraPackages = with pkgs; [
              mesa
              vaapiIntel
              vaapiVdpau
              libvdpau-va-gl
              intel-media-driver  # For Intel GPUs
              # amdvlk  # Uncomment for AMD GPUs
            ];
            isoImage.squashfsCompression = "gzip -Xcompression-level 1";
            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            branding = {
              enable = true;
              asciiArt = true;
              splash = true;
              wallpaper = true;
              # waybarIcons = true;  # Removed: Waybar is Hyprland-specific
            };

            users.users.nixos = {
              initialHashedPassword = lib.mkForce null;
              home = "/home/nixos";
              createHome = true;
              extraGroups = [ "audio" "jackaudio" "video" "networkmanager" ];
              shell = lib.mkForce pkgs.bashInteractive;
            };

            # Override audio-user as a minimal system user in live ISO (hides from SDDM, satisfies assertions)
            users.users.audio-user = lib.mkForce {
              isSystemUser = true;
              group = "audio-user";
              description = "Disabled in live ISO";
            };
            users.groups.audio-user = {};

            # Autologin to nixos user (Plasma session in live)
            services.displayManager.autoLogin.enable = true;
            services.displayManager.autoLogin.user = "nixos";

            # Ensure SDDM hides audio-user explicitly (redundant but safe)
            services.displayManager.sddm.settings = {
              Users.HideUsers = "audio-user";
            };

            # Optional: Create screenshot directory (harmless for Plasma)
            system.activationScripts.mkdirScreenshots = {
              text = ''
                mkdir -p /home/nixos/Pictures/Screenshots
                chown nixos:users /home/nixos/Pictures/Screenshots
              '';
            };

            # Optional NVIDIA support (uncomment if needed)
            # hardware.nvidia.modesetting.enable = true;
            # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
            # boot.kernelParams = [ "nvidia-drm.modeset=1" ];
          })
        ];
      };

      # New ARM64 configuration
      archibaldOS-arm = nixpkgs.lib.nixosSystem {
        system = system-arm;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
          musnix.nixosModules.musnix
          ./modules/audio.nix  # Use the modified audio.nix below
          ./modules/desktop.nix
          ./modules/users.nix
          ./modules/branding.nix
          ({ config, pkgs, lib, ... }: {
            nixpkgs.config.permittedInsecurePackages = [ "qtwebengine-5.15.19" ]; # Allow insecure qtwebengine for build if needed

            environment.systemPackages = with pkgs; [
              usbutils libusb1 alsa-firmware alsa-tools
              dialog disko mkpasswd networkmanager # For partitioning and utils
            ];

            hardware.graphics.enable = true;
            hardware.graphics.extraPackages = with pkgs; [
              mesa  # Generic for ARM64 (e.g., Broadcom, Mali, etc.)
            ];
            isoImage.squashfsCompression = "gzip -Xcompression-level 1";
            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            branding = {
              enable = true;
              asciiArt = true;
              splash = true;
              wallpaper = true;
              # waybarIcons = true;  # Removed: Waybar is Hyprland-specific
            };

            users.users.nixos = {
              initialHashedPassword = lib.mkForce null;
              home = "/home/nixos";
              createHome = true;
              extraGroups = [ "audio" "jackaudio" "video" "networkmanager" ];
              shell = lib.mkForce pkgs.bashInteractive;
            };

            # Override audio-user as a minimal system user in live ISO (hides from SDDM, satisfies assertions)
            users.users.audio-user = lib.mkForce {
              isSystemUser = true;
              group = "audio-user";
              description = "Disabled in live ISO";
            };
            users.groups.audio-user = {};

            # Autologin to nixos user (Plasma session in live)
            services.displayManager.autoLogin.enable = true;
            services.displayManager.autoLogin.user = "nixos";

            # Ensure SDDM hides audio-user explicitly (redundant but safe)
            services.displayManager.sddm.settings = {
              Users.HideUsers = "audio-user";
            };

            # Optional: Create screenshot directory (harmless for Plasma)
            system.activationScripts.mkdirScreenshots = {
              text = ''
                mkdir -p /home/nixos/Pictures/Screenshots
                chown nixos:users /home/nixos/Pictures/Screenshots
              '';
            };

            # Optional NVIDIA support for ARM64 (e.g., Jetson; uncomment if needed)
            # hardware.nvidia.modesetting.enable = true;
            # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
            # boot.kernelParams = [ "nvidia-drm.modeset=1" ];
          })
        ];
      };
    };

    packages.${system-x86}.installer = self.nixosConfigurations.archibaldOS.config.system.build.isoImage;
    packages.${system-arm}.installer-arm = self.nixosConfigurations.archibaldOS-arm.config.system.build.isoImage;

    devShells.${system-arm}.default = pkgs-arm.mkShell {
      packages = with pkgs-arm; [
        audacity fluidsynth musescore guitarix
        csound faust portaudio rtaudio supercollider qjackctl
        surge
        pcmanfm vim
      ];
    };
  };
}
