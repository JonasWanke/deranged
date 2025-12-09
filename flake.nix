{
  inputs = {
    # https://github.com/NixOS/nixpkgs/pull/462771
    nixpkgs.url = "github:nixos/nixpkgs?ref=52e1f2d2594441e36a637d3d9e79cd30426b200a";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = with pkgs; mkShell { buildInputs = [ dart ]; };
      }
    );
}
