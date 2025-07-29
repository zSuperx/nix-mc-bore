# nix-mc-bore

<!--toc:start-->
- [nix-mc-bore](#nix-mc-bore)
  - [About](#about)
  - [Usage](#usage)
  - [Troubleshooting](#troubleshooting)
<!--toc:end-->

## About

This is a simple NixOS module that extends the `nix-minecraft` NixOS module
with options to integrate with the `bore` TCP tunneling program.

Read more about each of them here:

- [nix-minecraft](https://github.com/Infinidoge/nix-minecraft)
- [bore](https://github.com/ekzhang/bore)

## Usage

This module is intended to be used alongside `nix-minecraft`'s
`minecraft-servers` module.

First add it to your flake inputs:

```nix
{
  inputs = {
    nix-mc-bore.url = "github:zSuperx/nix-mc-bore";
  };

  outputs = inputs @ { self, ... }: {
    # ...
  };
}
```

Then in your `configuration.nix` or adjacent, add the usual imports for `nix-minecraft`,
along with `nix-mc-bore`. You can then configure NixOS to automatically start a
systemd service for `bore local` alongside the minecraft server.

```nix
{ 
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
    inputs.nix-mc-bore.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    dataDir = "/var/servers/minecraft";
    servers = {
      survival = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_18_2;
        bore = {
          enable = true;
          address = "mc.myserver.net";
          secret = "totally-secure-secret";
          proxy-port = 6969;
          local-port = 6969;
          rcon-port = 6968;
        };
      };

      creative = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_18_2;
        bore = {
          enable = true;
          proxy-port = 69420;
          local-port = 25565;
          rcon-port = 25575;
        };
      };
    };
  };
}
```

(The default proxy address is [bore.pub], a publicly hosted server by the
author of bore. Go show them your support!)

## Troubleshooting

`nix-minecraft` creates systemd services named `"minecraft-server-<name>"`,
where `<name>` is the attribute name within
`services.minecraft-servers.servers`.

`nix-mc-bore` follows this convention, and simply appends `"-bore"` to the end,
creating services only when enabled. As a result, the following
configuration...

```nix
{
  services.minecraft-servers.servers = {
    survival = {
      enable = true;
      bore.enable = true;
    };

    creative = {
      enable = true;
      bore.enable = false;
    };
  };
}
```

...results in the following systemd services:

- `"minecraft-server-survival"`
- `"minecraft-server-survival-bore"`
- `"minecraft-server-creative"`

These can all be started and stopped with `systemctl [start|stop]
<service-name>`, and their logs can be observed with `journalctl -u
<service-name>`.

Additionally, `nix-mc-bore` will run some basic port exclusivity assertions at
build time, warning you about any duplicate local ports (server & rcon ports)
as well as duplicate bore server address/port tuples.

To disable these assertions, set
`services.minecraft-servers.allowDuplicatePorts = true`, but beware that the
bore services may silently fail.
