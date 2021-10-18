install-hadolint:
	wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.7.0/hadolint-Linux-x86_64
	chmod +x /bin/hadolint
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
	which kubectl

install-minikube:
	cd /tmp && curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
	sudo install /tmp/minikube-linux-amd64 /usr/local/bin/minikube
	which minikube

install-docker:
	sudo apt update
	sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
	apt-cache policy docker-ce
	sudo apt install docker-ce -y
	sudo usermod -aG docker ubuntu

install-ansible:
	sudo apt update
	sudo apt install ansible -y
	ansible-galaxy collection install community.general
	which ansible

install-yq:
	sudo wget https://github.com/mikefarah/yq/releases/download/v4.13.4/yq_linux_amd64 -O /usr/bin/yq
	sudo chmod +x /usr/bin/yq
	which yq

install-local:
	npm install

build-local: install-local
	npm run build
	
run-local:
	npm start

lint: install-local install-hadolint
	npm run svelte-check
	hadolint Dockerfile

build-image:
	docker build -t dgbwm .

push-image: lint build-image
	docker tag dgbwm wils93/udacity_capstone_prj5:latest
	docker push wils93/udacity_capstone_prj5:latest

run-server: build-image
	docker run --rm -it -p 80:80 dgbwm

create-network:
	./run.sh network create

delete-network:
	./run.sh network delete

create-servers:
	./run.sh servers create

delete-servers:
	./run.sh servers delete

delete-stacks: delete-servers delete-network

run-cluster:
	minikube start --ports=80:80
	minikube addons enable ingress
	kubectl apply -f k8s/deploy-cluster.yaml
	kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller 
	kubectl apply -f k8s/ingress.yaml

delete-cluster:
	minikube delete

list:
	@grep '^[^#[:space:]].*:' Makefile
