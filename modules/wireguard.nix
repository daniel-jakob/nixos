{ config, lib, ... }:
let
  cfg = config.networking.homelabWireguard;

  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    optionalAttrs
    types
    ;

  isServer = cfg.role == "server";
  isClient = cfg.role == "client";

  mkPeer =
    peer:
    {
      inherit (peer) publicKey allowedIPs;
    }
    // optionalAttrs (peer.endpoint != null) {
      endpoint = peer.endpoint;
    }
    // optionalAttrs (peer.persistentKeepalive != null) {
      persistentKeepalive = peer.persistentKeepalive;
    }
    // optionalAttrs (peer.presharedKeyFile != null) {
      presharedKeyFile = peer.presharedKeyFile;
    };

  splitTunnelAllowedIPs = lib.unique (cfg.client.splitTunnelCIDRs ++ [ cfg.vpnSubnet ]);

  clientAllowedIPs =
    if cfg.client.allowedIPs != null then
      cfg.client.allowedIPs
    else if cfg.client.routeAllTraffic then
      [ "0.0.0.0/0" "::/0" ]
    else
      splitTunnelAllowedIPs;

  privateKeyPath =
    if cfg.privateKeyFile != null then
      cfg.privateKeyFile
    else if cfg.privateKeySopsKey != null then
      config.sops.secrets.${cfg.privateKeySopsKey}.path
    else
      null;

  clientPrimaryPeer =
    {
      publicKey = cfg.client.serverPublicKey;
      endpoint = cfg.client.endpoint;
      allowedIPs = clientAllowedIPs;
    }
    // optionalAttrs (cfg.client.persistentKeepalive != null) {
      persistentKeepalive = cfg.client.persistentKeepalive;
    };
in
{
  options.networking.homelabWireguard = {
    enable = mkEnableOption "homelab WireGuard profile";

    role = mkOption {
      type = types.enum [ "server" "client" ];
      default = "client";
      description = "Run WireGuard as VPN server or client.";
    };

    interface = mkOption {
      type = types.str;
      default = "wg0";
      description = "WireGuard interface name.";
    };

    vpnSubnet = mkOption {
      type = types.str;
      default = "10.100.0.0/24";
      description = "VPN subnet CIDR.";
    };

    address = mkOption {
      type = types.str;
      description = "Address assigned to this host on the WireGuard interface, including CIDR.";
      example = "10.100.0.1/24";
    };

    listenPort = mkOption {
      type = types.port;
      default = 51820;
      description = "WireGuard listen port (server mode).";
    };

    privateKeyFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to WireGuard private key file.";
      example = "/etc/wireguard/server_private.key";
    };

    privateKeySopsKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "sops secret key name containing the WireGuard private key.";
      example = "wireguard_server_private_key";
    };

    server = {
      enableNAT = mkOption {
        type = types.bool;
        default = true;
        description = "Enable NAT for traffic coming from WireGuard clients.";
      };

      externalInterface = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Interface used for NAT egress.";
      };

      trustInterface = mkOption {
        type = types.bool;
        default = true;
        description = "Mark the WireGuard interface as trusted in the firewall.";
      };

      peers = mkOption {
        type =
          types.listOf (types.submodule {
            options = {
              publicKey = mkOption {
                type = types.str;
                description = "Peer public key.";
              };
              allowedIPs = mkOption {
                type = types.listOf types.str;
                description = "IP ranges routed to this peer.";
              };
              endpoint = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Peer endpoint (optional, useful for roaming peers).";
              };
              persistentKeepalive = mkOption {
                type = types.nullOr types.int;
                default = null;
                description = "Persistent keepalive in seconds.";
              };
              presharedKeyFile = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Path to preshared key file.";
              };
            };
          });
        default = [ ];
        description = "Server peers.";
      };
    };

    client = {
      endpoint = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Server endpoint in host:port format.";
      };

      serverPublicKey = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "VPN server public key.";
      };

      persistentKeepalive = mkOption {
        type = types.nullOr types.int;
        default = 25;
        description = "Persistent keepalive in seconds.";
      };

      routeAllTraffic = mkOption {
        type = types.bool;
        default = false;
        description = "Use full tunnel (0.0.0.0/0, ::/0).";
      };

      splitTunnelCIDRs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "CIDRs to route through the VPN for split tunnel mode.";
      };

      allowedIPs = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description = "Explicit allowedIPs for the server peer. Overrides routeAllTraffic/splitTunnelCIDRs logic.";
      };

      extraPeers = mkOption {
        type =
          types.listOf (types.submodule {
            options = {
              publicKey = mkOption {
                type = types.str;
                description = "Peer public key.";
              };
              allowedIPs = mkOption {
                type = types.listOf types.str;
                description = "IP ranges routed to this peer.";
              };
              endpoint = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Peer endpoint.";
              };
              persistentKeepalive = mkOption {
                type = types.nullOr types.int;
                default = null;
                description = "Persistent keepalive in seconds.";
              };
              presharedKeyFile = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Path to preshared key file.";
              };
            };
          });
        default = [ ];
        description = "Additional peers for advanced client setups.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = (cfg.privateKeyFile != null) != (cfg.privateKeySopsKey != null);
          message = "Set exactly one of networking.homelabWireguard.privateKeyFile or privateKeySopsKey.";
        }
        {
          assertion = !isServer || !cfg.server.enableNAT || cfg.server.externalInterface != null;
          message = "networking.homelabWireguard.server.externalInterface is required when server.enableNAT = true.";
        }
        {
          assertion = !isClient || cfg.client.endpoint != null;
          message = "networking.homelabWireguard.client.endpoint is required in client mode.";
        }
        {
          assertion = !isClient || cfg.client.serverPublicKey != null;
          message = "networking.homelabWireguard.client.serverPublicKey is required in client mode.";
        }
      ];

      sops.secrets = optionalAttrs (cfg.privateKeySopsKey != null) {
        ${cfg.privateKeySopsKey} = {
          owner = "root";
          group = "root";
          mode = "0400";
        };
      };

      networking.wireguard.interfaces.${cfg.interface} =
        {
          ips = [ cfg.address ];
          privateKeyFile = privateKeyPath;
          peers =
            if isServer then
              map mkPeer cfg.server.peers
            else
              [ clientPrimaryPeer ] ++ map mkPeer cfg.client.extraPeers;
        }
        // optionalAttrs isServer {
          listenPort = cfg.listenPort;
        };
    }

    (mkIf isServer {
      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
      };

      networking.firewall = {
        allowedUDPPorts = [ cfg.listenPort ];
        trustedInterfaces = lib.optionals cfg.server.trustInterface [ cfg.interface ];
      };

      networking.nat = mkIf cfg.server.enableNAT {
        enable = true;
        internalInterfaces = [ cfg.interface ];
        externalInterface = cfg.server.externalInterface;
      };
    })
  ]);
}
