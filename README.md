# ArchibaldOS: Lean Real-Time Audio NixOS Variant


## Overview

ArchibaldOS is a customized, minimal NixOS distribution optimized for real-time (RT) audio production. It leverages Musnix for low-latency audio configurations, PipeWire for audio handling, and KDE Plasma 6 as the desktop environment. This variant is designed for musicians, audio engineers, and producers who need a stable, performant system for tools like DAWs (Digital Audio Workstations), synthesizers, and effects plugins.

Now with support for both x86_64 and ARM64 (aarch64) architectures, enabling deployment on a wider range of hardware, including embedded devices like Raspberry Pi.

Key principles:
- **Minimalism**: Stripped-down setup focusing on RT audio essentials, avoiding bloat.
- **Oligarchy Philosophy**: A "minimal oligarchy" approach—prioritizing a small set of elite, high-performance components (e.g., RT kernel, low-latency PipeWire) over broad compatibility.
- **Branding**: Custom DeMoD LLC branding, including boot splash, wallpapers, and optional ASCII art in the installer.
- **Live ISO with Installer**: Built as a bootable ISO with a graphical Calamares installer for easy deployment.

This project is built using Nix flakes for reproducibility and declarative configuration. It's based on NixOS 24.11, with inputs from Musnix (for RT audio) and Disko (for declarative disk partitioning during installation).

## Features

### Real-Time Audio Optimization
- **Musnix Integration**: Enables RT kernel (latest RT patches), ALSA sequencer, RTIRQ for interrupt prioritization, and DAS watchdog for stability. Compatible with ARM64.
- **PipeWire Configuration**: Low-latency setup with 32-sample quantum at 48kHz sample rate. Supports ALSA, PulseAudio emulation, and JACK for compatibility with pro-audio apps.
- **Security Limits**: PAM limits for the `audio` group allow high RT priority (up to 95), unlimited memory lock, and high file descriptors.
- **Kernel Tweaks**: Parameters like `threadirqs`, CPU isolation (`isolcpus=1-3`), nohz_full for reduced latency, and performance governor. Swappiness set to 0, increased inotify watches. ARM64 configurations omit x86-specific options (e.g., Intel/processor C-states, HPET).
- **Audio Hardware Support**: Modules for USB audio/MIDI, with low-latency options. Graphics drivers for Intel (x86), with AMD/NVIDIA options commented out; ARM64 uses generic Mesa.
- **Pre-Installed Audio Tools**: A curated set including:
  - DAWs/Editors: Audacity, MuseScore, Zrythm, Carla, PureData, Cardinal, Helm.
  - Synths/Effects: Surge, ZynAddSubFX, Guitarix, Dragonfly Reverb, Calf plugins.
  - Utilities: QJackCtl, VMidi Keyboard (VMPK), QMidiNet, Faust (with ALSA/JACK/CSound backends), SuperCollider, CSound (with Qt GUI).
  - MIDI/Soundfonts: FluidSynth, PortAudio, RtAudio.

### Desktop Environment
- **KDE Plasma 6**: Lightweight, Wayland-enabled for better performance. SDDM display manager with auto-login in live mode. Fully supported on ARM64 hardware with sufficient resources.
- **Basic Utilities**: Vim, Kitty terminal, WirePlumber (PipeWire GUI), CAVA (audio visualizer), PlayerCtl (media controls).
- **Fonts**: JetBrains Mono for coding, Noto Emoji for broad support.

### Installation and Usability
- **Graphical Installer**: Calamares with Plasma 6 interface for partitioning, user setup, and installation.
- **Disko Support**: Declarative disk management for reproducible installs.
- **Live Mode**: Boot into a live Plasma session as `nixos` user (auto-login). Test audio setup before installing.
- **Users**: 
  - `nixos`: Default live user with sudo access (initial password: "nixos" post-install).
  - `audio-user`: Dedicated audio user with RT groups (`audio`, `jackaudio`, `video`, `wheel`). Home at `/home/audio-user`.
- **Branding Options** (configurable via Nix):
  - ASCII art in TUI installer (optional, adds minor delay).
  - Plymouth boot splash with DeMoD logo.
  - Wallpapers: Deployed system-wide to `/usr/share/wallpapers/ArchibaldOS`, with symlinks/scripts for Plasma, GNOME, XFCE, and fallback to `~/Pictures/Wallpapers`.
- **System Utilities**: USB tools, ALSA firmware, NetworkManager, dialog, mkpasswd for setup.

### Performance Enhancements
- **Disable Non-Essentials**: Systemd service to stop NetworkManager and Bluetooth on boot (for RT purity; re-enable if needed).
- **ASound Config**: Defaults to 48kHz, 32-bit float, low buffer for pro-audio.
- **Ardour Tweaks**: Custom `ardour.rc` for 32-sample buffer at 48kHz.
- **Dev Shell**: A Nix shell with audio tools for development/testing.

## Requirements

- **Hardware**:
  - x86_64 or aarch64 CPU (with at least 4 cores recommended for CPU isolation on x86; adjust for ARM SoCs).
  - Compatible audio interface (USB preferred; tested with ALSA/JACK).
  - Graphics: Intel integrated (x86), with AMD/NVIDIA options commented out; ARM64 uses Mesa (e.g., for Broadcom on Raspberry Pi or Mali on other SBCs).
  - At least 4GB RAM (8GB+ for heavy audio workloads). For ARM64, devices like Raspberry Pi 4/5, Orange Pi 5, or NVIDIA Jetson are recommended.
- **Software**:
  - Nix with flakes enabled (`nix.settings.experimental-features = [ "nix-command" "flakes" ];`).
- **Build Environment**: Allow unfree packages (`nixpkgs.config.allowUnfree = true;`) and permit insecure QtWebEngine for Calamares. For ARM64 builds on x86 hosts, cross-compilation is supported automatically via Nix.

## Building the ISO

1. Clone the repository:
   ```
   git clone <repo-url>
   cd archibaldos
   ```

2. Build the installer ISO:
   - For x86_64: `nix build .#installer`
   - For ARM64: `nix build .#packages.aarch64-linux.installer-arm`
   - Outputs: `result/iso/archibaldos-<version>.iso` (x86) or similar for ARM. ARM builds may take longer if not cached; use a powerful host for cross-compilation.

3. (Optional) Enter dev shell for testing audio tools:
   ```
   nix develop
   ```
   - This loads tools like Audacity, SuperCollider, etc. For ARM64, use `nix develop --system aarch64-linux`.

## Creating a Bootable USB

- Use `dd` (Linux/Mac):
  ```
  sudo dd if=result/iso/archibaldos-<version>.iso of=/dev/sdX bs=4M status=progress && sync
  ```
  Replace `/dev/sdX` with your USB device (use `lsblk` to identify). For ARM64 devices like Raspberry Pi, enable USB boot in firmware settings or use tools like Raspberry Pi Imager for SD cards if adapting to SD image format.

- Or use tools like Rufus (Windows) or Etcher.

## Installation Guide

1. **Boot the ISO**:
   - Boot from USB/CD. Select the ISO in BIOS/UEFI (x86) or firmware (ARM). For ARM64 (e.g., Raspberry Pi), ensure USB boot is enabled.
   - In live mode: Auto-logs in as `nixos` (no password). Test audio with pre-installed tools (e.g., run `qjackctl` for JACK setup).

2. **Run the Installer**:
   - Launch Calamares from the desktop or menu.
   - **Partitioning**: Use Disko/Calamares for guided or manual setup. Recommend EFI system if UEFI.
   - **Users**: Set up passwords. `audio-user` is pre-defined but disabled in live mode—enable post-install if needed.
   - **Networking**: Connect via NetworkManager if required.
   - Proceed with installation.

3. **Post-Install**:
   - Reboot into installed system.
   - Login as `nixos` (password: "nixos") or `audio-user` (set during install).
   - For RT audio: Add users to `audio` group if not already (`sudo usermod -aG audio <user>`).
   - Test latency: Run `jackd` or PipeWire apps. Use `rtirq status` to check priorities.
   - Customize: Edit `/etc/nixos/configuration.nix` (or flake) and `nixos-rebuild switch`.

   **Notes**:
   - In live mode, `audio-user` is a system user (hidden from login) to satisfy assertions.
   - Wallpapers are auto-deployed; set in Plasma settings.
   - For NVIDIA (x86 or ARM64 like Jetson): Uncomment hardware options in `flake.nix` and rebuild.
   - ARM64-Specific: Performance may vary on low-power devices; test RT latency with tools like `cyclictest`.

## Usage Tips

- **Audio Testing**:
  - Run `/etc/live-audio-test.sh` (if present) for a quick latency test.
  - Use QJackCtl to manage JACK sessions.
  - For visualization: Run CAVA in terminal (`cava`).

- **Customization**:
  - **Branding**: Disable via `branding.enable = false;` in modules.
  - **Kernel**: Switch to non-RT via `musnix.kernel.realtime = false;`.
  - **Add Packages**: Edit `audio.nix` or `desktop.nix` and rebuild.
  - **Wallpaper Paths**: Add to `branding.wallpaperPaths` list.

- **Troubleshooting**:
  - High latency? Check `cat /proc/interrupts` for IRQ conflicts; adjust `isolcpus`.
  - No sound? Ensure PipeWire is running (`systemctl --user status pipewire`).
  - Build errors: Ensure `allowUnfree` and permitted insecure packages.
  - For AMD GPUs (x86): Uncomment `amdvlk` in `flake.nix`.
  - ARM64 Issues: Verify hardware compatibility (e.g., mainline kernel support); some desktops may have minor lag on underpowered boards.

## Contributing

- Fork and PR changes to modules or flake.
- Report issues: Include Nix version, hardware specs (x86/ARM), and logs (e.g., `dmesg | grep audio`).
- Suggestions: Focus on RT audio improvements or minimalism.

## License

This project is licensed under the MIT License (or specify if different). DeMoD LLC branding assets are proprietary—contact for usage.

Built by DeMoD LLC | Version: Based on NixOS 24.11 | Last Updated: November 13, 2025

For questions, reach out on X @DeMoDLLC or via repo issues.
