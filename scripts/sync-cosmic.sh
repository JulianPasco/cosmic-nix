#!/usr/bin/env bash
# Sync COSMIC desktop configuration between repo and system
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Paths
REPO_COSMIC_DIR="/etc/nixos/cosmic-config"
USER_COSMIC_DIR="$HOME/.config/cosmic"

usage() {
    echo -e "${BLUE}COSMIC Config Sync${NC}"
    echo ""
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  export   - Export COSMIC config from ~/.config/cosmic to repo"
    echo "  import   - Import COSMIC config from repo to ~/.config/cosmic"
    echo "  status   - Show sync status"
    echo ""
}

export_config() {
    if [ ! -d "$USER_COSMIC_DIR" ]; then
        echo -e "${RED}Error: No COSMIC config found at $USER_COSMIC_DIR${NC}"
        echo "Make sure you have logged into COSMIC at least once."
        exit 1
    fi

    echo -e "${YELLOW}Exporting COSMIC config...${NC}"
    echo "From: $USER_COSMIC_DIR"
    echo "To:   $REPO_COSMIC_DIR"
    echo ""

    # Create directory and sync
    sudo mkdir -p "$REPO_COSMIC_DIR"
    sudo rsync -av --delete \
        --exclude='*.log' \
        --exclude='*.tmp' \
        --exclude='cache' \
        "$USER_COSMIC_DIR/" "$REPO_COSMIC_DIR/"
    
    # Fix ownership for git
    sudo chown -R root:root "$REPO_COSMIC_DIR"

    echo ""
    echo -e "${GREEN}Export complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "  cd /etc/nixos"
    echo "  sudo git add cosmic-config"
    echo "  sudo git commit -m 'Update COSMIC config'"
    echo "  sudo git push"
}

import_config() {
    if [ ! -d "$REPO_COSMIC_DIR" ]; then
        echo -e "${RED}Error: No COSMIC config found in repo at $REPO_COSMIC_DIR${NC}"
        echo "Run 'export' on your source machine first."
        exit 1
    fi

    echo -e "${YELLOW}Importing COSMIC config...${NC}"
    echo "From: $REPO_COSMIC_DIR"
    echo "To:   $USER_COSMIC_DIR"
    echo ""

    # Backup existing config if present
    if [ -d "$USER_COSMIC_DIR" ]; then
        BACKUP_DIR="$HOME/.config/cosmic.backup.$(date +%Y%m%d-%H%M%S)"
        echo -e "${YELLOW}Backing up existing config to $BACKUP_DIR${NC}"
        mv "$USER_COSMIC_DIR" "$BACKUP_DIR"
    fi

    # Sync from repo
    mkdir -p "$(dirname "$USER_COSMIC_DIR")"
    rsync -av "$REPO_COSMIC_DIR/" "$USER_COSMIC_DIR/"
    chown -R "$USER":"$USER" "$USER_COSMIC_DIR"

    echo ""
    echo -e "${GREEN}Import complete!${NC}"
    echo ""
    echo "You may need to log out and back in for changes to take effect."
}

show_status() {
    echo -e "${BLUE}COSMIC Config Sync Status${NC}"
    echo ""

    echo -n "User config:  "
    if [ -d "$USER_COSMIC_DIR" ]; then
        echo -e "${GREEN}exists${NC} at $USER_COSMIC_DIR"
        echo "              $(find "$USER_COSMIC_DIR" -type f | wc -l) files"
    else
        echo -e "${YELLOW}not found${NC}"
    fi

    echo ""
    echo -n "Repo config:  "
    if [ -d "$REPO_COSMIC_DIR" ]; then
        echo -e "${GREEN}exists${NC} at $REPO_COSMIC_DIR"
        echo "              $(find "$REPO_COSMIC_DIR" -type f | wc -l) files"
    else
        echo -e "${YELLOW}not found${NC}"
    fi
}

# Main
case "${1:-}" in
    export)
        export_config
        ;;
    import)
        import_config
        ;;
    status)
        show_status
        ;;
    *)
        usage
        exit 1
        ;;
esac
