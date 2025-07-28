{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options = {
    proxy-addr = mkOption {
      type = types.str;
      description = "Address of proxy server, which forwards all ingress traffic to local server.";
    };

    proxy-secret = mkOption {
      type = types.str;
      description = "Bore server secret used to authenticate tunnel connections.";
    };

    proxy-port = mkOption {
      type = types.int;
      default = 25565;
      description = ''
        The port to open on the proxy server.
        When connecting to the server, users will supply this port.
        If the port is 25565, it can be omitted by the user.
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
      '';
    };

    rcon-password = mkOption {
      type = types.str;
      default = "consolepass";
      description = ''
        The password used to log into the server RCON.
      '';
    };
  };

  config = {
    serverProperties = {
      server-port = config.local-port;
      enable-rcon = true;

      "rcon.port" = config.rcon-port;
      "rcon.password" = config.rcon-password;
    };
  };
}
