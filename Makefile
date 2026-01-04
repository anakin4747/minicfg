NVIM = neovim/build/bin/nvim

.PHONY: install
install: $(NVIM)
	-unlink ~/.config/nvim
	ln -s $(CURDIR) ~/.config/nvim
	sudo $(MAKE) -C neovim install

.PHONY: uninstall
uninstall:
	unlink ~/.config/nvim
	sudo rm -rf /usr/local/bin/nvim /usr/local/share/nvim

$(NVIM):
	git submodule update --init --recursive --force
	$(MAKE) -C neovim -j$(nproc)
