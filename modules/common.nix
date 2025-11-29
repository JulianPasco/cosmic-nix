# Common system configuration shared across all hosts
{ config, pkgs, lib, userConfig, ... }:

{
  # Nix settings
  nix = {
    settings = {
      # Enable flakes and new nix command
      experimental-features = [ "nix-command" "flakes" ];
      
      # Binary caches for faster builds
      substituters = [
        "https://cache.nixos.org/"
        "https://cosmic.cachix.org/"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
      ];
      
      # Optimize storage
      auto-optimise-store = true;
    };
    
    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Allow unfree packages (Chrome, OnlyOffice, etc.)
  nixpkgs.config.allowUnfree = true;

  # Timezone and locale
  time.timeZone = userConfig.timezone;
  i18n = {
    defaultLocale = userConfig.locale;
    extraLocaleSettings = {
      LC_ADDRESS = userConfig.locale;
      LC_IDENTIFICATION = userConfig.locale;
      LC_MEASUREMENT = userConfig.locale;
      LC_MONETARY = userConfig.locale;
      LC_NAME = userConfig.locale;
      LC_NUMERIC = userConfig.locale;
      LC_PAPER = userConfig.locale;
      LC_TELEPHONE = userConfig.locale;
      LC_TIME = userConfig.locale;
    };
  };

  # Networking
  networking.networkmanager.enable = true;

  # User account
  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = userConfig.fullName;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
  };

  # NOTE: All packages are in modules/cosmic.nix

  # OpenSSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # Enable firmware updates
  services.fwupd.enable = true;

  # Boot settings
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # This value determines the NixOS release
  # Do NOT change this after initial install
  system.stateVersion = "25.05";
}
