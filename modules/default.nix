{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.services.minecraft-servers;
in {
  options = {
    services.minecraft-servers = {
      # Extend services.minecraft-servers.servers options
      servers = mkOption {
        type = types.attrsOf (types.submodule {
          imports = [./options.nix];
        });
      };

      allowDuplicatePorts = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Set to true to remove the assertions on duplicate ports across servers.
        '';
      };
    };
  };

  config = let
    extractLocalPorts = servers: lib.flatten (lib.mapAttrsToList (_: value: builtins.attrValues (lib.getAttrs ["local-port" "rcon-port"] value.bore)) servers);
    enabledServers = lib.filterAttrs (_: v: v.enable && v.bore.enable) cfg.servers;
  in {
    assertions = [
      {
        assertion = cfg.allowDuplicatePorts || lib.allUnique (extractLocalPorts enabledServers);
        message = ''
          nix-mc-bore: Detected duplicate values for ports in services.minecraft-servers.servers
          Ensure port types are unique across servers! To turn off this assertion,
          set `services.minecraft-servers.allowDuplicatePorts = true;`.
        '';
      }
    ];
    systemd.services =
      lib.mapAttrs' (name: value: let
        startScript = with value.bore; "${lib.getExe pkgs.bore-cli} local --to ${address} ${toString local-port} --port ${toString proxy-port} ${lib.optionalString (secret != "") "--secret ${secret}"}";
      in {
        name = "minecraft-server-${name}-bore";
        value = {
          description = "bore TCP tunnel service for ${name}";
          enable = true;
          after = [
            "network-online.target"
            "nss-lookup.target"
            "minecraft-server-${name}.service"
          ];

          requires = [
            "network-online.target"
            "nss-lookup.target"
            "minecraft-server-${name}.service"
          ];

          wantedBy = ["multi-user.target"];

          serviceConfig = {
            ExecStart = startScript;
            Restart = "on-failure";
            RestartSec = 10;
          };
        };
      })
      enabledServers;
  };
}
