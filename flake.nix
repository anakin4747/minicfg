{
  description = "Neovim environment with LSPs and tools";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.buildEnv {
      name = "nvim-env";
      paths = with nixpkgs.legacyPackages.x86_64-linux; [
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
