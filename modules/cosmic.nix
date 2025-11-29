# COSMIC Desktop Environment configuration
{ config, pkgs, lib, ... }:

{
  # Enable X server (required for some apps)
  services.xserver.enable = true;

  # COSMIC Desktop
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # Keyboard layout
  services.xserver.xkb = {
    layout = "za";
    variant = "";
  };

  # Console keyboard
  console.keyMap = "us";

  # Sound with PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Printing
  services.printing.enable = true;

  # Flatpak for COSMIC Store
  services.flatpak.enable = true;

  # XDG portal for better app integration
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-cosmic ];
  };

  # ============================================
  # ALL PACKAGES - Edit this list to add/remove apps
  # ============================================
  environment.systemPackages = with pkgs; [
    
    # --- COSMIC Desktop ---
    cosmic-bg
    cosmic-edit
    cosmic-files
    cosmic-term
    #cosmic-store
    cosmic-screenshot
    cosmic-icons
    cosmic-wallpapers
    
    # Extra COSMIC packages from nixpkgs
    cosmic-player
    cosmic-settings
    cosmic-osd
    cosmic-idle
    cosmic-notifications
    cosmic-launcher
    cosmic-settings-daemon
    cosmic-session
    cosmic-panel
    cosmic-randr
    cosmic-workspaces-epoch
    cosmic-protocols
    cosmic-applets
    xdg-desktop-portal-cosmic
    quick-webapps
    
    # --- Browsers ---
    firefox
    google-chrome
    
    # --- Office ---
    onlyoffice-desktopeditors
    
    # --- Development ---
    vscode
    git
    lazygit
    neovim
    nodejs_22
    python3
    windsurf

    
    # --- CLI Tools ---
    wget
    curl
    htop
    btop
    fastfetch
    fzf
    ripgrep
    fd
    jq
    bat
    eza
    tree
    
    # --- File Management ---
    unzip
    zip
    p7zip
    file
    gparted
    filezilla
    
    # --- Media ---
    vlc
    celluloid
    
    # --- Remote Access ---
    remmina
    
    # --- Utilities ---
    xclip
    wl-clipboard
    lsof
    pciutils
    usbutils
    preload
  ];

  #Firefox as default browser
  programs.firefox.enable = true;

  #Enable dconf for GTK app settings
  programs.dconf.enable = true;

  # Font configuration
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrains Mono" ];
      };
    };
  };
}
