REPO_ROOT=$(shell git rev-parse --show-toplevel)
TEST_RUNNER=test/run_all_tests.sh

TESTS=$(wildcard test/test_*.sh)
LINT_TESTS=$(addprefix /app/, $(TESTS))

DOCKER_FLAGS=-it --rm -e SHUNIT_COLOR=always
KCOV_VERSION=33

test: test_bash4_4

test_bash4_4: docker_installed
	@docker run $(DOCKER_FLAGS) \
		--mount type=bind,source=$(REPO_ROOT),target=/app \
		bash:4.4 /app/$(TEST_RUNNER)

lint: docker_installed
	@docker run $(DOCKER_FLAGS) \
		--mount type=bind,source=$(REPO_ROOT),target=/app,readonly \
		koalaman/shellcheck:latest /app/setdown.sh /app/test/run_all_tests.sh \
		/app/test/run_test.sh $(LINT_TESTS)

coverage: docker_installed
	@docker run $(DOCKER_FLAGS) --security-opt seccomp=unconfined \
		--mount type=bind,source=$(REPO_ROOT),target=/source \
		--entrypoint=/source/$(TEST_RUNNER) -e USE_KCOV=true \
		ragnaroek/kcov:v$(KCOV_VERSION)

install:
	@docker pull bash:4.4
	@docker pull koalaman/shellcheck:latest
	@docker pull ragnaroek/kcov:v$(KCOV_VERSION)

docker_installed:
ifeq (, $(shell which docker))
    $(error Docker is required for testing, see https://www.docker.com to get set up)
endif

.PHONY: test test_bash4_4 lint coverage
