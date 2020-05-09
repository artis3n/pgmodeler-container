#!/usr/bin/env make

.PHONY: install
install:
	git submodule init && git submodule update --remote
	if [ ! -f /home/linuxbrew/.linuxbrew/bin/brew ]; then /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"; fi
	if [ ! -f /usr/local/bin/goss ]; then curl -fsSL https://goss.rocks/install | sh; fi

.PHONY: lint
lint:
	docker run --rm -i hadolint/hadolint hadolint --ignore DL3008 - < Dockerfile

.PHONY: size
size:
	if [! -f /usr/local/bin/dive ]; then brew install dive; fi;
	dive build -t artis3n/pgmodeler:dive .
	docker rmi artis3n/pgmodeler:dive

.PHONY: test
test:
	xhost +local:
	docker run -it --rm -e DISPLAY=$$DISPLAY -e QT_GRAPHICSSYSTEM=native -v /tmp/.X11-unix:/tmp/.X11-unix artis3n/pgmodeler:$${TAG:-test}
	xhost -local:

.PHONY: test-edit
test-edit:
	xhost +local:
	dgoss edit -it --rm -e DISPLAY=$$DISPLAY -e QT_GRAPHICSSYSTEM=native -v /tmp/.X11-unix:/tmp/.X11-unix artis3n/pgmodeler:$${TAG:-test}
	xhost -local:

.PHONY: build
build:
	docker build . -t artis3n/pgmodeler:$${TAG:-test}

.PHONY: run
run:
	xhost +local:
	docker run -it --rm -e DISPLAY=$$DISPLAY -e QT_GRAPHICSSYSTEM=native -v /tmp/.X11-unix:/tmp/.X11-unix artis3n/pgmodeler:$${TAG:-latest}
	xhost -local:
