
BIN_DIR = /usr/local/bin
NVIM = neovim/build/bin/nvim

SCRIPT_TARGETS := $(patsubst scripts/%, $(BIN_DIR)/%, $(wildcard scripts/*))

.PHONY: install uninstall

install: $(NVIM) $(SCRIPT_TARGETS) install-servers
	rm -f ~/.config/nvim
	ln -snf $(CURDIR) ~/.config/nvim
	sudo $(MAKE) CMAKE_BUILD_TYPE=Release -C neovim install

uninstall: uninstall-servers
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

# Language Servers {{{

NIX_PACKAGES = \
	autotools-language-server \
	awk-language-server \
	bash-language-server \
	clang-tools \
	cmake-language-server \
	docker-language-server \
	dot-language-server \
	goose-cli \
	gopls \
	lua-language-server \
	nil \
	opencode \
	pyright \
	rust-analyzer \
	shellcheck \
	shfmt \
	systemd-language-server \
	tinymist \
	texlab \
	tmux \
	tree-sitter \
	typescript-language-server \
	xdg-utils \
	yaml-language-server

NPM_PACKAGES = \
	devicetree-language-server \
	language-server-bitbake

.PHONY: install-servers
install-servers: install-nix-servers install-npm-servers install-kconfig-language-server

.PHONY: install-nix-servers
install-nix-servers:
	nix profile add $(foreach pkg,$(NIX_PACKAGES),nixpkgs\#$(pkg))

.PHONY: install-npm-servers
install-npm-servers:
	sudo npm isnt -g $(NPM_PACKAGES)

.PHONY: install-kconfig-language-server
install-kconfig-language-server:
	if [ ! -d /opt/kconfig-language-server ]; then \
		sudo git clone --depth 1 \
			https://github.com/anakin4747/kconfig-language-server \
			/opt/kconfig-language-server; \
	fi
	sudo $(MAKE) PREFIX=/usr -C /opt/kconfig-language-server install

.PHONY: uninstall-servers
uninstall-servers:
	-nix profile remove $(NIX_PACKAGES)
	-sudo npm uninstall -g $(NPM_PACKAGES)
	-sudo $(MAKE) -C /opt/kconfig-language-server uninstall
	-sudo rm -rf /opt/kconfig-language-server

# }}}

