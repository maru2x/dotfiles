.PHONY: install set-link setup scripts-perms brew-diff brew-unused

scripts-perms:
	chmod +x scripts/*.sh

install: scripts-perms
	./scripts/install.sh

set-link: scripts-perms
	./scripts/set-link.sh

setup: install set-link

brew-diff: scripts-perms
	./scripts/brew-diff.sh

brew-unused: brew-diff
