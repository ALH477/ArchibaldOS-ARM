# ArchibaldOS: A Lean Real-Time Audio NixOS Variant

![Logo](./modules/assets/demod-logo.png)

## Overview

ArchibaldOS is a specialized, minimal NixOS distribution tailored for real-time (RT) audio production. It integrates Musnix for low-latency audio configurations, PipeWire for robust audio handling, and KDE Plasma 6 as the desktop environment. Designed for musicians, audio engineers, and producers, ArchibaldOS provides a stable and high-performance platform for digital audio workstations (DAWs), synthesizers, and effects plugins.

With support for both x86_64 and ARM64 (aarch64) architectures, ArchibaldOS enables deployment on diverse hardware, including desktop systems and embedded devices such as Raspberry Pi.

### Key Principles
- **Minimalism**: A streamlined setup focused on essential RT audio tools, minimizing unnecessary components.
- **Oligarchy Philosophy**: Prioritizes a select group of high-performance elements (e.g., RT kernel, low-latency PipeWire) for optimized efficiency.
- **Custom Branding**: Features DeMoD LLC branding, including boot splash, wallpapers, and optional ASCII art in the installer.
- **Live Media with Installer**: Delivered as bootable ISO or SD images with a graphical Calamares installer for seamless deployment.

Built using Nix flakes, ArchibaldOS ensures reproducibility and declarative configuration. It is based on NixOS 24.11, incorporating inputs from Musnix for RT audio and Disko for declarative disk partitioning.

## Features

### Real-Time Audio Optimization
- **Musnix Integration**: Enables the RT kernel with the latest patches, ALSA sequencer, RTIRQ for interrupt prioritization, and DAS watchdog for enhanced stability. Fully compatible with ARM64.
- **PipeWire Configuration**: Configured for low-latency operation with a 32-sample quantum at 48 kHz. Supports ALSA, PulseAudio emulation, and JACK for broad pro-audio compatibility.
- **Security Limits**: PAM configurations for the `audio` group provide high RT priority (up to 95), unlimited memory locking, and expanded file descriptors.
- **Kernel Tweaks**: Includes parameters such as `threadirqs`, CPU isolation (`isolcpus=1-3`), `nohz_full` for latency reduction, and the performance governor. ARM64 variants exclude x86-specific options (e.g., Intel/processor C-states, HPET).
- **Audio Hardware Support**: Loads modules for USB audio/MIDI with low-latency settings. Graphics drivers include Intel support (x86) with optional AMD/NVIDIA; ARM64 utilizes generic Mesa.
- **Pre-Installed Audio Tools**:
  - DAWs/Editors: Audacity, MuseScore, Zrythm, Carla, PureData, Cardinal, Helm.
  - Synths/Effects: Surge (x86 only; ARM may require overrides), ZynAddSubFX, Guitarix, Dragonfly Reverb, Calf plugins.
  - Utilities: QJackCtl, Virtual MIDI Keyboard (VMPK), QMidiNet, Faust (with ALSA/JACK/CSound backends), SuperCollider, CSound (with Qt GUI).
  - MIDI/Soundfonts: FluidSynth, PortAudio, RtAudio.

### Desktop Environment
- **KDE Plasma 6**: A lightweight, Wayland-enabled interface for optimal performance. Includes SDDM display manager with auto-login in live mode. Supported on ARM64 with adequate hardware resources.
- **Basic Utilities**: Vim, Kitty terminal, WirePlumber (PipeWire GUI), CAVA (audio visualizer), PlayerCtl (media controls).
- **Fonts**: JetBrains Mono for coding tasks and Noto Emoji for comprehensive symbol support.

### Installation and Usability
- **Graphical Installer**: Calamares with a Plasma 6 interface for intuitive partitioning, user configuration, and installation.
- **Disko Support**: Enables declarative disk management for consistent and reproducible setups.
- **Live Mode**: Boots into a live Plasma session as the `nixos` user (auto-login enabled). Ideal for testing audio configurations prior to installation.
- **User Management**:
  - `nixos`: Default live user with sudo privileges (initial post-install password: "nixos").
  - `audio-user`: Dedicated user for audio tasks, assigned to RT groups (`audio`, `jackaudio`, `video`, `wheel`). Home directory: `/home/audio-user`.
- **Branding Options** (Nix-configurable):
  - Optional ASCII art in the TUI installer (adds minor delay).
  - Plymouth boot splash featuring the DeMoD logo.
  - Wallpapers deployed system-wide to `/usr/share/wallpapers/ArchibaldOS`, with symlinks/scripts for Plasma, GNOME, XFCE, and a fallback to `~/Pictures/Wallpapers`.
- **System Utilities**: Includes USB tools, ALSA firmware, NetworkManager, dialog, and mkpasswd for setup assistance.

### Performance Enhancements
- **Service Management**: A Systemd service disables non-essential components (e.g., NetworkManager, Bluetooth) on boot to maintain RT integrity; re-enable as needed.
- **ALSA Configuration**: Defaults to 48 kHz, 32-bit float, with low buffer sizes for professional audio workflows.
- **Ardour Optimization**: Custom `ardour.rc` for 32-sample buffers at 48 kHz.
- **Development Shell**: A Nix shell environment pre-loaded with audio tools for testing and development.

## Requirements

- **Hardware**:
  - CPU: x86_64 or aarch64 (4+ cores recommended for CPU isolation on x86; adjust for ARM SoCs).
  - Audio Interface: Compatible USB device (tested with ALSA/JACK).
  - Graphics: Intel integrated (x86) with optional AMD/NVIDIA; Mesa for ARM64 (e.g., Broadcom on Raspberry Pi or Mali on other SBCs).
  - RAM: Minimum 4 GB (8+ GB recommended for intensive audio workloads). Suitable ARM64 devices include Raspberry Pi 4/5, Orange Pi 5, or NVIDIA Jetson.
- **Software**:
  - Nix with flakes enabled (`nix.settings.experimental-features = [ "nix-command" "flakes" ];`).
- **Build Environment**: Enable unfree packages (`nixpkgs.config.allowUnfree = true;`) and permit insecure QtWebEngine for Calamares. For ARM64 builds on x86 hosts, leverage cross-compilation. Some packages (e.g., surge-XT) may require `allowUnsupportedSystem = true;` and could exhibit runtime issues on ARM—perform thorough testing.

## Building the Media

1. Clone the repository:
   ```
   git clone <repo-url>
   cd archibaldos
   ```

2. Build the installer media:
   - For x86_64 (ISO): `nix build .#packages.x86_64-linux.installer`
   - For ARM64 (SD Image): `nix build .#packages.x86_64-linux.installer-arm`
   - Outputs: `result/iso/archibaldos-<version>.iso` for x86 or `result/sd-image/archibaldos-arm-<version>.img.zst` for ARM (unzip before writing). ARM builds may require extended time due to cross-compilation; use a capable host.

3. (Optional) Enter the development shell for tool testing:
   ```
   nix develop
   ```
   For ARM64: `nix develop --system aarch64-linux`.

## Creating Bootable Media

### For x86_64 (USB Drive)
- Use `dd` (Linux/Mac):
  ```
  sudo dd if=result/iso/archibaldos-<version>.iso of=/dev/sdX bs=4M status=progress && sync
  ```
  Replace `/dev/sdX` with your USB device (identify via `lsblk`).

- Alternatives: Rufus (Windows) or Etcher.

### For ARM64 (SD Card)
- Unzip the image if necessary: `unzstd result/sd-image/archibaldos-arm-<version>.img.zst -o archibaldos-arm-<version>.img`.
- Use `dd` (Linux/Mac):
  ```
  sudo dd if=archibaldos-arm-<version>.img of=/dev/sdX bs=4M status=progress && sync
  ```
  Replace `/dev/sdX` with your SD card device (use `lsblk` to confirm).

- Alternatives: Raspberry Pi Imager or balenaEtcher for graphical writing. For Raspberry Pi, insert the SD card and boot; enable USB boot in firmware if needed for peripherals.

## Installation Guide

1. **Boot the Media**:
   - x86: Boot from USB via BIOS/UEFI settings.
   - ARM64: Insert the SD card and power on the device (e.g., Raspberry Pi). For ARM SBCs, ensure firmware supports the boot method.
   - Live mode auto-logs in as `nixos` (no password). Test audio tools (e.g., `qjackctl` for JACK setup).

2. **Run the Installer**:
   - Launch Calamares from the desktop or menu.
   - **Partitioning**: Use guided or manual modes with Disko/Calamares support. EFI is recommended for UEFI systems.
   - **User Setup**: Configure passwords. The `audio-user` is pre-defined but disabled in live mode; enable post-install if required.
   - **Networking**: Connect using NetworkManager as needed.
   - Complete the installation process.

3. **Post-Installation**:
   - Reboot into the installed system.
   - Log in as `nixos` (password: "nixos") or `audio-user` (set during install).
   - Configure RT audio: Add users to the `audio` group (`sudo usermod -aG audio <user>`).
   - Verify latency: Use `jackd` or PipeWire applications; check priorities with `rtirq status`.
   - Customize: Modify `/etc/nixos/configuration.nix` (or flake) and apply changes with `nixos-rebuild switch`.

   **Notes**:
   - `audio-user` appears as a system user in live mode (hidden from login) to meet configuration assertions.
   - Wallpapers are automatically deployed; configure in Plasma settings.
   - NVIDIA support (x86 or ARM64 like Jetson): Uncomment relevant options in `flake.nix` and rebuild.
   - ARM64 Considerations: Performance varies on low-power hardware; use `cyclictest` for RT latency testing. Some packages (e.g., surge-XT) are marked unsupported in Nixpkgs but may function with overrides—monitor for stability.

## Usage Tips

- **Audio Testing**:
  - Execute `/etc/live-audio-test.sh` for latency checks.
  - Manage JACK sessions via QJackCtl.
  - Visualize audio with CAVA (`cava` in terminal).

- **Customization**:
  - Disable branding: Set `branding.enable = false;` in modules.
  - Switch to non-RT kernel: `musnix.kernel.realtime = false;`.
  - Add packages: Edit `audio.nix` or `desktop.nix` and rebuild.
  - Extend wallpaper paths: Modify `branding.wallpaperPaths`.

- **Troubleshooting**:
  - Latency issues: Inspect `/proc/interrupts` for IRQ conflicts; tune `isolcpus`.
  - Audio absence: Verify PipeWire status (`systemctl --user status pipewire`).
  - Build failures: Confirm `allowUnfree` and insecure package permissions.
  - AMD GPUs (x86): Uncomment `amdvlk` in `flake.nix`.
  - ARM64 challenges: Ensure mainline kernel compatibility; desktops may exhibit minor lag on underpowered boards; unsupported packages like surge-XT could fail at runtime.

## Contributing

Fork the repository and submit pull requests for module or flake enhancements. Report issues with details on Nix version, hardware (x86/ARM), and logs (e.g., `dmesg | grep audio`). Suggestions should emphasize RT audio optimizations or minimalism.

## License

Licensed under the MIT License. DeMoD LLC branding assets are proprietary—contact for usage permissions.

Built by DeMoD LLC | Version: Based on NixOS 24.11 | Last Updated: November 13, 2025

For inquiries, contact via X @DeMoDLLC or repository issues.
