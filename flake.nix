{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.rustc
          pkgs.cargo
          pkgs.ocaml
          pkgs.dune_3
          pkgs.ocamlPackages.ocaml-lsp
          pkgs.ocamlPackages.ocamlformat
          pkgs.fish
        ];
        shellHook = ''
          echo "poc-compiler-unsafe: $(rustc --version) + $(ocaml -version)"
        '';
      };
    };
}
