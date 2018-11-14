SHELL := /bin/bash

include config.mk

PROJECTS = $(shell echo $(QUORUM_NAME) $(CONSTELLATION_NAME) $(CRUX_NAME) | tr '[:lower:]' '[:upper:]')
PACKAGES = $(foreach project,$(PROJECTS), $(foreach build,$(BUILDS), $($(project)_NAME)-$($(project)_VERSION)-$(build) ) )
RUN_CONTAINERS = $(firstword $(BUILDS))-docker-$(QUORUM_NAME) $(firstword $(BUILDS))-docker-$(CONSTELLATION_NAME) $(firstword $(BUILDS))-docker-$(CRUX_NAME)
BUILD_CONTAINERS = docker-build-$(VERSION)

.PHONY: all qbc qbc-containers qbc-tarballs test release tag circleci-macos clean check_clobber clobber
.DEFAULT_GOAL := qbc

ifneq ($(filter all,$(MAKECMDGOALS)),)
.NOTPARALLEL:
endif

all: clean
	$(MAKE) qbc && $(MAKE) test

qbc: qbc-tarballs qbc-containers

qbc-containers: $(RUN_CONTAINERS)

qbc-tarballs: $(foreach build,$(BUILDS),tarball-$(build))

tarball-%: $(PACKAGES)
	cd $(BUILDDIR) && tar czf qbc-$(VERSION)-$*.tar.gz $(addsuffix .tar.gz, $?)

$(PACKAGES): $(addprefix .build~,$(PACKAGES))
	$(eval PROJECT = $(shell echo $(firstword $(subst -, ,$@))| tr '[:lower:]' '[:upper:]'))
	@test -e $(BUILDDIR)/$@.tar.gz \
	|| ( echo "BUILD, TAR & GZIP PACKAGE: $@" && cd $(BUILDDIR) \
	&& tar cf $@.tar -C $(CURDIR)/docs/$($(PROJECT)_NAME) . \
	&& tar rf $@.tar -C $(CURDIR)/config/$($(PROJECT)_NAME) . \
	&& tar rf $@.tar -C $@/$($(PROJECT)_BINPATH) $($(PROJECT)_OUTFILES) \
	&& find $@/$($(PROJECT)_BINPATH) -name '*.so.*' | xargs tar rf $@.tar \
	&& gzip -f $@.tar )

.build~%: $(addprefix .clone~,$(PACKAGES)) | $(BUILD_CONTAINERS)
	$(eval PACKAGE = $*)
	$(eval PROJECT = $(shell echo $(firstword $(subst -, ,$(PACKAGE)))| tr '[:lower:]' '[:upper:]'))
	$(eval CONTAINER_$(PROJECT)_BUILD = docker run -i -v $(shell pwd)/$(BUILDDIR)/$(PACKAGE):/tmp/$($(PROJECT)_NAME) consensys/linux-build:$(VERSION) ./build-$($(PROJECT)_NAME).sh)
	@test -e $(BUILDDIR)/$@ \
	|| ( [[ "$(PACKAGE)" == *"linux"* ]] && ( cd $(BUILDDIR)/$(PACKAGE) && $(CONTAINER_$(PROJECT)_BUILD) && touch ../$@ ) || echo "SKIP" \
	&&   [[ "$(PACKAGE)" == *"darwin"* ]] && ( cd $(BUILDDIR)/$(PACKAGE) && $($(PROJECT)_BUILD) && touch ../$@) || echo "SKIP" )

.clone~%:
	$(eval PACKAGE = $*)
	$(eval PROJECT = $(shell echo $(firstword $(subst -, ,$(PACKAGE)))| tr '[:lower:]' '[:upper:]'))
	@mkdir -p $(BUILDDIR)
	@test -e $(BUILDDIR)/$(PACKAGE) || ( echo "CLONE: $($(PROJECT)_NAME) INTO: $(PACKAGE)" \
	&& cd $(BUILDDIR) \
	&& git clone --branch $($(PROJECT)_VERSION) --depth 1 $($(PROJECT)_REPO) $(PACKAGE) \
	&& touch $@ )

$(BUILD_CONTAINERS):
	@test -e $(CURDIR)/$(BUILDDIR)/.$@ || ( echo "BUILDING BUILD_CONTAINER: $@" \
	&& mkdir -p $(CURDIR)/$(BUILDDIR)/$@ \
	&& cd $(CURDIR)/$(BUILDDIR)/$@ \
	&& cp $(CURDIR)/docker/linux-build.Dockerfile linux-build.Dockerfile \
	&& docker build --build-arg CACHEBUST=$(date +%s) -f linux-build.Dockerfile -t consensys/linux-build:$(VERSION) . \
	&& touch $(CURDIR)/$(BUILDDIR)/.$@ )

$(RUN_CONTAINERS): $(PACKAGES)
	$(eval PROJECT = $(shell echo $(lastword $(subst -, ,$@))| tr '[:lower:]' '[:upper:]'))
	$(eval OS = $(shell echo $(word 1, $(subst -, ,$@))))
	$(eval ARCH = $(shell echo $(word 2, $(subst -, ,$@))))
	@test -e $(CURDIR)/$(BUILDDIR)/.docker-$($(PROJECT)_NAME) || ( echo "BUILDING RUN_CONTAINER: $@" \
	&& mkdir -p $(CURDIR)/$(BUILDDIR)/docker-$($(PROJECT)_NAME) \
	&& cp $(CURDIR)/docker/$($(PROJECT)_NAME)-start.sh $(CURDIR)/$(BUILDDIR)/docker-$($(PROJECT)_NAME) \
	&& mv $(CURDIR)/build/$($(PROJECT)_NAME)-$($(PROJECT)_VERSION)-$(OS)-$(ARCH).tar.gz $(CURDIR)/$(BUILDDIR)/docker-$($(PROJECT)_NAME) \
	&& cd $(CURDIR)/$(BUILDDIR)/docker-$($(PROJECT)_NAME) \
	&& cp ../../docker/$($(PROJECT)_NAME).Dockerfile $($(PROJECT)_NAME).Dockerfile \
	&& docker build --build-arg osarch=$(OS)-$(ARCH) --build-arg version=$($(PROJECT)_VERSION) -f $($(PROJECT)_NAME).Dockerfile -t consensys/$($(PROJECT)_NAME):$(VERSION) . \
	&& docker tag consensys/$($(PROJECT)_NAME):$(VERSION) consensys/$($(PROJECT)_NAME):latest \
	&& touch $(CURDIR)/$(BUILDDIR)/.docker-$($(PROJECT)_NAME) )

test: $(RUN_CONTAINERS)
	cd tests && make

release: tag $(BUILDDIR)/.dockerpush $(BUILDDIR)/.tgzpush
	git push origin master --tags

tag:
	git tag -s $(VERSION)

$(BUILDDIR)/.dockerpush: $(BUILDDIR)/.dockerlogin $(addprefix $(BUILDDIR)/.dockerpush-$(VERSION)-, $(shell echo $(PROJECTS) | tr '[:upper:]' '[:lower:]'))
	touch $(BUILDDIR)/.dockerpush

$(BUILDDIR)/.dockerlogin: 
	docker login
	
$(BUILDDIR)/.dockerpush-$(VERSION)-quorum:
	docker push consensys/quorum:$(VERSION) && touch $@

$(BUILDDIR)/.dockerpush-$(VERSION)-constellation:
	docker push consensys/constellation:$(VERSION) && touch $@

$(BUILDDIR)/.dockerpush-$(VERSION)-crux:
	docker push consensys/crux:$(VERSION) && touch $@

$(BUILDDIR)/.tgzpush: $(addsuffix .tar.gz.asc, $(addprefix $(BUILDDIR)/qbc-$(VERSION)-, $(BUILDS)))
	touch $(BUILDDIR)/.tgzpush

$(BUILDDIR)/qbc-$(VERSION)-%: qbc-tarballs
	gpg --detach-sign -o $@ $(subst .asc,,$@)
	curl -T $@ -u$(BINTRAY_USER):$(BINTRAY_KEY) -H "X-Bintray-Package:qbc" -H "X-Bintray-Version:$(VERSION)" https://api.bintray.com/content/consensys/binaries/qbc/$(VERSION)/qbc-$(VERSION)-$*
	curl -T $(subst .asc,,$@) -u$(BINTRAY_USER):$(BINTRAY_KEY) -H "X-Bintray-Package:qbc" -H "X-Bintray-Version:$(VERSION)" https://api.bintray.com/content/consensys/binaries/qbc/$(VERSION)/qbc-$(VERSION)-$(subst .asc,,$*)

circleci-macos: 
	mkdir -p $(BUILDDIR) && touch $(BUILDDIR)/.docker-build-$(VERSION) && $(MAKE) tarball-darwin-64

clean:
	echo $(BUILDS)
	rm -Rf $(BUILDDIR)

check_clobber:
	@echo "You have chosen to go nuclear.  Are you sure you want to delete ALL stopped containers (Y/n)?" && read ans && [ $$ans == Y ]

clobber: check_clobber clean
	docker ps -a | awk '{ print $$1,$$2 }' | grep consensys | awk '{print $$1 }' | xargs -I {} docker container stop {} && docker system prune -a -f --volumes