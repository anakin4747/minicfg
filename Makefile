
BIN_DIR = /usr/local/bin
NVIM = neovim/build/bin/nvim

SCRIPT_TARGETS := $(patsubst scripts/%, $(BIN_DIR)/%, $(wildcard scripts/*))

.PHONY: help # print this help
help:
	@./scripts/list-targets $(MAKEFILE_LIST)

.PHONY: install # install nvim, config, scripts, deps
install: $(NVIM) $(SCRIPT_TARGETS) install-deps
	rm -f ~/.config/nvim
	ln -snf $(CURDIR) ~/.config/nvim
	sudo $(MAKE) CMAKE_BUILD_TYPE=Release -C neovim install

.PHONY: uninstall # uninstall everything
uninstall: uninstall-deps
	rm -f ~/.config/nvim
	sudo rm -rf \
		/usr/local/share/nvim \
		$(BIN_DIR)/nvim \
		$(SCRIPT_TARGETS)

$(BIN_DIR)/%: $(CURDIR)/scripts/%
	sudo ln -snf "$<" "$@"

$(NVIM):
	git submodule update --init --recursive --force
	$(MAKE) CMAKE_BUILD_TYPE=Release -C neovim -j$(shell nproc)

# Dependencies {{{

NIX_PACKAGES = \
	autotools-language-server \
	awk-language-server \
	bash-language-server \
	clang-tools \
	cmake-language-server \
	docker-language-server \
	dot-language-server \
	ginko \
	git \
	goose-cli \
	gopls \
	lazygit \
	lua-language-server \
	nil \
	oelint-adv \
	opencode \
	psmisc \
	pyright \
	rust-analyzer \
	shellcheck \
	shfmt \
	systemd-language-server \
	texlab \
	tinymist \
	tree-sitter \
	typescript-language-server \
	wl-clipboard \
	xdg-utils \
	yaml-language-server

NPM_PACKAGES = language-server-bitbake

PACMAN_PACKAGES = words

.PHONY: install-deps # install lsps, linters, cli tools
install-deps:
	nix profile add $(foreach pkg,$(NIX_PACKAGES),nixpkgs\#$(pkg))
	sudo npm isnt -g $(NPM_PACKAGES)
	sudo pacman -S --noconfirm $(PACMAN_PACKAGES)

	if [ ! -d /opt/kconfig-language-server ]; then \
		sudo git clone --depth 1 \
			https://github.com/anakin4747/kconfig-language-server \
			/opt/kconfig-language-server; \
	fi
	sudo $(MAKE) PREFIX=/usr -C /opt/kconfig-language-server install

.PHONY: uninstall-deps # uninstall lsps, linters, cli tools
uninstall-deps:
	-nix profile remove $(NIX_PACKAGES)
	-sudo npm uninstall -g $(NPM_PACKAGES)
	-sudo $(MAKE) -C /opt/kconfig-language-server uninstall
	-sudo rm -rf /opt/kconfig-language-server

# }}}

