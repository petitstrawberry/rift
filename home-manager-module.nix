{ lib, toTOML }:

{ config, pkgs, ... }:

let
  cfg = config.services.rift;
  
  riftConfig = lib.filterAttrsRecursive (n: v: v != null && v != { }) {
    settings = cfg.settings // {
      layout = cfg.layout;
      ui = cfg.ui;
      gestures = cfg.gestures;
      window_snapping = cfg.windowSnapping;
    };
    virtual_workspaces = cfg.virtualWorkspaces;
    app_rules = cfg.appRules;
    modifier_combinations = cfg.modifierCombinations;
    keys = cfg.keybindings;
  };
  
  configFile = if cfg.configFile != null 
    then cfg.configFile 
    else pkgs.writeText "rift-config.toml" (toTOML { inherit lib; } riftConfig);
in
{
  options.services.rift = {
    enable = lib.mkEnableOption "Rift - A tiling window manager for macOS";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The rift package to use.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Rift settings configuration.";
    };

    layout = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Layout configuration.";
    };

    ui = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "UI configuration.";
    };

    gestures = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Trackpad gestures configuration.";
    };

    windowSnapping = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Window snapping configuration.";
    };

    virtualWorkspaces = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Virtual workspaces configuration.";
    };

    appRules = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "Application rules for automatic window assignment.";
    };

    modifierCombinations = lib.mkOption {
      type = lib.types.attrs;
      default = { comb1 = "Alt + Shift"; };
      description = "Named modifier combinations for reuse in keybindings.";
    };

    keybindings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Key bindings for rift commands.";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional path to a custom config file.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/rift/config.toml".source = configFile;
    
    launchd.agents.rift = {
      enable = true;
      config = {
        ProgramArguments = [ "${cfg.package}/bin/rift" ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/rift.log";
        StandardErrorPath = "/tmp/rift.log";
      };
    };
  };
}
