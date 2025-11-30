# ArchibaldOS ARM64  
**© 2025 DeMoD LLC. All rights reserved.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Nix Flake](https://img.shields.io/badge/Built%20with-Nix-blue.svg)](https://nixos.org/)
[![Architecture](https://img.shields.io/badge/Arch-aarch64-green.svg)](https://nixos.org/)
[![GitHub Issues](https://img.shields.io/github/issues/DeMoD-LLC/archibaldos-arm)](https://github.com/DeMoD-LLC/archibaldos-arm/issues)
[![GitHub Stars](https://img.shields.io/github/stars/DeMoD-LLC/archibaldos-arm)](https://github.com/DeMoD-LLC/archibaldos-arm/stargazers)

**ArchibaldOS ARM64** is a professional-grade, fully reproducible NixOS-based operating system engineered by DeMoD LLC specifically for real-time audio production on modern ARM64 hardware. It delivers sub-5ms round-trip latency on devices ranging from single-board computers (Raspberry Pi 5, Orange Pi 5/Plus, Rock 5 series) to Apple Silicon Macs (M1/M2/M3 via Asahi Linux). The entire system is built declaratively with Nix flakes, enabling atomic updates, cross-compilation, and pixel-perfect reproducibility across all supported platforms.

Designed for musicians, sound designers, live performers, and embedded-audio developers, ArchibaldOS combines vendor-optimized kernels, Musnix audio tuning, PipeWire/JACK, and a curated professional audio toolset into a lightweight, power-efficient package.

## Key Features

- **Ultra-low latency audio** — Hardware-optimized kernels + Musnix + tuned PipeWire/JACK (128 samples @ 48kHz = ~2.7ms theoretical)
- **Modular & declarative** — Enable/disable audio, desktop (Hyprland/Plasma), or headless server modes with single-line configuration changes
- **Native multi-SoC support** — Raspberry Pi 5, Rockchip RK3588 boards, Apple Silicon M1/M2/M3, ODROID, Pine64, and more
- **One-command image generation** — `nix build .#orange-pi-5` produces ready-to-flash SD images
- **Cross-compilation ready** — Build ARM64 images from x86_64 workstations
- **Enterprise-grade reproducibility** — Every build is bit-for-bit identical; perfect for studios and deployments
- **Professional audio software** — Includes Guitarix, Faust, Pure Data, Ardour, Reaper, Carla, and more

## About Real-Time Performance

### The PREEMPT_RT Debate

Traditional wisdom says you need a PREEMPT_RT patched kernel for professional audio. **ArchibaldOS takes a pragmatic approach:**

**Current Implementation (v1.0):**
- Uses **vendor-optimized kernels** (RK3588, BCM2712, etc.) with full hardware support
- Applies **Musnix real-time tuning**: IRQ prioritization, CPU isolation, memory locking, performance governor
- Configures **PipeWire for minimum latency**: 128-sample buffers, optimized scheduling
- Expected latency: **3-5ms** round-trip on well-configured systems

**Why Not PREEMPT_RT Initially?**
1. **Hardware compatibility** — Vendor kernels include critical drivers (GPU, NPU, PCIe, power management) that aren't in mainline
2. **Stability** — RK3588 PREEMPT_RT patches are experimental and may cause boot failures or hardware issues
3. **Practical performance** — With proper tuning, non-RT kernels achieve acceptable latency for most professional work
4. **Development priorities** — We focused on getting a stable, reproducible base system first

**Future Roadmap:**
- [ ] PREEMPT_RT kernel variants as opt-in modules (for users willing to trade stability for absolute minimum latency)
- [ ] Mainline kernel option once ARM64 hardware support improves
- [ ] Per-board latency benchmarking and optimization guides
- [ ] Hybrid approach: RT kernel for Apple Silicon (mainline support is good), vendor kernels for SBCs

**Bottom Line:** If you need guaranteed sub-3ms latency, wait for our PREEMPT_RT variants. If 3-5ms works for your use case (it does for most live performance, recording, and DSP development), the current system is production-ready.

## Supported Hardware (as of November 2025)

| Category              | Devices / SoCs                                      | Status          |
|-----------------------|-----------------------------------------------------|-----------------|
| Rockchip RK3588       | Orange Pi 5 / 5 Plus, Radxa Rock 5A / 5B            | ✅ Tested       |
| Raspberry Pi          | Raspberry Pi 5 (BCM2712)                            | ⚠️ Experimental |
| Rockchip RK3399       | Pine64 Pinebook Pro, NanoPC-T4                      | ⚠️ Experimental |
| Apple Silicon         | M1 / M1 Pro / M1 Max / M1 Ultra / M2 / M3 (Asahi)   | 🚧 In Progress  |
| Amlogic               | ODROID-C2, ODROID-HC4                               | ⚠️ Experimental |

**Legend:**
- ✅ **Tested** — Validated with audio workloads, documented performance
- ⚠️ **Experimental** — Builds successfully, not yet benchmarked
- 🚧 **In Progress** — Active development

More boards can be added in minutes thanks to the parametric flake design.

## Quick Start

### Prerequisites
- NixOS or Nix package manager installed
- For cross-compilation from x86_64: `boot.binfmt.emulatedSystems = [ "aarch64-linux" ];` in your `/etc/nixos/configuration.nix`

### Building an Image

```bash
# 1. Clone the repository
git clone https://github.com/DeMoD-LLC/archibaldos-arm.git
cd archibaldos-arm

# 2. Build an image for your board
BOARD=orange-pi-5 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 \
  nix build .# --impure -L

# 3. Flash to SD card (decompress first if needed)
zstd -d result/sd-image/*.img.zst -o archibaldos-op5.img
sudo dd if=archibaldos-op5.img of=/dev/sdX bs=4M status=progress conv=fsync

# 4. Boot and log in
# Default user: audio
# Default password: changeme (change immediately!)
```

### Other Boards

```bash
# Orange Pi 5 Plus
BOARD=orange-pi-5-plus nix build .# --impure -L

# Rock 5A
BOARD=rock-5a nix build .# --impure -L

# Raspberry Pi 5 (experimental)
BOARD=raspberry-pi-5 nix build .# --impure -L
```

## Post-Installation

After first boot:

```bash
# Verify real-time configuration
rt-check

# Test audio latency (requires loopback cable or interface)
audio-latency-test

# List available audio software
guitarix        # Guitar/bass amp simulator
puredata        # Visual audio programming
faust2jack      # Compile Faust DSP code to JACK plugins
ardour          # DAW
qjackctl        # JACK connection manager
```

## Audio Software Included

**Live Performance & Effects:**
- Guitarix — Real-time guitar amp simulation and effects
- Carla — Universal plugin host (LV2, VST, LADSPA)

**Audio Programming:**
- Pure Data — Visual programming for interactive audio
- Faust — Functional audio DSP language with jack/lv2 compilation

**DAWs & Recording:**
- Ardour — Professional DAW
- Reaper — Commercial DAW (license required)
- Qtractor — MIDI/audio sequencer

**Utilities:**
- QjackCtl — JACK audio connection manager
- qpwgraph — PipeWire graph patchbay
- Helvum — PipeWire patchbay (GTK)
- Pavucontrol — Volume control

## Configuration Examples

### Disable Desktop (Headless Server)
Edit `configuration.nix`:
```nix
{
  imports = [
    ./modules/audio.nix
    # ./modules/desktop.nix  # Comment out
  ];
  
  services.xserver.enable = false;  # Disable X11
}
```

### Adjust Buffer Size
Edit `modules/audio.nix`:
```nix
default.clock.quantum = 64;  # Lower = less latency, more CPU
```

### Add Custom Audio Software
```nix
environment.systemPackages = with pkgs; [
  # ... existing packages ...
  hydrogen        # Drum machine
  supercollider   # Audio programming language
  vcv-rack        # Modular synthesizer
];
```

## Troubleshooting

### Audio Dropouts (XRUNs)
```bash
# Check CPU governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
# Should show "performance"

# Check RT limits
ulimit -r
# Should show 99

# Monitor system load
htop
```

### No Sound Output
```bash
# Check PipeWire status
systemctl --user status pipewire

# List audio devices
pw-cli list-objects | grep node.name

# Test with speaker-test
speaker-test -c 2 -r 48000
```

## Contributing

Contributions are welcome! Areas we'd especially appreciate help:

1. **PREEMPT_RT kernel variants** — Patches for RK3588, BCM2712
2. **Latency benchmarking** — Systematic testing across boards
3. **Board support** — Testing on Raspberry Pi 5, Rock 5B, etc.
4. **Documentation** — Guides, tutorials, troubleshooting
5. **Audio software** — Package additions, configuration improvements

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Copyright & License

© 2025 DeMoD LLC. All rights reserved.

Licensed under the **MIT License** — see [LICENSE](LICENSE) for full text.

```
MIT License

Copyright (c) 2025 DeMoD LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software...
```

## Contact & Support

- **Website:** https://demod.dev  
- **Issues:** https://github.com/DeMoD-LLC/archibaldos-arm/issues  
- **Discussions:** https://github.com/DeMoD-LLC/archibaldos-arm/discussions
- **Commercial support & custom builds:** contact@demod.dev  

---

**ArchibaldOS ARM64 — Professional real-time audio, declaratively delivered.**  
*Sub-5ms latency on affordable ARM hardware. Fully reproducible. Infinitely hackable.*
