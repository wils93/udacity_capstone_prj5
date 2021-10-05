install-hadolint:
	sudo wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.7.0/hadolint-Linux-x86_64
	sudo chmod +x /bin/hadolint
	which hadolint

install-circleci:
	curl -fLSs https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh | sudo bash
	which circleci

install-k8s:
	cd /tmp && curl -LO "https://dl.k8s.io/release/$(shell curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	cd /tmp && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	cd /tmp && chmod +x kubectl
	mkdir -p ~/.local/bin/kubectl
	cd /tmp && mv ./kubectl ~/.local/bin/kubectl

install-minikube:
	cd /tmp && curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
	sudo install /tmp/minikube-linux-amd64 /usr/local/bin/minikube
	which minikube	

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