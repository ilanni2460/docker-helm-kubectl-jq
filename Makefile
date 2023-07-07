default: docker_build

DOCKER_IMAGE ?= ilanni2460/helm-kubectl-jq
DOCKER_TAG ?= `git rev-parse --abbrev-ref HEAD`

docker_build:
	@docker build \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker_push:
	# Push to DockerHub
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)

.PHONY: latest
latest: HELM=$(shell ./version.sh helm)
latest: KUBECTL=$(shell ./version.sh kubectl)
latest:
	sed -i.bak 's/KUBE_LATEST_VERSION="v[0-9]*.[0-9]*.[0-9]*"/KUBE_LATEST_VERSION="$(KUBECTL)"/' Dockerfile
	sed -i.bak 's/HELM_VERSION="v[0-9]*.[0-9]*.[0-9]*"/HELM_VERSION="$(HELM)"/' Dockerfile
	rm Dockerfile.bak

.PHONY: commit
commit: HELM:=$(shell grep -E 'HELM_VERSION="v([0-9]*.[0-9]*.[0-9]*)"' Dockerfile | sed 's/^ENV HELM_VERSION="v\(.*\)"/\1/')
commit: KUBECTL:=$(shell grep -E 'KUBE_LATEST_VERSION="v([0-9]*.[0-9]*.[0-9]*)"' Dockerfile | sed 's/^ENV KUBE_LATEST_VERSION="v\(.*\)"/\1/')
commit: MSG=helm $(HELM), kubectl $(KUBECTL), alpine 3.12, jq 1.6
commit:
	git checkout -b v$(HELM)
	git add Dockerfile README.md
	git commit -m "$(MSG)"

.PHONY: docker_test
docker_test:
	@DOCKERFILE=$$(grep -E 'HELM_VERSION="v([0-9]*.[0-9]*.[0-9]*)"' Dockerfile | sed 's/^ENV HELM_VERSION="v\(.*\)"/\1/'); \
	IMAGE=$$(docker run -it --rm $(DOCKER_IMAGE):$(DOCKER_TAG) helm version --template '{{.Version}}'); \
	MSG="Dockerfile v$${DOCKERFILE}, Image $${IMAGE}"; \
	if [ "v$$DOCKERFILE" != "$$IMAGE" ]; then \
		echo "Version mismatch: $$MSG" \
		&& exit 1; \
	else \
		echo "$$MSG"; \
	fi;
