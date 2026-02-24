
BIN_DIR = /usr/local/bin

.PHONY: help # print this help
help:
	@./scripts/list-targets $(MAKEFILE_LIST)

.PHONY: install # install nvim, config, scripts, deps
install: install-deps
	rm -f ~/.config/nvim
	ln -snf $(CURDIR) ~/.config/nvim

.PHONY: uninstall # uninstall everything
uninstall: uninstall-deps
	rm -f ~/.config/nvim
	sudo rm -rf \
		/usr/local/share/nvim \
		$(BIN_DIR)/nvim

# Dependencies {{{

NPM_PACKAGES = language-server-bitbake

PACMAN_PACKAGES = words

.PHONY: install-deps # install lsps, linters, cli tools
install-deps:
	nix profile add .\#default
	sudo npm isnt -g $(NPM_PACKAGES)
	sudo pacman -S --noconfirm $(PACMAN_PACKAGES)

.PHONY: uninstall-deps # uninstall lsps, linters, cli tools
uninstall-deps:
	-nix profile remove .\#default
	-sudo npm uninstall -g $(NPM_PACKAGES)

# }}}

