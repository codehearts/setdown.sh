REPO_ROOT=$(shell git rev-parse --show-toplevel)
KCOV_VERSION=33

test: lint coverage test_bash4_4

test_bash4_4: docker_installed
	@docker pull bash:4.4
	@docker run -t --rm \
		--mount type=bind,source=$(REPO_ROOT),target=/app,readonly \
		bash:4.4 /app/test/test_setdown.sh

lint: docker_installed
	@docker pull koalaman/shellcheck:latest
	@docker run -t --rm \
		--mount type=bind,source=$(REPO_ROOT),target=/app,readonly \
		koalaman/shellcheck:latest /app/setdown.sh /app/test/test_setdown.sh

coverage: docker_installed
	@docker pull ragnaroek/kcov:v$(KCOV_VERSION)
	@docker run -t --rm --security-opt seccomp=unconfined \
		--mount type=bind,source=$(REPO_ROOT),target=/source \
		ragnaroek/kcov:v$(KCOV_VERSION) --exclude-path=/source/test/ \
		/source/coverage /source/test/test_setdown.sh

docker_installed:
ifeq (, $(shell which docker))
    $(error Docker is required for testing, see https://www.docker.com to get set up)
endif

.PHONY: test test_coverage test_bash4_4
