# Make targets for building the TF.js example image analysis MMS edge service.

# This imports the variables from horizon/hzn.json. You can ignore these lines, but do not remove them.
-include horizon/.hzn.json.tmp.mk

# Transform the machine arch into some standard values: "arm", "arm64", or "amd64"
SYSTEM_ARCH := $(shell uname -m | sed -e 's/aarch64.*/arm64/' -e 's/x86_64.*/amd64/' -e 's/armv.*/arm/')

# To build for an arch different from the current system, set this env var to one of the values in the comment above
#export ARCH ?= $(SYSTEM_ARCH)

# Default ARCH to the architecture of this machines (as horizon/golang describes it)
export ARCH ?= $(shell hzn architecture)

DOCKER_IMAGE_BASE ?= iportilla/image-tf-mms
SERVICE_NAME ?=image.mms
SERVICE_VERSION ?=1.0.0
PORT_NUM ?=9080
DOCKER_NAME ?=image-tf-mms

default: all

all: build run

build:
	docker build -t $(DOCKER_IMAGE_BASE)_$(ARCH):$(SERVICE_VERSION) -f ./Dockerfile.$(ARCH) .

run:
	@echo "Open your browser and go to http://localhost:9080"
	docker run -d -p=$(PORT_NUM):80 --name=$(DOCKER_NAME) $(DOCKER_IMAGE_BASE)_$(ARCH):$(SERVICE_VERSION)

	# Publish the service to the Horizon Exchange for the current architecture
publish-service:
	hzn exchange service publish -O -f horizon/service.definition.json

	# Publish the pattern to the Horizon Exchange for the current architecture
publish-pattern:
	hzn exchange pattern publish -f horizon/pattern.json

  # target to publish new ML model file to mms
publish-mms-object:
	hzn mms object publish -m mms/object.json -f mms/index.js

  # target to list mms object
list-mms-object:
	hzn mms object list -t js -i index.js -d

list-js:
	hzn mms object list -t js -i index.js -d

list-files:
	sudo ls -Rla /var/horizon/ess-store/sync/local

 # target to delete input.json file in mms
delete-mms-object:
	hzn mms object delete -t js --id index.js

 # register node
register:
	hzn register -p pattern-image-tf-mms-amd64

  # unregiser node
unregister:
	hzn unregister -Df
# Stop and remove a running container
stop:
	docker stop $(DOCKER_NAME); docker rm $(DOCKER_NAME)


# Clean the container
clean:
	-docker rm -f $(DOCKER_NAME) 2> /dev/null || :
