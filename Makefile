DESTDIR ?=
PREFIX ?= /usr/local

NVIM = neovim/build/bin/nvim
SCRIPTS := $(wildcard $(CURDIR)/scripts/*)
SCRIPT_TARGETS := $(patsubst $(CURDIR)/scripts/%,\
	$(DESTDIR)$(PREFIX)/bin/%,$(SCRIPTS))

.PHONY: install uninstall

install: $(NVIM) $(SCRIPT_TARGETS)
	rm -f ~/.config/nvim
	ln -snf $(CURDIR) ~/.config/nvim
	sudo $(MAKE) -C neovim install \
		DESTDIR=$(DESTDIR) PREFIX=$(PREFIX)

uninstall:
	rm -f ~/.config/nvim
	sudo rm -rf \
		/usr/local/bin/nvim \
		/usr/local/share/nvim \
		$(SCRIPT_TARGETS)

$(DESTDIR)$(PREFIX)/bin/%: scripts/%
	sudo install -d "$(DESTDIR)$(PREFIX)/bin"
	sudo ln -snf "$(CURDIR)/scripts/$*" "$@"

$(NVIM):
	git submodule update --init --recursive --force
	$(MAKE) CMAKE_BUILD_TYPE=Release -C neovim -j$(shell nproc) \
		DESTDIR=$(DESTDIR) PREFIX=$(PREFIX)


