# Styling for output
YELLOW := "\e[1;33m"
NC := "\e[0m"
INFO := @sh -c '\
    printf $(YELLOW); \
    echo "=> $$1"; \
    printf $(NC)' VALUE

.SILENT:  # Ignore output of make `echo` command

# Catch command args
PARAMS := cljstyle
GOALS = $(filter-out $@,$(MAKECMDGOALS))
IMAGE_NAME = $(GOALS)
VERSION_FILE=$(IMAGE_NAME)/VERSION
VERSION ?= $(shell cat $(VERSION_FILE))
REPO=abogoyavlensky/$(IMAGE_NAME):$(VERSION)


.PHONY: help  # Show list of targets with descriptions
help:
	@$(INFO) "Commands:"
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\1 > \2/' | column -tx -s ">"


.PHONY: check-image-name
check-image-name:
ifneq ($(filter $(IMAGE_NAME),$(PARAMS)),)
	$(info Set version $(IMAGE_NAME) as $(VERSION))
else
	$(error $(IMAGE_NAME) does not exist in $(PARAMS))
endif


.PHONY: build  # Build image by dir name
build:
	@$(MAKE) check-image-name $(IMAGE_NAME)
	@$(INFO) "Building image $(REPO)..."
	# Run build.sh in image dir with custom args
	@cd $(IMAGE_NAME) && REPO=$(REPO) VERSION=$(VERSION) ./build.sh


.PHONY: publish  # Publish image by dir name
publish:
	@$(MAKE) check-image-name $(IMAGE_NAME)
	@$(MAKE) build $(IMAGE_NAME)
	@$(INFO) "Publishing image $(REPO)..."
	# Run build.sh in image dir with custom args
	@docker push $(REPO)