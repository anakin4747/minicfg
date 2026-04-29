{
  description = "language-server-bitbake from the vscode-bitbake extension";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      tree-sitter-bitbake = pkgs.tree-sitter.buildGrammar {
        language = "bitbake";
        version = "0-unstable";
        src = pkgs.fetchFromGitHub {
          owner = "idillon-sfl";
          repo = "tree-sitter-bitbake";
          rev = "bc577daab90b551ad1dc42c3373db2cb7c43857d";
          hash = "";
        };
      };

      vscode-bitbake-src = pkgs.fetchFromGitHub {
        owner = "yoctoproject";
        repo = "vscode-bitbake";
        rev = "a2fdba8e659778bdbc1f239ac9c6338e54401c60";
        hash = "";
      };

      language-server-bitbake = pkgs.buildNpmPackage {
        pname = "language-server-bitbake";
        version = "2.8.0";

        src = vscode-bitbake-src;

        npmDepsHash = "";

        makeCacheWritable = true;

        nativeBuildInputs = with pkgs; [ typescript ];

        buildPhase = ''
          npm run compile
        '';

        installPhase = ''
          mkdir -p $out/bin $out/lib/language-server-bitbake

          cp -r server/out $out/lib/language-server-bitbake/out
          cp -r server/node_modules $out/lib/language-server-bitbake/node_modules

          cp ${tree-sitter-bitbake}/parser $out/lib/language-server-bitbake/tree-sitter-bitbake.wasm
          cp ${pkgs.tree-sitter-grammars.tree-sitter-bash}/parser $out/lib/language-server-bitbake/tree-sitter-bash.wasm

          cat > $out/bin/language-server-bitbake <<EOF
          #!${pkgs.nodejs}/bin/node
          require('$out/lib/language-server-bitbake/out/server.js');
          EOF
          chmod +x $out/bin/language-server-bitbake
        '';
      };
    in {
      packages.${system} = {
        inherit language-server-bitbake;
        default = language-server-bitbake;
      };
    };
}
