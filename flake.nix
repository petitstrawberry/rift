{
  description = "Rift - A tiling window manager for macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    let
      toTOML = import ./lib/to-toml.nix;

      supportedSystems = [ "aarch64-darwin" "x86_64-darwin" ];

      mkRiftPackage = pkgs: pkgs.rustPlatform.buildRustPackage {
        pname = "rift";
        version = "0.1.0";

        src = ./.;

        cargoLock = {
          lockFile = ./Cargo.lock;
          outputHashes = {
            "continue-0.1.1" = "sha256-1k2mwp81fzblr27f4mrxs1scrsq96w4gg8f15b4dq2pszhys0bzi=";
            "dispatchr-1.0.0" = "sha256-0ac23sayzajx8kmn2dl0k0f25qbpb9kvrx7xv2r9jvir61s8zzhd=";
          };
        };

        nativeBuildInputs = with pkgs; [ pkg-config ];

        meta = with pkgs.lib; {
          description = "A tiling window manager for macOS";
          homepage = "https://github.com/acsandmann/rift";
          license = licenses.mit;
          platforms = platforms.darwin;
          mainProgram = "rift";
        };
      };

      rustToolchain = pkgs: pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" "rust-analyzer" ];
      };
    in
    {
      overlays.default = final: prev: {
        rift = mkRiftPackage final;
      };

      darwinModules.default = { config, lib, pkgs, ... }: {
        imports = [ (import ./darwin-module.nix { inherit lib toTOML; }) ];
        config = lib.mkIf config.services.rift.enable {
          services.rift.package = lib.mkDefault (mkRiftPackage pkgs);
        };
      };

      homeManagerModules.default = { config, lib, pkgs, ... }: {
        imports = [ (import ./home-manager-module.nix { inherit lib toTOML; }) ];
        config = lib.mkIf config.services.rift.enable {
          services.rift.package = lib.mkDefault (mkRiftPackage pkgs);
        };
      };
    } // flake-utils.lib.eachSystem supportedSystems (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        riftPackage = mkRiftPackage pkgs;
      in
      {
        packages = {
          default = riftPackage;
          rift = riftPackage;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            (rustToolchain pkgs)
            cargo-watch
            cargo-edit
            pkg-config
          ];
          env = {
            RUST_SRC_PATH = "${rustToolchain pkgs}/lib/rustlib/src/rust/library";
          };
        };
      }
    );
}
