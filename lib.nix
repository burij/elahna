{ pkgs ? import
    (fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.11")
    { config = { }; overlays = [ ]; }
}:

let
  lib = pkgs.lib;



  appName = "elahna";
  appVersion = lib.strings.fileContents ./VERSION;
  appPort = 8151;
  appUser = "elahna"; # change to your username, if content outside src
  appGroup = "users";

  contentHostPath = "/srv/config/${appName}/${appVersion}/priv/content";
  secretHostPath = "/srv/secrets/${appName}/phoenix_secret";

  elixirAppName = "elahna";

  elixirEnv = with pkgs; [
    elixir
    erlang
  ];

  beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang;

  dependencies = with pkgs; [
    wget
    nixpkgs-fmt
    openssl
  ];

  shell = pkgs.mkShell {
    buildInputs = elixirEnv ++ dependencies;
    shellHook = ''
      cp ./README.md ./priv/content/readme.md

      if [ -z "$SECRET_KEY_BASE" ]; then
        export SECRET_KEY_BASE=$(mix phx.gen.secret 2>/dev/null || \
          echo "dev_secret_fallback_for_local_only")
      fi

      alias run='mix phx.server'
      alias form='nixpkgs-fmt lib.nix; mix format'
      alias test='PHX_SERVER=true CONTENT_PATH=./priv/content \
        ./result/bin/elahna start'
      alias newkey='mkdir -p $(dirname ${secretHostPath}); \
        openssl rand -base64 64 | \
        tee ${secretHostPath} > /dev/null &&
        chmod 600 ${secretHostPath}'
    '';
  };

  package = beamPackages.mixRelease {
    pname = appName;
    version = appVersion;
    src = ./.;
    removeCookie = false;
    env = {
      HOME = "/tmp";
    };
  };

  container = { config, lib, pkgs, ... }: {
    containers.${appName} = {
      autoStart = true;
      privateNetwork = false;
      privateUsers = "pick";
      hostAddress = "10.0.0.1";
      localAddress = "10.0.0.2";

      bindMounts = {
        "${appName}-content" = {
          hostPath = contentHostPath;
          mountPoint = "/var/www/content";
          isReadOnly = false;
        };
        "${appName}-secret" = {
          hostPath = secretHostPath;
          mountPoint = "/etc/${appName}/secret_key";
          isReadOnly = true;
        };
      };

      config = { config, pkgs, ... }: {
        system.stateVersion = "25.11";

        environment.systemPackages = with pkgs; [
          package
        ];

        systemd.services."${appName}" = {
          description = "${appName} - Phoenix HTMX Server";

          script = ''

            export SECRET_KEY_BASE=$(cat /etc/${appName}/secret_key)
            export RELEASE_DISTRIBUTION=name
            export RELEASE_NODE="${appName}@127.0.0.1"
            exec ${package}/bin/${elixirAppName} start
          '';

          environment = {
            PHX_SERVER = "true";
            CONTENT_PATH = "/var/www/content";
            PORT = toString appPort;
            PHX_URL_PORT = toString appPort;
            PHX_URL_SCHEME = "http";
            PHX_HOST = "localhost";
          };
          serviceConfig = {
            Restart = "always";
            RestartSec = 10;
            WorkingDirectory = "/var/www/content";
            User = appUser;
            Group = appGroup;
          };
          wantedBy = [ "multi-user.target" ];
        };

        systemd.tmpfiles.rules = [
          "d /var/www/content 0755 ${appUser} ${appGroup}"
        ];

        users.users.${appUser} = lib.mkDefault {
          isSystemUser = true;
          group = appGroup;
        };
        users.groups.${appGroup} = lib.mkDefault { };

        networking.firewall.allowedTCPPorts = [ appPort ];
      };
    };
  };

in
{ shell = shell; package = package; container = container; }