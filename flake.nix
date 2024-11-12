{
  description = "A daemon for the history feature of wl-screenrec";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    wl-screenrec-src = {
      url = "github:russelltg/wl-screenrec/russell/reconnect_on_lost_output";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      lib = nixpkgs.lib;
      systems = lib.systems.flakeExposed;
      pkgsFor = lib.genAttrs systems (system: import nixpkgs { inherit system; });
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
    in
    {
      packages = forEachSystem (pkgs: rec {
        wl-screenrec = pkgs.callPackage ./wl-screenrec.nix { inherit (inputs) wl-screenrec-src; };
        wl-screenrec-daemon = pkgs.writeShellApplication {
          name = "wl-screenrec-daemon";
          runtimeInputs = with pkgs; [
            wl-screenrec # should use the one from rec instead of from pkgs
            libnotify
            coreutils
          ];
          text = builtins.readFile ./wl-screenrec-daemon.sh;
        };
        default = wl-screenrec-daemon;
      });

      homeManagerModules = rec {
        wl-screenrec-daemon = import ./hm-module.nix self;
        default = wl-screenrec-daemon;
      };
    };
}
