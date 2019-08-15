qa: lint lint-shell build test scan-vulnerability
build: clean-tags build
push: build push
ci-push: ci-docker-login push

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(abspath $(patsubst %/,%,$(dir $(mkfile_path))))

.PHONY: *

BUILDINGIMAGE=*

# Docker PHP images build matrix ./build-php.sh (nts/zts) (PHP version) (Alpine version)
docker-build: BUILDINGIMAGE=github-cli
docker-build: clean-tags
	./docker-build-php.sh github-cli 7.3 3.10

.NOTPARALLEL: clean-tags
clean-tags:
	rm ${current_dir}/tmp/build.tags || true

# Docker images push
push:
	cat ./tmp/build.tags | xargs -I % docker push %

# CI dependencies
ci-docker-login:
	docker login --username $$DOCKER_USER --password $$DOCKER_PASSWORD

lint:
	docker run -v ${current_dir}:/project:ro --workdir=/project --rm -it hadolint/hadolint:latest-debian hadolint /project/Dockerfile

docker-test: ./tmp/build.tags
	xargs -I % ./docker-test.sh % < ./tmp/build.tags

scan-vulnerability:
	docker-compose -f test/security/docker-compose.yml -p clair-ci up -d
	RETRIES=0 && while ! wget -T 10 -q -O /dev/null http://localhost:6060/v1/namespaces ; do sleep 1 ; echo -n "." ; if [ $${RETRIES} -eq 10 ] ; then echo " Timeout, aborting." ; exit 1 ; fi ; RETRIES=$$(($${RETRIES}+1)) ; done
	cat ./tmp/build.tags | xargs -I % sh -c 'clair-scanner --ip 172.17.0.1 -r "./tmp/clair/%.json" -l ./tmp/clair/clair.log % || echo "% is vulnerable"'
	docker-compose -f test/security/docker-compose.yml -p clair-ci down

ci-scan-vulnerability:
	docker-compose -f test/security/docker-compose.yml -p clair-ci up -d
	RETRIES=0 && while ! wget -T 10 -q -O /dev/null http://localhost:6060/v1/namespaces ; do sleep 1 ; echo -n "." ; if [ $${RETRIES} -eq 10 ] ; then echo " Timeout, aborting." ; exit 1 ; fi ; RETRIES=$$(($${RETRIES}+1)) ; done
	cat ./tmp/build.tags | xargs -I % sh -c 'clair-scanner --ip 172.17.0.1 -r "./tmp/clair/%.json" -l ./tmp/clair/clair.log %'; \
	XARGS_EXIT=$$?; \
	if [ $${XARGS_EXIT} -eq 123 ]; then find ./tmp/clair/github-cli -type f | sed 's/^/-Fjson=@/' | xargs -d'\n' curl -X POST ${WALLE_REPORT_URL} -F channel=team_oz -F buildUrl=https://circleci.com/gh/php-api-clients/github-cli/${CIRCLE_BUILD_NUM}#artifacts/containers/0; else exit $${XARGS_EXIT}; fi

all:
	composer run-script qa-all --timeout=0

all-coverage:
	composer run-script qa-all-coverage --timeout=0

ci:
	composer run-script qa-ci --timeout=0

ci-extended:
	composer run-script qa-ci-extended --timeout=0

contrib:
	composer run-script qa-contrib --timeout=0

init:
	composer ensure-installed

cs:
	composer cs

cs-fix:
	composer cs-fix

unit:
	composer run-script unit --timeout=0

unit-coverage:
	composer run-script unit-coverage --timeout=0

ci-coverage: init
	composer ci-coverage
