{ ... }:
{
  sops.defaultSopsFile = ../secrets/core.yaml;
  sops.age.sshKeyPaths = [ /home/tonychg/.ssh/secrets ];
}
