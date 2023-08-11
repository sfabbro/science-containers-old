
DEVNAME = phosphoros

NAME = images.canfar.net/skaha/$(DEVNAME)
VERSION = 1.8.0

build: dependencies Dockerfile
	docker build -t $(NAME):$(VERSION) --build-arg PHOSPHOROS_VERSION=$(VERSION) -f Dockerfile .

dependencies: 

init:
	mkdir -p build

.PHONY: clean
clean:
	\rm -rf build
