# Rift Nix Integration

Nix modules for using Rift with nix-darwin and Home Manager.

## Usage

### nix-darwin

In your main `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    rift.url = "github:YOUR_USERNAME/rift";  # or local path: path:/path/to/rift
  };

  outputs = { self, nixpkgs, darwin, rift, ... }:
  {
    darwinConfigurations."hostname" = darwin.lib.darwinSystem {
      modules = [
        rift.darwinModules.default
        
        {
          services.rift = {
            enable = true;
            
            # Basic settings
            settings = {
              animate = true;
              animation_duration = 0.3;
              focus_follows_mouse = true;
              mouse_follows_focus = true;
              hot_reload = true;
            };
            
            # Layout configuration
            layout = {
              mode = "traditional";
              gaps = {
                outer = { top = 5; left = 5; bottom = 5; right = 5; };
                inner = { horizontal = 5; vertical = 5; };
              };
            };
            
            # Virtual workspaces
            virtualWorkspaces = {
              enabled = true;
              default_workspace_count = 4;
              workspace_names = [ "main" "dev" "browser" "media" ];
            };
            
            # Application rules
            appRules = [
              { app_id = "com.apple.Safari"; workspace = 2; }
              { title_substring = "Preferences"; floating = true; }
            ];
            
            # Keybindings
            modifierCombinations = {
              comb1 = "Alt + Shift";
            };
            
            keybindings = {
              "Alt + H" = { move_focus = "left"; };
              "Alt + J" = { move_focus = "down"; };
              "Alt + K" = { move_focus = "up"; };
              "Alt + L" = { move_focus = "right"; };
              "Alt + 1" = { switch_to_workspace = 1; };
              "Alt + 2" = { switch_to_workspace = 2; };
              "comb1 + H" = { move_node = "left"; };
              "comb1 + J" = { move_node = "down"; };
              "comb1 + K" = { move_node = "up"; };
              "comb1 + L" = { move_node = "right"; };
            };
          };
        }
      ];
    };
  };
}
```

### Home Manager

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    rift.url = "github:YOUR_USERNAME/rift";
  };

  outputs = { self, nixpkgs, home-manager, rift, ... }:
  {
    homeConfigurations."username" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [
        rift.homeManagerModules.default
        
        {
          services.rift = {
            enable = true;
            # Same options as nix-darwin
          };
        }
      ];
    };
  };
}
```

### Using a Custom Config File

```nix
{
  services.rift = {
    enable = true;
    configFile = ./path/to/custom-config.toml;
  };
}
```

### Using the Overlay

```nix
{
  nixpkgs.overlays = [ rift.overlays.default ];
  
  # Now pkgs.rift is available
}
```

## Configuration Options

All configuration options are documented in `rift.default.toml`. The Nix module provides the following options:

- `services.rift.enable` - Enable Rift
- `services.rift.package` - The rift package to use
- `services.rift.settings` - Basic settings (animations, mouse behavior, etc.)
- `services.rift.layout` - Layout configuration (mode, gaps, etc.)
- `services.rift.ui` - UI configuration (menu bar, stack line, mission control)
- `services.rift.gestures` - Trackpad gestures configuration
- `services.rift.windowSnapping` - Window snapping configuration
- `services.rift.virtualWorkspaces` - Virtual workspaces configuration
- `services.rift.appRules` - Application rules for automatic window assignment
- `services.rift.modifierCombinations` - Named modifier combinations for keybindings
- `services.rift.keybindings` - Keyboard shortcuts
- `services.rift.configFile` - Path to a custom config file (overrides generated config)
