# 🧬 drzzln/nix

**Composable, modular NixOS platform configurations — hardened, automated, and deeply DRY.**

This flake powers all my computing infrastructure. Built on [`flake-parts`](https://flake.parts) for maximum flexibility and maintainability.

---

## ✨ Features

- ✅ **Flake-based structure** using [`flake-parts`](https://flake.parts) for clean modularization
- 🧠 **Single-source DRY logic** for all system types: NixOS, Home Manager, Darwin/macOS
- 🔐 **Secrets Management** via [`sops-nix`](https://github.com/Mic92/sops-nix)
- ⚙️ **Overlays** and custom packages with lazy per-system resolution
- 🎨 Theming support with [`stylix`](https://github.com/danth/stylix)
- ☁️ Darwin/macOS config bootstrapping with `nix-darwin` + Home Manager

---

## 📁 Layout

```
.
├── flake.nix                  # Entry point for the platform
├── parts/                     # Modular logic via flake-parts
│   ├── overlays.nix           # All Nixpkgs overlays
│   ├── packages.nix           # Cross-system packages & devShells
│   ├── nixos.nix              # NixOS modules & configurations
│   ├── home.nix               # Home Manager logic
│   └── darwin.nix             # macOS configuration
├── modules/                   # Custom reusable NixOS/Home modules
├── nixosConfigurations/       # System-level configurations
├── homeConfigurations/        # Home Manager-only configs
├── darwinConfigurations/      # macOS systems
├── overlays/                  # Project-specific overlays
└── pkgs/                      # Custom packages (e.g., neovim, etc.)
```

---

## 🚀 Getting Started

### ❄️ Use as a flake

```bash
nix run github:drzln/nix#devShells.x86_64-linux.default
```

### 💻 Build a NixOS host (e.g. `plo`)

```bash
sudo nixos-rebuild switch --flake .#plo
```

## 🔐 Secrets Management

Secrets are stored encrypted in Git with [SOPS](https://github.com/mozilla/sops), and mounted read-only into containers.

To decrypt:

```bash
sops -d secrets.yaml
```

> Requires GPG access, managed via Home Manager if needed.

---

## 📦 Binary Cache

This repo integrates with [`attic`](https://github.com/zhaofengli/attic) for reproducible distributed builds.

To enable:

```nix
{
  nix.settings = {
    substituters = [ "https://attic.example.com/drzzln" ];
    trusted-public-keys = [ "drzzln.attic.pub" ];
  };
}
```

---

## ⚒️ DevShells

Run:

```bash
nix develop
```

You'll get access to tools like:

- `kubectl` from your own Kubernetes flake
- `neovim` with custom overlays
- `sops`, `git`, etc.

---

## 💡 Tips

- Everything uses **only self-built binaries** — even `kubelet`, `containerd`, `etcd`, etc.
- `specialArgs` are passed consistently into all modules (for inputs, packages, etc.).
- Configuration is DRY by design — modularize first, hardcode nothing.

---

## 🧠 Philosophy

> “Configuration is code. Code is memory. Memory should be minimal and reproducible.”

This flake is designed to be entirely **stateless and immutable**, driven only by:

- Git commits
- Encrypted secrets
- Reproducible derivations

---

## 🤝 Contributing

If you're working on this as part of a team or in your company:

- Define local systems under `nixosConfigurations/your-system`
- Mount your GPG identity via `~/.gnupg` or Home Manager
- Keep all secrets encrypted and reviewed in PRs

---

## 📜 License

MIT. Do what you want, just don’t ship bugs.

---

## 👤 Maintainer

Built and maintained by [drzzln](https://github.com/drzln) — platform engineer, devopsist, and builder of weird systems.
