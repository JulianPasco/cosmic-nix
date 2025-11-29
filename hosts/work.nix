# Work machine configuration
# All packages and settings are in modules/common.nix and modules/cosmic.nix
# Both work and home machines share the same setup
{ config, pkgs, lib, userConfig, ... }:

{
  # Host identity - only difference between machines
  networking.hostName = "work";

  # Add work-ONLY packages here (things you don't need at home)
  # For shared packages, edit modules/common.nix or modules/cosmic.nix
  environment.systemPackages = with pkgs; [
    # Example: work-only tools
    # vpn-client
  ];
}
