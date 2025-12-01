{ config, pkgs, inputs, board, lib, ... }:

{
  imports = [
    ./modules/audio.nix      # Real-time audio configuration
    # ./modules/desktop.nix  # Disabled - cross-compilation issues with some packages
  ];

  # Disable PulseAudio (PipeWire handles audio)
  services.pulseaudio.enable = false;

  # Hostname
  networking.hostName = "archibaldos-${board}";
  
  # NixOS version
  system.stateVersion = "25.05";

  # Enable network manager
  networking.networkmanager.enable = true;

  # Default user for audio work
  users.users.audio = {
    isNormalUser = true;
    description = "Audio User";
    extraGroups = [ 
      "wheel"      # sudo access
      "audio"      # audio hardware access
      "realtime"   # real-time scheduling
      "networkmanager"
    ];
    initialPassword = "changeme";  # Change on first boot!
  };

  # Enable SSH for remote access
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  # Basic system packages
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    tmux
    neovim
  ];

  # Headless system - no desktop environment
  # For GUI applications, use X11 forwarding over SSH or VNC
}
