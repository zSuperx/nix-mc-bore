{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.services.minecraft-servers;
  containsDuplicateAttrValue = attrSet: name:
    !(
      lib.allUnique
      (builtins.map (lib.getAttr name) (lib.collect (x: x ? ${name}) attrSet))
    );
  duplicateErrorMessage = name: builtins.throw "Detected duplicate values for ${name} in config.mc-servers. Ensure port types are unique across servers!";

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

  config =
    if containsDuplicateAttrValue cfg.servers "rcon-port"
    then duplicateErrorMessage
    else {
      systemd.services = buildBoreService cfg.servers;
    };
}
