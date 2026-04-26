SHELL := /bin/bash
.DEFAULT_GOAL := help

DOCKER ?= docker
BUILDERS_DIR ?= .
BASE_TAG_PREFIX ?=
BUILDER_NAMESPACE ?= $(if $(BASE_TAG_PREFIX),$(BASE_TAG_PREFIX),gr4-dev)
PLATFORMS ?= linux/amd64,linux/arm64

distro_from_base = $(shell basename $(shell dirname $(patsubst %/Dockerfile,%,$1)))
distro_from_profile = $(shell basename $(shell dirname $(shell dirname $(patsubst %/Dockerfile,%,$1))))
profile_name = $(shell basename $(patsubst %/Dockerfile,%,$1))

BASE_DOCKERFILES := $(wildcard $(BUILDERS_DIR)/*/base/Dockerfile)
PROFILE_DOCKERFILES := $(wildcard $(BUILDERS_DIR)/*/profiles/*/Dockerfile)
TARGETS := $(foreach df,$(BASE_DOCKERFILES),build-$(call distro_from_base,$(df))-base) \
	$(foreach df,$(PROFILE_DOCKERFILES),build-$(call distro_from_profile,$(df))-$(call profile_name,$(df)))
PUSH_TARGETS := $(foreach df,$(BASE_DOCKERFILES),push-$(call distro_from_base,$(df))-base) \
	$(foreach df,$(PROFILE_DOCKERFILES),push-$(call distro_from_profile,$(df))-$(call profile_name,$(df)))

help:
	@printf '%s\n' 'Available targets:' \
		'  make list' \
		'  make build-all' \
		'  make push-all'
	@for target in $(TARGETS); do printf '%s\n' "  make $$target"; done
	@for target in $(PUSH_TARGETS); do printf '%s\n' "  make $$target"; done

list:
	@printf '%s\n' $(TARGETS) $(PUSH_TARGETS)

build-all: $(TARGETS)
push-all: $(PUSH_TARGETS)

define define_base_target
build-$(call distro_from_base,$1)-base: $1
	$$(DOCKER) build \
		-t $$(BUILDER_NAMESPACE)/$(call distro_from_base,$1)-base:latest \
		-f $1 \
		$$(BUILDERS_DIR)/$(call distro_from_base,$1)
endef

define define_profile_target
build-$(call distro_from_profile,$1)-$(call profile_name,$1): build-$(call distro_from_profile,$1)-base $1
	$$(DOCKER) build \
		-t $$(BUILDER_NAMESPACE)/$(call distro_from_profile,$1)-$(call profile_name,$1):latest \
		--build-arg BASE_IMAGE=$$(BUILDER_NAMESPACE)/$(call distro_from_profile,$1)-base:latest \
		-f $1 \
		$$(BUILDERS_DIR)/$(call distro_from_profile,$1)
endef

define define_base_push_target
push-$(call distro_from_base,$1)-base: $1
	$$(DOCKER) buildx build \
		--platform $$(PLATFORMS) \
		--push \
		-t $$(BUILDER_NAMESPACE)/$(call distro_from_base,$1)-base:latest \
		-f $1 \
		$$(BUILDERS_DIR)/$(call distro_from_base,$1)
endef

define define_profile_push_target
push-$(call distro_from_profile,$1)-$(call profile_name,$1): push-$(call distro_from_profile,$1)-base $1
	$$(DOCKER) buildx build \
		--platform $$(PLATFORMS) \
		--push \
		-t $$(BUILDER_NAMESPACE)/$(call distro_from_profile,$1)-$(call profile_name,$1):latest \
		--build-arg BASE_IMAGE=$$(BUILDER_NAMESPACE)/$(call distro_from_profile,$1)-base:latest \
		-f $1 \
		$$(BUILDERS_DIR)/$(call distro_from_profile,$1)
endef

$(foreach df,$(BASE_DOCKERFILES),$(eval $(call define_base_target,$(df))))
$(foreach df,$(PROFILE_DOCKERFILES),$(eval $(call define_profile_target,$(df))))
$(foreach df,$(BASE_DOCKERFILES),$(eval $(call define_base_push_target,$(df))))
$(foreach df,$(PROFILE_DOCKERFILES),$(eval $(call define_profile_push_target,$(df))))

.PHONY: help list build-all push-all $(TARGETS) $(PUSH_TARGETS)
