# Home machine configuration
# All packages and settings are in modules/common.nix and modules/cosmic.nix
# Both work and home machines share the same setup
{ config, pkgs, lib, userConfig, ... }:

{
  # Host identity - only difference between machines
  networking.hostName = "home";

  # Disable swap to prevent boot hangs on ghost partitions
  # This overrides any swapDevices detected in hardware-home.nix
  swapDevices = lib.mkForce [ ];

  # Add home-ONLY packages here (things you don't need at work)
  # For shared packages, edit modules/common.nix or modules/cosmic.nix
  environment.systemPackages = with pkgs; [
    # Example: home-only tools
    # steam
  ];
}
