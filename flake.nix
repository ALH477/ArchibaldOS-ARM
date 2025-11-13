{
  description = "Lean RT Audio ArchibaldOS: Minimal Oligarchy NixOS variant for real-time audio with Musnix, Plasma KDE (with ARM64 support)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    musnix.url = "github:musnix/musnix";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, musnix, disko }: let
    system-x86 = "x86_64-linux";
    system-arm = "aarch64-linux";
    pkgs-x86 = import nixpkgs {
      system = system-x86;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [ "qtwebengine-5.15.19" ];
      };
    };
    pkgs-arm = import nixpkgs {
      localSystem = system-x86;
      crossSystem = system-arm;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [ "qtwebengine-5.15.19" ];
      };
    };

    wallpaperSrc = ./modules/assets/wallpaper.jpg;

  in {
    nixosConfigurations = {
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
            environment.systemPackages = with pkgs; [
              usbutils libusb1 alsa-firmware alsa-tools
              dialog disko mkpasswd networkmanager
            ];

            hardware.graphics.enable = true;
            hardware.graphics.extraPackages = with pkgs; [
              mesa vaapiIntel vaapiVdpau libvdpau-va-gl intel-media-driver
              # amdvlk
            ];
            isoImage.squashfsCompression = "gzip -Xcompression-level 1";
            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            branding = {
              enable = true;
              asciiArt = true;
              splash = true;
              wallpaper = true;
            };

            users.users.nixos = {
              initialHashedPassword = lib.mkForce null;
              home = "/home/nixos";
              createHome = true;
              extraGroups = [ "audio" "jackaudio" "video" "networkmanager" ];
              shell = lib.mkForce pkgs.bashInteractive;
            };

            users.users.audio-user = lib.mkForce {
              isSystemUser = true;
              group = "audio-user";
              description = "Disabled in live ISO";
            };
            users.groups.audio-user = {};

            services.displayManager.autoLogin.enable = true;
            services.displayManager.autoLogin.user = "nixos";

            services.displayManager.sddm.settings = {
              Users.HideUsers = "audio-user";
            };

            system.activationScripts.mkdirScreenshots = {
              text = ''
                mkdir -p /home/nixos/Pictures/Screenshots
                chown nixos:users /home/nixos/Pictures/Screenshots
              '';
            };

            # Optional NVIDIA
            # hardware.nvidia.modesetting.enable = true;
            # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
            # boot.kernelParams = [ "nvidia-drm.modeset=1" ];
          })
        ];
      };

      archibaldOS-arm = nixpkgs.lib.nixosSystem {
        pkgs = pkgs-arm;
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          musnix.nixosModules.musnix
          ./modules/audio.nix
          ./modules/desktop.nix
          ./modules/users.nix
          ./modules/branding.nix
          ({ config, pkgs, lib, ... }: {
            environment.systemPackages = with pkgs; [
              usbutils libusb1 alsa-firmware alsa-tools
              dialog disko mkpasswd networkmanager
            ];

            hardware.graphics.enable = true;
            hardware.graphics.extraPackages = with pkgs; [
              mesa
            ];

            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            branding = {
              enable = true;
              asciiArt = true;
              splash = true;
              wallpaper = true;
            };

            users.users.nixos = {
              initialHashedPassword = lib.mkForce null;
              home = "/home/nixos";
              createHome = true;
              extraGroups = [ "audio" "jackaudio" "video" "networkmanager" ];
              shell = lib.mkForce pkgs.bashInteractive;
            };

            users.users.audio-user = lib.mkForce {
              isSystemUser = true;
              group = "audio-user";
              description = "Disabled in live ISO";
            };
            users.groups.audio-user = {};

            services.displayManager.autoLogin.enable = true;
            services.displayManager.autoLogin.user = "nixos";

            services.displayManager.sddm.settings = {
              Users.HideUsers = "audio-user";
            };

            system.activationScripts.mkdirScreenshots = {
              text = ''
                mkdir -p /home/nixos/Pictures/Screenshots
                chown nixos:users /home/nixos/Pictures/Screenshots
              '';
            };

            # Optional NVIDIA for ARM
            # hardware.nvidia.modesetting.enable = true;
            # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
            # boot.kernelParams = [ "nvidia-drm.modeset=1" ];

            # Example for Raspberry Pi
            # boot.loader.raspberryPi.enable = true;
            # boot.loader.raspberryPi.version = 4;
            # boot.kernelPackages = pkgs.linuxPackages_rpi4;
          })
        ];
      };
    };

    packages = {
      "${system-x86}" = {
        installer = self.nixosConfigurations.archibaldOS.config.system.build.isoImage;
        installer-arm = self.nixosConfigurations.archibaldOS-arm.config.system.build.sdImage;
      };
    };

    devShells."${system-arm}".default = pkgs-arm.mkShell {
      packages = with pkgs-arm; [
        audacity fluidsynth musescore guitarix
        csound faust portaudio rtaudio supercollider qjackctl
        surge-XT
        pcmanfm vim
      ];
    };
  };
}
