{
  description = "Nix module for Minecraft + Bore TCP tunnel integration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = _: {
    nixosModules.nix-minecraft-bore = ./module.nix;
  };
}
