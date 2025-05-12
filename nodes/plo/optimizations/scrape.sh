#!/usr/bin/env sh

set -euo pipefail

# Output directory
OUTDIR="./nixos_system_info"
mkdir -p "$OUTDIR"

echo "Collecting system hardware information..."

# System hardware info
lscpu >"$OUTDIR/cpu_info.txt"
lsmem >"$OUTDIR/memory_info.txt"
lsblk >"$OUTDIR/block_devices.txt"
lspci -vvv >"$OUTDIR/pci_devices.txt"
lsusb -vvv >"$OUTDIR/usb_devices.txt"

# NVMe detailed info
nvme list >"$OUTDIR/nvme_devices.txt" || echo "NVMe command not available"

# Kernel and boot configuration
echo "Collecting kernel and boot configuration..."
cat /proc/cmdline >"$OUTDIR/kernel_cmdline.txt"
sudo dmesg >"$OUTDIR/dmesg_output.txt"

# Services status
echo "Collecting system services information..."
systemctl list-unit-files --state=enabled >"$OUTDIR/enabled_services.txt"
systemctl list-units --type=service --state=running >"$OUTDIR/running_services.txt"

# System performance data
echo "Collecting performance-related data..."
vmstat 2 5 >"$OUTDIR/vmstat.txt"
free -h >"$OUTDIR/memory_usage.txt"
df -h >"$OUTDIR/disk_usage.txt"

# Networking and DNS
echo "Collecting networking configuration..."
ip addr show >"$OUTDIR/network_interfaces.txt"
ip route show >"$OUTDIR/network_routes.txt"
cat /etc/resolv.conf >"$OUTDIR/resolv_conf.txt"

# DNS performance check
dig google.com @127.0.0.1 +stats >"$OUTDIR/dns_local_test.txt" || echo "Dig not available or DNS not running locally"

# NixOS specific information
echo "Collecting NixOS specific configuration..."
nixos-version >"$OUTDIR/nixos_version.txt"
cat /etc/nixos/configuration.nix >"$OUTDIR/configuration.nix"
nix-store --gc --print-roots >"$OUTDIR/nix_gc_roots.txt"
nix-store --optimise --dry-run >"$OUTDIR/nix_optimise_dry_run.txt"

# Current flake details if available
if [ -f flake.nix ]; then
  nix flake show >"$OUTDIR/flake_info.txt" || echo "Nix flakes not in use"
fi

# Processes snapshot
ps auxf --sort=-%cpu >"$OUTDIR/process_snapshot.txt"

# GPU info
if command -v nvidia-smi &>/dev/null; then
  nvidia-smi >"$OUTDIR/nvidia_gpu_info.txt"
fi

# System logs
journalctl -b -p err >"$OUTDIR/system_errors.log"

# Complete

echo "Data collection complete. Results stored in: $OUTDIR"
