#!/usr/bin/env make

.PHONY: install
install:
	git submodule init && git submodule update --remote

.PHONY: lint
lint:
	docker run --rm -i hadolint/hadolint hadolint --ignore DL3008 - < Dockerfile

.PHONY: size
size:
	dive artis3n/pgmodeler:$${TAG:-test}

.PHONY: test
test:
	xhost +local:
	mkdir -p /tmp/saves; touch /tmp/saves/exist.txt
	dgoss run -it --rm -e DISPLAY=$$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /tmp/saves:/app/savedwork artis3n/pgmodeler:$${TAG:-test}
	CI=true dive artis3n/pgmodeler:$${TAG:-test}
	xhost -local:

.PHONY: test-edit
test-edit:
	xhost +local:
	dgoss edit -it --rm -e DISPLAY=$$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix artis3n/pgmodeler:$${TAG:-test}
	xhost -local:

.PHONY: build
build:
	docker build . -t artis3n/pgmodeler:$${TAG:-test}

.PHONY: run
run:
	xhost +local:
	mkdir -p /tmp/saves
	docker run -it --rm -e DISPLAY=$$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /tmp/saves:/app/savedwork artis3n/pgmodeler:$${TAG:-latest}
	xhost -local:
