{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.services.minecraft-servers;
  buildBoreService = lib.mapAttrs' (name: value: {
    name = "minecraft-server-${name}-bore";
    value = {
      description = "Service for starting bore tunnel for ${name}";
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
        ExecStart = with value; "${lib.getExe pkgs.bore-cli} local --to ${proxy-addr} ${toString local-port} --port ${toString proxy-port} ${lib.optionalString (proxy-secret != null) "--secret ${proxy-secret}"}";
        Restart = "on-failure";
        RestartSec = 10;
      };
    };
  });
in {
  options = {
    # Extend services.minecraft-servers.servers options
    services.minecraft-servers.servers = mkOption {
      type = types.attrsOf (types.submodule {
        imports = [./options.nix];
      });
    };
  };

  config = {
    assertions = builtins.map (
      port: {
        assertion =
          lib.allUnique
          (builtins.map (lib.getAttr port) (builtins.attrValues cfg.servers));
        message = "Detected duplicate values for ${port} in config.mc-servers. Ensure port types are unique across servers!";
      }
    ) ["rcon-port" "local-port" "proxy-port"];
    systemd.services = buildBoreService cfg.servers;
  };
}
