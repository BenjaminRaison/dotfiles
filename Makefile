# Originally from github:jessfraz/dotfiles

.PHONY: all
all: bin dotfiles etc warn ## Installs the bin and etc directory files and the dotfiles.

.PHONY: warn
warn:
	@echo "\033[0;31mMANUAL: Add '*/2 * * * * /usr/local/bin/battery-warning.sh' to user crontab\033[0m'"

.PHONY: bin
bin: ## Installs the bin directory files.
	# add aliases for things in bin
	for file in $(shell find $(CURDIR)/bin -type f -not -name "*-backlight" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		sudo ln -sf $$file /usr/local/bin/$$f; \
	done
	if [ -f /usr/local/bin/android-studio/bin/studio.sh ]; then \
		sudo ln -snf /usr/local/bin/android-studio/bin/studio.sh /usr/local/bin/androidstudio; \
	fi;
	if [ -f /usr/local/bin/pinentry ]; then \
		sudo ln -snf /usr/bin/pinentry /usr/local/bin/pinentry; \
	fi;

.PHONY: dotfiles
dotfiles: ## Installs the dotfiles.
	# add aliases for dotfiles
	for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".travis.yml" -not -name ".git" -not -name ".*.swp" -not -name ".gnupg" -not -name ".mako"); do \
		f=$$(basename $$file); \
		ln -snf $$file $(HOME)/$$f; \
	done; \
	gpg --list-keys || true;
	ln -snf $(CURDIR)/.gnupg/gpg.conf $(HOME)/.gnupg/gpg.conf;
	ln -snf $(CURDIR)/.gnupg/gpg-agent.conf $(HOME)/.gnupg/gpg-agent.conf;
	ln -snf $(CURDIR)/gitignore $(HOME)/.gitignore;
	git update-index --skip-worktree $(CURDIR)/.gitconfig;
	mkdir -p $(HOME)/.config;
	ln -snf $(CURDIR)/config/* $(HOME)/.config/;
	mkdir -p $(HOME)/.local/share;
	ln -snf $(CURDIR)/.fonts $(HOME)/.local/share/fonts;
	ln -snf $(CURDIR)/.bash_profile $(HOME)/.profile;
	ln -snf $(CURDIR)/.Xdefaults $(HOME)/.Xdefaults;
	ln -snf $(CURDIR)/.Xdefaults $(HOME)/.Xresources;
	mkdir -p $(HOME)/.config/mako;
	cp $(CURDIR)/config/.mako/config $(HOME)/.config/mako/config;

.PHONY: etc
etc: ## Installs the etc directory files.
	for file in $(shell find $(CURDIR)/etc -type f -not -name ".*.swp"); do \
		f=$$(echo $$file | sed -e 's|$(CURDIR)||'); \
		sudo mkdir -p $$(dirname $$f); \
		sudo ln -f $$file $$f; \
	done
	
	systemctl --user daemon-reload || true
	sudo systemctl daemon-reload
	sudo systemctl enable systemd-networkd systemd-resolved
	sudo systemctl start systemd-networkd systemd-resolved
	sudo ln -snf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
	
	sudo cp $(CURDIR)/udev/* /etc/udev/rules.d/
	sudo udevadm control --reload

.PHONY: test
test: shellcheck ## Runs all the tests on the files in the repository.

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

.PHONY: shellcheck
shellcheck: ## Runs the shellcheck tests on the scripts.
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		r.j3ss.co/shellcheck:latest ./test.sh

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
