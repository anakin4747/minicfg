
BIN_DIR = /usr/local/bin
NVIM = neovim/build/bin/nvim

SCRIPT_TARGETS := $(patsubst scripts/%, $(BIN_DIR)/%, $(wildcard scripts/*))

.PHONY: install uninstall

install: $(NVIM) $(SCRIPT_TARGETS)
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

SERVERS = \
	bash-language-server \
	clangd \
	kconfig-language-server \
	language-server-bitbake \
	lua-language-server \
	rust-analyzer

.PHONY: install-servers
install-servers: $(addprefix /usr/bin/,$(SERVERS))

.PHONY: uninstall-servers
uninstall-servers:
	-sudo pacman -Rns --noconfirm \
		lua-language-server \
		bash-language-server \
		clang \
		rust-analyzer
	-sudo npm uninstall -g language-server-bitbake
	-sudo $(MAKE) -C /opt/kconfig-language-server uninstall

/usr/bin/lua-language-server:
	sudo pacman -S --noconfirm lua-language-server

/usr/bin/bash-language-server:
	sudo pacman -S --noconfirm bash-language-server

/usr/bin/clangd:
	sudo pacman -S --noconfirm clang

/usr/bin/rust-analyzer:
	sudo pacman -S --noconfirm rust-analyzer

/usr/bin/gopls:
	sudo pacman -S --noconfirm gopls

/usr/bin/pyright:
	sudo pacman -S --noconfirm pyright

/usr/bin/docker-language-server:
	yay -S --noconfirm docker-language-server-bin

/usr/bin/cmake-language-server:
	yay -S --noconfirm cmake-language-server

/usr/bin/nil:
	yay -S --noconfirm nil-git

/usr/bin/autotools-language-server:
	yay -S --noconfirm autotools-language-server

/usr/bin/devicetree-language-server:
	sudo npm isnt -g devicetree-language-server

/usr/bin/language-server-bitbake:
	sudo npm isnt -g language-server-bitbake

/usr/bin/ansible-language-server:
	sudo npm isnt -g @ansible/ansible-language-server

/usr/bin/awk-language-server:
	sudo npm isnt -g awk-language-server

/usr/bin/kconfig-language-server:
	sudo git clone --depth 1 \
		https://github.com/anakin4747/kconfig-language-server \
		/opt/kconfig-language-server
	sudo $(MAKE) PREFIX=/usr -C /opt/kconfig-language-server install
