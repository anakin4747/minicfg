{
  description = "language-server-bitbake from the vscode-bitbake extension";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "2.8.0";

      # The published .vsix is a ZIP that already contains the pre-built wasm files.
      vsix = pkgs.fetchurl {
        url = "https://github.com/yoctoproject/vscode-bitbake/releases/download/v${version}/yocto-bitbake-${version}.vsix";
        hash = "sha256-FCgZ3yG4WQGTxJ6Z9AFRycX7owUU9/1xrNzC1WjzvgA=";
      };

      vscode-bitbake-src = pkgs.fetchFromGitHub {
        owner = "yoctoproject";
        repo = "vscode-bitbake";
        rev = "a2fdba8e659778bdbc1f239ac9c6338e54401c60";
        hash = "sha256-xrMq8nZK3lUGl/w5NhR42YwETtTuwoFGhkvnjRQXoJk=";
      };

      # Server runtime node_modules (node-cache, vscode-languageserver, etc.)
      server-runtime-deps = pkgs.buildNpmPackage {
        pname = "language-server-bitbake-server-deps";
        inherit version;
        src = vscode-bitbake-src;
        sourceRoot = "source/server";
        npmDepsHash = "sha256-zZ5qLzVsjiMFT9pCMKz24/uVCRaT7VhOXkjpHabTSNQ=";
        nativeBuildInputs = with pkgs; [ pkg-config ];
        buildInputs = with pkgs; [ libsecret ];
        dontBuild = true;
        installPhase = ''
          mkdir -p $out
          cp -rL node_modules $out/
        '';
      };

      language-server-bitbake = pkgs.buildNpmPackage {
        pname = "language-server-bitbake";
        inherit version;

        src = vscode-bitbake-src;

        # Root npm deps (typescript, @types/node, @types/jest, etc.)
        npmDepsHash = "sha256-j1awkWOh+xuGzNdBra+QI6anpCVmD/YRYe3fzXRFYtY=";

        # Suppress postinstall which does nested `npm install` in server/ and client/,
        # and skip native addon builds (keytar etc.) not needed for the language server
        npmFlags = [ "--ignore-scripts" ];

        makeCacheWritable = true;

        nativeBuildInputs = with pkgs; [ typescript makeWrapper unzip ];

        buildPhase = ''
          ln -s ${server-runtime-deps}/node_modules server/node_modules
          tsc -b server
        '';

        installPhase = ''
          mkdir -p $out/bin $out/lib/language-server-bitbake

          cp -r server/out $out/lib/language-server-bitbake/out
          cp -r ${server-runtime-deps}/node_modules $out/lib/language-server-bitbake/node_modules

          # Extract pre-built wasm files from the release vsix (a ZIP archive)
          unzip -p ${vsix} extension/server/tree-sitter-bitbake.wasm \
            > $out/lib/language-server-bitbake/tree-sitter-bitbake.wasm
          unzip -p ${vsix} extension/server/tree-sitter-bash.wasm \
            > $out/lib/language-server-bitbake/tree-sitter-bash.wasm

          makeWrapper ${pkgs.nodejs}/bin/node $out/bin/language-server-bitbake \
            --add-flags $out/lib/language-server-bitbake/out/server.js
        '';
      };
    in {
      packages.${system} = {
        inherit language-server-bitbake;
        default = language-server-bitbake;
      };
    };
}
