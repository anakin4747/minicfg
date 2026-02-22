{
  description = "Neovim environment with LSPs and tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    # Add the neovim overlay input
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, neovim-nightly-overlay }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ neovim-nightly-overlay.overlays.default ];
      };
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "nvim-env";
        paths = with pkgs; [
          neovim
          autotools-language-server
          awk-language-server
          bash-language-server
          clang-tools
          cmake-language-server
          docker-language-server
          dot-language-server
          ginko
          git
          goose-cli
          gopls
          lazygit
          lua-language-server
          nil
          oelint-adv
          opencode
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
