IMAGE_NAMESPACE ?= wayofdev/ansible
TEMPLATE ?= base-alpine


########################################################################################################################
# Most likely there is nothing to change behind this line
########################################################################################################################

IMAGE_TAG ?= $(IMAGE_NAMESPACE):$(TEMPLATE)-latest
DOCKERFILE_DIR ?= ./dist/$(TEMPLATE)
CACHE_FROM ?= $(IMAGE_TAG)
CURRENT_DIR ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

BUILDER_TEMPLATE ?= builder-alpine
BUILDER_IMAGE_TAG ?= $(IMAGE_NAMESPACE):$(BUILDER_TEMPLATE)-latest
BUILDER_DOCKERFILE_DIR ?= ./dist/$(BUILDER_TEMPLATE)

all: generate builder-build builder-test build test
PHONY: all

build:
	cd $(CURRENT_DIR)$(DOCKERFILE_DIR); \
	docker build . -t $(IMAGE_TAG)
PHONY: build

build-from-cache:
	cd $(CURRENT_DIR)$(DOCKERFILE_DIR); \
	docker build --cache-from $(CACHE_FROM) . -t $(IMAGE_TAG)
PHONY: build-from-cache

builder-build:
	cd $(CURRENT_DIR)$(BUILDER_DOCKERFILE_DIR); \
	docker build . -t $(BUILDER_IMAGE_TAG)
PHONY: builder-build

test:
	set -eux
	GOSS_FILES_STRATEGY=cp GOSS_FILES_PATH=$(DOCKERFILE_DIR) dgoss run -t $(IMAGE_TAG)
.PHONY: test

builder-test:
	set -eux
	GOSS_FILES_STRATEGY=cp GOSS_FILES_PATH=$(BUILDER_DOCKERFILE_DIR) dgoss run -t $(BUILDER_IMAGE_TAG)
PHONY: builder-test

pull:
	docker pull $(IMAGE_TAG)
.PHONY: pull

push:
	docker push $(IMAGE_TAG)
.PHONY: push

ssh:
	docker run --rm -it -v $(PWD)/:/opt/ansible $(IMAGE_TAG) sh
.PHONY: ssh

install-hooks:
	pre-commit install --hook-type commit-msg
.PHONY: install-hooks



########################################################################################################################
# Ansible
########################################################################################################################

generate:
	ansible-playbook src/generate.yml
PHONY: generate

clean:
	rm -rf ./dist/*
PHONY: clean
