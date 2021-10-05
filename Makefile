install-hadolint:
	sudo wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.7.0/hadolint-Linux-x86_64
	sudo chmod +x /bin/hadolint
	which hadolint

install-circleci:
	curl -fLSs https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh | sudo bash
	which circleci

install-local:
	npm install

build-local:
	npm run build
	
run-local:
	npm start

lint:
	npm run svelte-check
	hadolint Dockerfile
	
build-image:
	docker build -t dgbwm .
	
run-server: build-image
	docker run --rm -it -p 80:80 dgbwm

list:
	@grep '^[^#[:space:]].*:' Makefile