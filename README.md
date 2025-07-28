# nix-mc-bore

This is a simple NixOS module that extends the `nix-minecraft` NixOS module
with options to integrate with the `bore` TCP tunneling program.

Read more about each of them here:
- [nix-minecraft](https://github.com/Infinidoge/nix-minecraft)
- [bore](https://github.com/ekzhang/bore)

## Usage

This module is intended to be used alongside `nix-minecraft`'s `minecraft-servers` module.

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
along with `nix-mc-bore`. Then you can configure servers to automatically start a
systemd service for a `bore local` script alongside the minecraft server.

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

    services.minecraft-servers
}
```
