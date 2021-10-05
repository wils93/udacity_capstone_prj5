install-hadolint:
	sudo wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.7.0/hadolint-Linux-x86_64
	sudo chmod +x /bin/hadolint
	which hadolint

install-circleci:
	curl -fLSs https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh | sudo bash
	which circleci

install:
	npm install

build:
	npm run build

lint:
	npm run svelte-check
	hadolint Dockerfile

list:
	@grep '^[^#[:space:]].*:' Makefile