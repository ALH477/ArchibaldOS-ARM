# ArchibaldOS ARM64  
**© 2025 DeMoD LLC. All rights reserved.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Nix Flake](https://img.shields.io/badge/Built%20with-Nix-blue.svg)](https://nixos.org/)
[![Architecture](https://img.shields.io/badge/Arch-aarch64-green.svg)](https://nixos.org/)
[![GitHub Issues](https://img.shields.io/github/issues/DeMoD-LLC/archibaldos-arm)](https://github.com/DeMoD-LLC/archibaldos-arm/issues)
[![GitHub Stars](https://img.shields.io/github/stars/DeMoD-LLC/archibaldos-arm)](https://github.com/DeMoD-LLC/archibaldos-arm/stargazers)

**ArchibaldOS ARM64** is a professional-grade, fully reproducible NixOS-based operating system engineered by DeMoD LLC specifically for real-time audio production on modern ARM64 hardware. It delivers sub-5 ms round-trip latency on devices ranging from single-board computers (Raspberry Pi 5, Orange Pi 5/Plus, Rock 5 series) to Apple Silicon Macs (M1/M2/M3 via Asahi Linux). The entire system is built declaratively with Nix flakes, enabling atomic updates, cross-compilation, and pixel-perfect reproducibility across all supported platforms.

Designed for musicians, sound designers, live performers, and embedded-audio developers, ArchibaldOS combines the Musnix real-time kernel, PipeWire/JACK, and a curated professional audio toolset into a lightweight, power-efficient package.

## Key Features

- **Ultra-low latency audio** — PREEMPT_RT kernel + Musnix + tuned PipeWire (1.5–3 ms typical on supported hardware)  
- **Modular & declarative** — enable/disable audio, desktop (Hyprland/KDE), or headless server modes with a single flag  
- **Native multi-SoC support** — Raspberry Pi 5, Rockchip RK3588 boards, Apple Silicon M1/M2/M3, ODROID, Pine64, and more  
- **One-command image generation** — Nix flake produces ready-to-flash SD images or Apple installer ISOs  
- **Cross-compilation ready** — build everything from an x86_64 workstation  
- **Enterprise-grade reproducibility** — every build is bit-for-bit identical; perfect for studios and deployments  
- **Built-in testing** — QEMU boot checks, latency sanity script, fallback kernels  

## Supported Hardware (as of November 2025)

| Category              | Devices / SoCs                                      |
|-----------------------|-----------------------------------------------------|
| Raspberry Pi          | Raspberry Pi 5 (BCM2712)                            |
| Rockchip RK3588       | Orange Pi 5 / 5 Plus, Radxa Rock 5A / 5B            |
| Rockchip RK3399       | Pine64 Pinebook Pro, NanoPC-T4                      |
| Amlogic               | ODROID-C2, ODROID-HC4                               |
| Apple Silicon         | M1 / M1 Pro / M1 Max / M1 Ultra / M2 / M3 (Asahi)   |

More boards can be added in minutes thanks to the parametric flake design.

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/DeMoD-LLC/archibaldos-arm.git
cd archibaldos-arm

# 2. Build an image (example: Orange Pi 5)
nix build .#images.orange-pi-5 -L

# 3. Flash (decompress first if needed)
zstd -d result/sd-image/*.img.zst -o archibaldos-op5.img
sudo dd if=archibaldos-op5.img of=/dev/sdX bs=4M status=progress conv=fsync

# 4. Boot → live session auto-logs as audio-user
#    Run `rt-check` to verify real-time performance
```

For Apple Silicon, build the installer ISO instead:
```bash
nix build .#installerIso.apple-m2 -L
```

## Installation & Usage

Detailed instructions are in [INSTALL.md](INSTALL.md) (Apple Silicon) and [SBC-INSTALL.md](SBC-INSTALL.md) (single-board computers).

After installation:
```bash
# Switch configuration (e.g., disable desktop, enable server mode)
sudo nixos-rebuild switch --flake .#orange-pi-5

# Test latency
jack_iodelay
```

## Contributing

Contributions are welcome under the terms of the MIT License. Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Copyright & License

© 2025 DeMoD LLC. All rights reserved.

Permission is hereby granted under the **MIT License** — see the [LICENSE](LICENSE) file for full details.

```
MIT License

Copyright (c) 2025 DeMoD LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), ...
```

## Contact & Support

- Website: https://demod.dev  
- Issues: https://github.com/DeMoD-LLC/archibaldos-arm/issues  
- Commercial support & custom builds: contact@demod.dev  

**ArchibaldOS ARM64 — Professional real-time audio, anywhere ARM64 runs.**
