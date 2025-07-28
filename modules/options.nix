{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
in {
  options = {
    bore = {
      enable = mkEnableOption "bore proxy integration";

      address = mkOption {
        type = types.str;
        default = "bore.pub";
        description = ''
          Address of proxy server running `bore server`,
          which forwards all ingress traffic to local server running `bore local`.
        '';
      };

      secret = mkOption {
        type = types.str;
        default = "";
        description = ''
          Bore server secret used to authenticate tunnel connections.
          Omit if no secret is required.
        '';
      };

      proxy-port = mkOption {
        type = types.int;
        default = 25565;
        description = ''
          The port to open on the proxy server.
          When connecting to the server, player will supply this port.
          If the port is 25565, it can be omitted by the player.
          (e.g. `mc.myserver.com:25565` == `mc.myserver.com`)
        '';
      };

      local-port = mkOption {
        type = types.int;
        default = 25565;
        description = ''
          The port used locally to run the server on localhost. This is not exposed to the user
          and is instead only used internally via the bore tunneling service.
        '';
      };

      rcon-port = mkOption {
        type = types.int;
        default = 25575;
        description = ''
          The port to use to connect to RCON via localhost.
          This is not and SHOULD not be exposed to the user/public internet.
          Only connect to this by logging onto the server computer and then running RCON on localhost.

          (This option simply sets serverProperties."rcon.port".
          It is included in this module for type checking reasons.)
        '';
      };
    };
  };

  config = {
    serverProperties = {
      server-port = config.bore.local-port;
      "rcon.port" = lib.mkForce config.bore.rcon-port;
    };
  };
}
