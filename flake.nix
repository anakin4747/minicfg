{
  description = "Neovim environment with LSPs and tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    kconfig-language-server = {
        url = "github:anakin4747/kconfig-language-server";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, neovim-nightly-overlay, kconfig-language-server }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ neovim-nightly-overlay.overlays.default ];
      };
      scripts = pkgs.stdenv.mkDerivation {
        name = "scripts";
        src = ./scripts;
        installPhase = ''
          mkdir -p $out/bin
          find . -maxdepth 1 -type f -executable -exec ln -s $src/{} $out/bin/{} \;
        '';
      };
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "nvim-env";
        paths = with pkgs; [
          scripts
          neovim
          autotools-language-server
          awk-language-server
          bash-language-server
          clang-tools
          cmake-language-server
          docker-language-server
          dot-language-server
          ginko
          gopls
          kconfig-language-server.packages.${system}.default
          lazygit
          lua-language-server
          nil
          oelint-adv
          psmisc
          pyright
          rust-analyzer
          shellcheck
          shfmt
          systemd-language-server
          texlab
          tinymist
          tree-sitter
          typescript-language-server
          wl-clipboard
          xdg-utils
          yaml-language-server
        ];
      };
    };
}
