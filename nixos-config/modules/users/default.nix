{ config, lib, pkgs, ... }:
{
  sops.secrets."root/password".neededForUsers = true;
  sops.secrets."tonychg/password".neededForUsers = true;

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.settings.PasswordAuthentication = false;

  users.mutableUsers = false;
  users.users.root = {
    openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFoYsBIQNKnOXkeRHXo1uJ7uhLemtC9d7+lQK6tf7dcT''
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxf+HvL6nx30p/8/S8YKCgQRwQEDJcyY0wqT/mHZTKM''
    ];
    hashedPasswordFile = config.sops.secrets."root/password".path;
  };
  users.users.tonychg = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFoYsBIQNKnOXkeRHXo1uJ7uhLemtC9d7+lQK6tf7dcT''
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxf+HvL6nx30p/8/S8YKCgQRwQEDJcyY0wqT/mHZTKM''
    ];
    hashedPasswordFile = config.sops.secrets."tonychg/password".path;
  };
}
