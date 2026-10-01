{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.usbguard;

  policy = (
    lib.types.enum [
      "allow"
      "block"
      "reject"
      "keep"
      "apply-policy"
    ]
  );
in
{
  options.services.usbguard = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable usbguard as a system service.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.usbguard;
      defaultText = lib.literalExpression "pkgs.usbguard";
      description = ''
        The package to use for `usbguard`.
      '';
    };

	rules = {
      file = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = "/var/lib/usbguard/rules.conf";
          example = "/run/scarySecretRules.conf";
          description = ''
            This tells the usbguard which file to load as policy rule set.

            The file can be changed manually or via the IPC interface assuming it has the right file permissions.

            For more details see {manpage}`usbguard-rules.conf(5)`.
          '';
      };

      text = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
        example = ''
          allow with-interface equals { 08:*:* }
        '';
        description = ''
          Usbguard will load this as the policy ruleset.
          As these rules are finix managed they are immutable and can't
          be changed by the IPC interface.

          If you do not set this option, the usbguard will load
          it's policy rule set from the option configured in `services.usbguard.rules.file`.

          Running `usbguard generate-policy` as root will
          generate a config for your currently plugged in devices.

          For more details see {manpage}`usbguard-rules.conf(5)`.
        '';
      };
	};

    policies = {
      deviceNotMatching = lib.mkOption {
        type = lib.types.enum [
          "allow"
          "block"
          "reject"
        ];
        default = "block";
        description = ''
          How to treat USB devices that don't match any rule in the policy.
          Target should be one of allow, block or reject (logically remove the
          device node from the system).
        '';
      };

      deviceAlreadyPresent = lib.mkOption {
        type = policy;
        default = "apply-policy";
        description = ''
          How to treat USB devices that are already connected when usbguard
          starts. Policy should be one of allow, block, reject, keep (keep
          whatever state the device is currently in) or apply-policy (evaluate
          the rule set for every present device).
        '';
      };

      controllerAlreadyPresent = lib.mkOption {
        type = policy;
        default = "keep";
        description = ''
          How to treat USB controller devices that are already connected when
          usbguard starts. One of allow, block, reject, keep or apply-policy.
        '';
      };

      deviceInserted = lib.mkOption {
        type = lib.types.enum [
          "block"
          "reject"
          "apply-policy"
        ];
        default = "apply-policy";
        description = ''
          How to treat USB devices that are already connected after usbguard
          starts. One of block, reject, apply-policy.
        '';
      };
	};
    restoreControllerDeviceState = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Usbguard modifies some attributes of controller
        devices like the default authorization state of new child device
        instances. Using this setting, you can control whether usbguard
        will try to restore the attribute values to the state before
        modification on shutdown.
      '';
    };

    IPCAllowedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "root" ];
      example = [
        "root"
        "yourusername"
      ];
      description = ''
        A list of usernames that the daemon will accept IPC connections from.
      '';
    };

    IPCAllowedGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "wheel" ];
      description = ''
        A list of groupnames that the daemon will accept IPC connections
        from.
      '';
    };

    deviceRulesWithPort = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Generate device specific rules including the "via-port" attribute.
      '';
    };

	dbus.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable usbguard dbus daemon.
      '';
    };
  };
  config = lib.mkIf cfg.enable {

  };
}
