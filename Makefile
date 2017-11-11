
PREFIX ?= /usr/local

install:
	mkdir -p $(HOME)/.bashrc.d
	cp resty $(HOME)/.bashrc.d
	cp pypp pp $(PREFIX)/bin/
	@echo "You should add 'source ~/.bashrc.d/resty' to your bashrc"

uninstall:
	rm -f $(PREFIX)/bin/{pp,pypp} $(HOME)/.bashrc.d/resty
