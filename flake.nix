{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    unf.url = "git+https://git.atagen.co/atagen/unf";
  };

  outputs = inputs @ {self, ...}: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {inherit system;};
  in {
    # NixOS module
    nixosModules.minecraft-servers = ./modules;

    # Doc generation
    packages.${system}.docs = pkgs.callPackage inputs.unf.lib.pak-chooie {
      inherit self;
      projectName = "nix-mc-bore";
      newPath = "https://github.com/zSuperx/nix-mc-bore";
      modules = [./modules];
    };
  };
}
