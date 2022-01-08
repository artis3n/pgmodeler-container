#!/usr/bin/env make

.PHONY: install
install:
	git submodule update --init --recursive

.PHONY: lint
lint:
	hadolint --ignore DL3008 Dockerfile

.PHONY: size
size:
	dive artis3n/pgmodeler:$${TAG:-test}

.PHONY: test
test:
	xhost +local:
	mkdir -p /tmp/saves; touch /tmp/saves/exist.txt
	dgoss run -it --rm -e DISPLAY --cap-drop=all -v /tmp/.X11-unix:/tmp/.X11-unix -v /tmp/saves:/app/savedwork artis3n/pgmodeler:$${TAG:-test}
	CI=true dive artis3n/pgmodeler:$${TAG:-test}
	xhost -local:

.PHONY: test-edit
test-edit:
	mkdir -p /tmp/saves; touch /tmp/saves/exist.txt
	dgoss edit -it --rm -e DISPLAY --cap-drop=all -v /tmp/.X11-unix:/tmp/.X11-unix -v $$(xauth info | grep "Authority file" | awk '{ print $$3 }'):/home/modeler/.Xauthority:ro -v /tmp/saves:/app/savedwork artis3n/pgmodeler:$${TAG:-test}

.PHONY: build
build:
	docker build . -t artis3n/pgmodeler:$${TAG:-test}

.PHONY: build-ci
build-ci:
	docker build --progress plain . -t artis3n/pgmodeler:$${TAG:-test}

.PHONY: run
run:
	docker run -it --rm -e DISPLAY --cap-drop=all -v /tmp/.X11-unix:/tmp/.X11-unix -v $$(xauth info | grep "Authority file" | awk '{ print $$3 }'):/home/modeler/.Xauthority:ro -v $${WORK:-~/Documents}:/app/savedwork artis3n/pgmodeler:$${TAG:-test}
