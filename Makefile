VERSION=0.3
QUORUM_VERSION=v2.1.1-grpc
CONSTELLATION_VERSION=v0.3.2
CRUX_VERSION=v1.0.3
GOOS=$(uname -s | tr '[:upper:]' '[:lower:]')
GOARCH=64
BINTRAY_USER=jdoe
BINTRAY_KEY=pass

.PHONY: clean release tag circleci-macos
.DEFAULT_GOAL := build/.docker-$(VERSION)

build/qbc-$(VERSION)-linux-amd64.tar.gz: build/quorum-$(QUORUM_VERSION)-linux-amd64.tar.gz build/constellation-$(CONSTELLATION_VERSION)-linux-amd64.tar.gz build/crux-$(CRUX_VERSION)-linux-amd64.tar.gz
	cd build && tar czf qbc-$(VERSION)-linux-amd64.tar.gz quorum-$(QUORUM_VERSION)-linux-amd64.tar.gz constellation-$(CONSTELLATION_VERSION)-linux-amd64.tar.gz crux-$(CRUX_VERSION)-linux-amd64.tar.gz

build/qbc-$(VERSION)-darwin-64.tar.gz: build/quorum-$(QUORUM_VERSION)-darwin-64.tar.gz build/constellation-$(CONSTELLATION_VERSION)-darwin-64.tar.gz build/crux-$(CRUX_VERSION)-darwin-64.tar.gz
	cd build && tar czf qbc-$(VERSION)-darwin-64.tar.gz quorum-$(QUORUM_VERSION)-darwin-64.tar.gz constellation-$(CONSTELLATION_VERSION)-darwin-64.tar.gz crux-$(CRUX_VERSION)-darwin-64.tar.gz

quorum-$(QUORUM_VERSION)-darwin-64:
	git clone --branch $(QUORUM_VERSION) --depth 1 https://github.com/ConsenSys/quorum.git quorum-$(QUORUM_VERSION)-darwin-64

quorum-$(QUORUM_VERSION)-darwin-64/build/bin/geth: quorum-$(QUORUM_VERSION)-darwin-64
	cd quorum-$(QUORUM_VERSION)-darwin-64 && make all

build/quorum-$(QUORUM_VERSION)-darwin-64.tar.gz: quorum-$(QUORUM_VERSION)-darwin-64/build/bin/geth
	mkdir -p build
	tar cf build/quorum-$(QUORUM_VERSION)-darwin-64.tar -C docs/quorum .
	tar rf build/quorum-$(QUORUM_VERSION)-darwin-64.tar -C quorum-$(QUORUM_VERSION)-darwin-64/build/bin geth bootnode
	gzip build/quorum-$(QUORUM_VERSION)-darwin-64.tar

quorum-$(QUORUM_VERSION)-linux-amd64:
	git clone --branch $(QUORUM_VERSION) --depth 1 https://github.com/ConsenSys/quorum.git quorum-$(QUORUM_VERSION)-linux-amd64

quorum-$(QUORUM_VERSION)-linux-amd64/build/bin/geth: quorum-$(QUORUM_VERSION)-linux-amd64 build/.docker-build-$(VERSION)
	docker run -it -v $(CURDIR)/quorum-$(QUORUM_VERSION)-linux-amd64:/tmp/geth consensys/linux-build:$(VERSION) ./build-geth.sh

build/quorum-$(QUORUM_VERSION)-linux-amd64.tar.gz: quorum-$(QUORUM_VERSION)-linux-amd64/build/bin/geth
	mkdir -p build
	tar cf build/quorum-$(QUORUM_VERSION)-linux-amd64.tar -C docs/quorum .
	tar rf build/quorum-$(QUORUM_VERSION)-linux-amd64.tar -C quorum-$(QUORUM_VERSION)-linux-amd64/build/bin geth bootnode
	gzip build/quorum-$(QUORUM_VERSION)-linux-amd64.tar

constellation-$(CONSTELLATION_VERSION):
	git clone --branch $(CONSTELLATION_VERSION) --depth 1 https://github.com/jpmorganchase/constellation.git constellation-$(CONSTELLATION_VERSION)

constellation-$(CONSTELLATION_VERSION)/bin/constellation-node: constellation-$(CONSTELLATION_VERSION)
	cd constellation-$(CONSTELLATION_VERSION) && stack install && cp $(HOME)/.local/bin/constellation-node ./bin/

build/constellation-$(CONSTELLATION_VERSION)-darwin-64.tar.gz: constellation-$(CONSTELLATION_VERSION)/bin/constellation-node
	mkdir -p build
	tar cf build/constellation-$(CONSTELLATION_VERSION)-darwin-64.tar -C docs/constellation .
	tar rf build/constellation-$(CONSTELLATION_VERSION)-darwin-64.tar -C constellation-$(CONSTELLATION_VERSION)/bin constellation-node
	gzip build/constellation-$(CONSTELLATION_VERSION)-darwin-64.tar

constellation-$(CONSTELLATION_VERSION)-linux-amd64:
	git clone --branch $(CONSTELLATION_VERSION) --depth 1 https://github.com/jpmorganchase/constellation.git constellation-$(CONSTELLATION_VERSION)-linux-amd64

crux-$(CRUX_VERSION):
	git clone --branch $(CRUX_VERSION) --depth 1 https://github.com/blk-io/crux.git crux-$(CRUX_VERSION)

crux-$(CRUX_VERSION)/bin/crux: crux-$(CRUX_VERSION)
	cd crux-$(CRUX_VERSION) && make setup && make

build/crux-$(CRUX_VERSION)-darwin-64.tar.gz: crux-$(CRUX_VERSION)/bin/crux
	mkdir -p build
	tar cf build/crux-$(CRUX_VERSION)-darwin-64.tar -C docs/crux .
	tar rf build/crux-$(CRUX_VERSION)-darwin-64.tar -C crux-$(CRUX_VERSION)/bin crux
	gzip build/crux-$(CRUX_VERSION)-darwin-64.tar

crux-$(CRUX_VERSION)-linux-amd64:
	git clone --branch $(CRUX_VERSION) --depth 1 https://github.com/blk-io/crux.git crux-$(CRUX_VERSION)-linux-amd64

build/.docker-build-$(VERSION):
	mkdir -p build
	docker build -f docker/linux-build.Dockerfile -t consensys/linux-build:$(VERSION) .
	touch build/.docker-build-$(VERSION)

constellation-$(CONSTELLATION_VERSION)-linux-amd64/bin/constellation-node: constellation-$(CONSTELLATION_VERSION)-linux-amd64 build/.docker-build-$(VERSION)
	docker run -it -v $(CURDIR)/constellation-$(CONSTELLATION_VERSION)-linux-amd64:/tmp/constellation consensys/linux-build:$(VERSION) ./build-constellation.sh

build/constellation-$(CONSTELLATION_VERSION)-linux-amd64.tar.gz: constellation-$(CONSTELLATION_VERSION)-linux-amd64/bin/constellation-node
	mkdir -p build
	docker run -it -v $(CURDIR)/constellation-$(CONSTELLATION_VERSION)-linux-amd64:/tmp/constellation consensys/linux-build:$(VERSION) /bin/bash -c "cp /tmp/constellation/.stack-work/install/x86_64-linux/lts-10.5/8.2.2/bin/constellation-node /tmp/constellation/bin/ && ldd /tmp/constellation/bin/constellation-node | cut -f3- -d ' ' | grep '^/.*' | cut -f1 -d ' '| xargs -I '{}' cp -v '{}' /tmp/constellation/bin/"
	tar cf build/constellation-$(CONSTELLATION_VERSION)-linux-amd64.tar -C docs/constellation .
	tar rf build/constellation-$(CONSTELLATION_VERSION)-linux-amd64.tar -C constellation-$(CONSTELLATION_VERSION)-linux-amd64/bin constellation-node
	find constellation-$(CONSTELLATION_VERSION)-linux-amd64/bin -name '*.so.*' | xargs tar rf build/constellation-$(CONSTELLATION_VERSION)-linux-amd64.tar
	gzip build/constellation-$(CONSTELLATION_VERSION)-linux-amd64.tar

crux-$(CRUX_VERSION)-linux-amd64/bin/crux: crux-$(CRUX_VERSION)-linux-amd64 build/.docker-build-$(VERSION)
	docker run -it -v $(CURDIR)/crux-$(CRUX_VERSION)-linux-amd64:/tmp/crux consensys/linux-build:$(VERSION) ./build-crux.sh

build/crux-$(CRUX_VERSION)-linux-amd64.tar.gz: crux-$(CRUX_VERSION)-linux-amd64/bin/crux
	mkdir -p build
	tar cf build/crux-$(CRUX_VERSION)-linux-amd64.tar -C docs/crux .
	tar rf build/crux-$(CRUX_VERSION)-linux-amd64.tar -C crux-$(CRUX_VERSION)-linux-amd64/bin crux
	gzip build/crux-$(CRUX_VERSION)-linux-amd64.tar

build/.docker-$(VERSION)-quorum: build/qbc-$(VERSION)-linux-amd64.tar.gz build/qbc-$(VERSION)-darwin-64.tar.gz
	docker build -f docker/quorum.Dockerfile -t consensys/quorum:$(VERSION) .
	docker tag consensys/quorum:$(VERSION) consensys/quorum:latest
	touch build/.docker-$(VERSION)-quorum

build/.docker-$(VERSION)-crux: build/qbc-$(VERSION)-linux-amd64.tar.gz build/qbc-$(VERSION)-darwin-64.tar.gz
	docker build -f docker/crux.Dockerfile -t consensys/crux:$(VERSION) .
	docker tag consensys/crux:$(VERSION) consensys/crux:latest
	touch build/.docker-$(VERSION)-crux

build/.docker-$(VERSION)-constellation: build/qbc-$(VERSION)-linux-amd64.tar.gz build/qbc-$(VERSION)-darwin-64.tar.gz
	docker build -f docker/constellation.Dockerfile -t consensys/constellation:$(VERSION) .
	docker tag consensys/constellation:$(VERSION) consensys/constellation:latest
	touch build/.docker-$(VERSION)-constellation

build/.docker-$(VERSION): build/.docker-$(VERSION)-quorum build/.docker-$(VERSION)-constellation build/.docker-$(VERSION)-crux
	touch build/.docker-$(VERSION)

build/.dockerpush-$(VERSION): build/.docker-$(VERSION)-quorum build/.docker-$(VERSION)-constellation build/.docker-$(VERSION)-crux
	docker login -u $(BINTRAY_USER) -p $(BINTRAY_KEY) consensys-docker-qbc.bintray.io
	docker tag consensys/quorum:$(VERSION) consensys-docker-qbc.bintray.io/consensys/quorum:$(VERSION)
	docker push consensys-docker-qbc.bintray.io/consensys/quorum:$(VERSION)
	docker tag consensys/constellation:$(VERSION) consensys-docker-qbc.bintray.io/consensys/constellation:$(VERSION)
	docker push consensys-docker-qbc.bintray.io/consensys/constellation:$(VERSION)
	docker tag consensys/crux:$(VERSION) consensys-docker-qbc.bintray.io/consensys/crux:$(VERSION)
	docker push consensys-docker-qbc.bintray.io/consensys/crux:$(VERSION)
	touch build/.dockerpush-$(VERSION)

clean:
	rm -Rf constellation-*
	rm -Rf crux-*
	rm -Rf quorum-*
	rm -Rf build

build/qbc-$(VERSION)-linux-amd64.tar.gz.asc: build/qbc-$(VERSION)-linux-amd64.tar.gz
	gpg --detach-sign -o build/qbc-$(VERSION)-linux-amd64.tar.gz.asc build/qbc-$(VERSION)-linux-amd64.tar.gz

build/qbc-$(VERSION)-darwin-64.tar.gz.asc: build/qbc-$(VERSION)-darwin-64.tar.gz
	gpg --detach-sign -o build/qbc-$(VERSION)-darwin-64.tar.gz.asc build/qbc-$(VERSION)-darwin-64.tar.gz

build/.tgzpush-$(VERSION): build/qbc-$(VERSION)-linux-amd64.tar.gz.asc build/qbc-$(VERSION)-darwin-64.tar.gz.asc
	curl -T build/qbc-$(VERSION)-linux-amd64.tar.gz -u$(BINTRAY_USER):$(BINTRAY_KEY) -H "X-Bintray-Package:qbc" -H "X-Bintray-Version:$(VERSION)" https://api.bintray.com/content/consensys/binaries/qbc/$(VERSION)/qbc-$(VERSION)-linux-amd64.tar.gz
	curl -T build/qbc-$(VERSION)-linux-amd64.tar.gz.asc -u$(BINTRAY_USER):$(BINTRAY_KEY) -H "X-Bintray-Package:qbc" -H "X-Bintray-Version:$(VERSION)" https://api.bintray.com/content/consensys/binaries/qbc/$(VERSION)/qbc-$(VERSION)-linux-amd64.tar.gz.asc
	curl -T build/qbc-$(VERSION)-darwin-64.tar.gz -u$(BINTRAY_USER):$(BINTRAY_KEY) -H "X-Bintray-Package:qbc" -H "X-Bintray-Version:$(VERSION)" https://api.bintray.com/content/consensys/binaries/qbc/$(VERSION)/qbc-$(VERSION)-darwin-64.tar.gz
	curl -T build/qbc-$(VERSION)-darwin-64.tar.gz.asc -u$(BINTRAY_USER):$(BINTRAY_KEY) -H "X-Bintray-Package:qbc" -H "X-Bintray-Version:$(VERSION)" https://api.bintray.com/content/consensys/binaries/qbc/$(VERSION)/qbc-$(VERSION)-darwin-64.tar.gz.asc
	touch build/.tgzpush-$(VERSION)

tag:
	git tag -s $(VERSION)

release: tag build/.dockerpush-$(VERSION) build/.tgzpush-$(VERSION)
	git push origin master --tags

circleci-macos: build/qbc-$(VERSION)-darwin-64.tar.gz

