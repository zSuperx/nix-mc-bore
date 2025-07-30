{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    unf.url = "git+https://git.atagen.co/atagen/unf";
  };

  outputs = inputs @ {self, ...}: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {inherit system;};
  in {
    nixosModules.minecraft-servers = ./modules;

    packages.${system}.docs = inputs.unf.lib.html {
      inherit self pkgs;
      projectName = "nix-mc-bore";
      newPath = "https://github.com/zSuperx/nix-mc-bore";
      modules = [
        ./modules
      ];
      userOpts = {
        warningsAreErrors = false;
      };
    };
  };
}
