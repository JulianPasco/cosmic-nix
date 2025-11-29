# NixOS COSMIC Configuration

Modern NixOS configuration with COSMIC desktop environment, using flakes and Home Manager.

## Features

- **COSMIC Desktop** - System76's modern Wayland desktop
- **Flakes** - Reproducible, composable Nix configuration
- **Home Manager** - Declarative user environment management
- **Multi-host** - Support for work and home machines
- **Extra Applets** - Additional COSMIC applets (currently disabled due to upstream issues)
- **COSMIC Config Sync** - GUI-editable settings synced via git

## Quick Install

On a fresh NixOS installation:

```bash
curl -fsSL https://raw.githubusercontent.com/JulianPasco/cosmic-nix/main/scripts/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/JulianPasco/cosmic-nix /tmp/cosmic-nix
chmod +x /tmp/cosmic-nix/scripts/install.sh
/tmp/cosmic-nix/scripts/install.sh
```

## Structure

```
cosmic-nix/
├── flake.nix                 # Main flake configuration
├── user-config.nix           # Your config (placeholder, overwritten on install)
├── modules/
│   ├── common.nix            # System: packages, user, nix settings
│   ├── cosmic.nix            # Desktop: COSMIC, apps, fonts
│   └── user.nix              # User: shell, git, CLI tools (Home Manager)
├── hosts/
│   ├── work.nix              # Work machine (just hostname)
│   ├── home.nix              # Home machine (just hostname)
│   ├── hardware-work.nix     # Work hardware (generated on install)
│   └── hardware-home.nix     # Home hardware (generated on install)
├── scripts/
│   ├── install.sh            # Fresh install script
│   └── sync-cosmic.sh        # COSMIC config sync
└── cosmic-config/            # Synced COSMIC GUI settings
```

> **Note**: `user-config.nix` is overwritten during installation with your details (username, email, timezone). Hardware files are generated with your actual hardware config during install.

## Usage

### Rebuild System

```bash
sudo nixos-rebuild switch --flake /etc/nixos#work
# or
sudo nixos-rebuild switch --flake /etc/nixos#home
```

### Update All Packages

```bash
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild switch --flake /etc/nixos#work
```

### Sync COSMIC Configuration

After customizing COSMIC via the GUI (panels, wallpaper, shortcuts, etc.):

```bash
# Export your settings to the repo
/etc/nixos/scripts/sync-cosmic.sh export
cd /etc/nixos
sudo git add cosmic-config
sudo git commit -m "Update COSMIC config"
sudo git push
```

On another machine:

```bash
cd /etc/nixos
sudo git pull
/etc/nixos/scripts/sync-cosmic.sh import
# Log out and back in
```

## Private Dotfiles

SSH keys and sensitive dotfiles should be stored in a **private** repository.

Create a private repo (e.g., `dotfiles-private`) with this structure:

```
dotfiles-private/
├── .ssh/
│   ├── id_ed25519
│   ├── id_ed25519.pub
│   └── config
├── .gitconfig
├── .zshrc
└── install-dotfiles.sh
```

Example `install-dotfiles.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# SSH keys
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
for f in id_ed25519 id_ed25519.pub config; do
    [ -f "$DOTFILES_DIR/.ssh/$f" ] && ln -sf "$DOTFILES_DIR/.ssh/$f" "$HOME/.ssh/$f"
done
chmod 600 "$HOME/.ssh/id_ed25519" 2>/dev/null || true
chmod 644 "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || true

# Other dotfiles
for f in .gitconfig .zshrc; do
    [ -f "$DOTFILES_DIR/$f" ] && ln -sf "$DOTFILES_DIR/$f" "$HOME/$f"
done

echo "Dotfiles installed!"
```

Usage:

```bash
git clone git@github.com:YourName/dotfiles-private.git ~/dotfiles-private
cd ~/dotfiles-private
./install-dotfiles.sh
```

## Customization

### Edit User Config

User configuration is stored in `user-config.nix` (generated during install).

To modify, edit the file directly:

```bash
sudo nano /etc/nixos/user-config.nix
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake /etc/nixos
```

### Add Packages

Both machines share the **same packages, settings, and desktop layout**.

**All packages are in one file**: `modules/cosmic.nix`

Other files:
- `modules/common.nix` - System settings (nix, user, network, SSH)
- `modules/user.nix` - Shell config (zsh, git, aliases)

Host files (`hosts/work.nix`, `hosts/home.nix`) only set the hostname.

### Enable Docker

Add to `modules/common.nix`:

```nix
virtualisation.docker = {
  enable = true;
  enableOnBoot = true;
};
# Also add "docker" to user's extraGroups
```

### Enable Gaming

Add to `modules/cosmic.nix`:

```nix
programs.steam.enable = true;
```

## Extra Applets

Additional COSMIC applets from [ext-cosmic-applets-flake](https://github.com/wingej0/ext-cosmic-applets-flake) are **currently disabled** due to upstream hash mismatch issues.

Once fixed, uncomment in `modules/cosmic.nix`:
```nix
inputs.cosmic-applets-collection.packages.${system}.default
```

Available applets include: minimon, clipboard-manager, emoji-selector, weather, caffeine.

## Troubleshooting

### Binary Cache

If builds are slow, ensure the cache is working:

```bash
nix store ping --store https://cosmic.cachix.org/
```

### Hardware Configuration

Regenerate hardware config if needed:

```bash
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hosts/hardware-work.nix
```

### Rollback

If something breaks:

```bash
sudo nixos-rebuild switch --rollback
```

Or select a previous generation at boot.

## License

MIT
