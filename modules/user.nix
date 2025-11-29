# User configuration (Home Manager)
{ config, pkgs, lib, userConfig, inputs, ... }:

{
  home.username = userConfig.username;
  home.homeDirectory = "/home/${userConfig.username}";
  home.stateVersion = "25.11";
  home.enableNixpkgsReleaseCheck = false;

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # NOTE: All packages are in modules/cosmic.nix
  # This file only configures shell, git, and user tools

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = userConfig.fullName;
      user.email = userConfig.email;
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Zsh shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ll = "eza -la --icons";
      ls = "eza --icons";
      cat = "bat";
      
      # NixOS shortcuts
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
      update = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake /etc/nixos";
      
      # COSMIC config sync
      cosmic-export = "/etc/nixos/scripts/sync-cosmic.sh export";
      cosmic-import = "/etc/nixos/scripts/sync-cosmic.sh import";
    };
    
    initExtra = ''
      # Custom prompt or additional config
      export EDITOR=nvim
    '';
  };

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
    };
  };

  # Direnv for development environments
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # XDG directories
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # NOTE: COSMIC desktop config is NOT managed by Home Manager
  # Use /etc/nixos/scripts/sync-cosmic.sh for COSMIC GUI config sync
  # This keeps COSMIC editable via the GUI while still synced through git
}
