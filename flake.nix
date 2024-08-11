{
  description = "A daemon for the history feature of wl-screenrec";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  outputs =
    { nixpkgs, ... }@inputs:
    let
      lib = nixpkgs.lib;
      systems = lib.systems.flakeExposed;
      pkgsFor = lib.genAttrs systems (system: import nixpkgs { inherit system; });
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
    in
    {
      packages = forEachSystem (pkgs: rec {
        wl-screenrec-daemon = pkgs.writeShellApplication {
          name = "wl-screenrec-daemon";
          runtimeInputs = with pkgs; [
            wl-screenrec
            libnotify
          ];
          text = builtins.readFile ./wl-screenrec-daemon.sh;
        };
        default = wl-screenrec-daemon;
      });
    };
}
