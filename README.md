# Baremetal minimal Linux Build with Busybox


## Components

- **Linux Kernel (configurable):** The heart of the operating system.
- **Busybox (configurable):** A suite of standard UNIX/Linux utilities combined into a single, statically-linked executable.

## Prerequisites

- A Linux or Unix-like environment (I built it on Arch WSL btw)
- Build essentials:
  - `make`
  - `gcc` (or another compiler if cross-compiling)
  - `wget`
  - `tar`
  - `cpio`
  - `musl-gcc` (for a statically linked Busybox build)
- Run this (on Arch):
  - `sudo pacman -S make gcc wget tar cpio && yay -S musl-gcc`

## Getting started

1. **Clone the repository:**

   ```bash
   git clone https://github.com/sajalkmr/tiny-linux-build

2. **Customize (optional):**
  Edit the build_minimal_linux.sh script to adjust the KERNEL_VERSION and BUSYBOX_VERSION if desired.

3. **Execute the build script:**

   ```bash
   sudo ./busybox.sh

3. **Running:**
   - **bzImage:** The compiled Linux kernel image.
   - **initrd.img:** The initial RAM disk containing Busybox and basic system setup.

4. **Booting with QEMU (example):**
   ```bash
   qemu-system-x86_64 -kernel bzImage -initrd initrd.img -nographic -append "console=ttyS0"
