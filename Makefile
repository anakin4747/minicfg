
BIN_DIR = /usr/local/bin
NVIM = neovim/build/bin/nvim

SCRIPT_TARGETS := $(patsubst scripts/%, $(BIN_DIR)/%, $(wildcard scripts/*))

.PHONY: install uninstall

install: $(NVIM) $(SCRIPT_TARGETS) install-servers
	rm -f ~/.config/nvim
	ln -snf $(CURDIR) ~/.config/nvim
	sudo $(MAKE) CMAKE_BUILD_TYPE=Release -C neovim install

uninstall:
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

PACMAN_PACKAGES = \
	bash-language-server \
	clang \
	gopls \
	lua-language-server \
	pyright \
	rust-analyzer \
	tinymist \
	typescript-language-server \
	yaml-language-server

YAY_PACKAGES = \
	autotools-language-server \
	cmake-language-server \
	docker-language-server-bin \
	nil-git

NPM_PACKAGES = \
	@ansible/ansible-language-server \
	awk-language-server \
	devicetree-language-server \
	dot-language-server \
	language-server-bitbake

.PHONY: install-servers
install-servers: install-pacman-servers install-yay-servers install-npm-servers install-kconfig-language-server

.PHONY: install-pacman-servers
install-pacman-servers:
	sudo pacman -S --noconfirm --needed $(PACMAN_PACKAGES)

.PHONY: install-yay-servers
install-yay-servers:
	yay -S --noconfirm --needed $(YAY_PACKAGES)

.PHONY: install-npm-servers
install-npm-servers:
	sudo npm install -g $(NPM_PACKAGES)

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
	-sudo pacman -Rns --noconfirm $(PACMAN_PACKAGES)
	-yay -Rns --noconfirm $(YAY_PACKAGES)
	-sudo npm uninstall -g $(NPM_PACKAGES)
	-sudo $(MAKE) -C /opt/kconfig-language-server uninstall
	-sudo rm -rf /opt/kconfig-language-server

# }}}
