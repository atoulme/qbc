VERSION=0.3
TESSERA_VERSION=0.6.1-qbc
QUORUM_VERSION=v2.1.1-grpc
CRUX_VERSION=master
GOOS=darwin
GOARCH=386
BINTRAY_USER=jdoe
BINTRAY_KEY=pass

.PHONY: clean release check_bintray tag test
.DEFAULT_GOAL := build/.docker-$(VERSION)

build/qbc-$(VERSION)-linux-386.tar.gz: build/tessera-$(TESSERA_VERSION).tar.gz build/quorum-$(QUORUM_VERSION)-linux-386.tar.gz build/crux-$(CRUX_VERSION)-linux-386.tar.gz
	cd build && tar czf qbc-$(VERSION)-linux-386.tar.gz tessera-$(TESSERA_VERSION).tar.gz quorum-$(QUORUM_VERSION)-linux-386.tar.gz crux-$(CRUX_VERSION)-linux-386.tar.gz

build/qbc-$(VERSION)-darwin-64.tar.gz: build/tessera-$(TESSERA_VERSION).tar.gz build/quorum-$(QUORUM_VERSION)-darwin-64.tar.gz build/crux-$(CRUX_VERSION)-darwin-64.tar.gz
	cd build && tar czf qbc-$(VERSION)-darwin-64.tar.gz tessera-$(TESSERA_VERSION).tar.gz quorum-$(QUORUM_VERSION)-darwin-64.tar.gz crux-$(CRUX_VERSION)-darwin-64.tar.gz

tessera-$(TESSERA_VERSION):
	git clone --branch $(TESSERA_VERSION) --depth 1 https://github.com/consensys/tessera.git tessera-$(TESSERA_VERSION)

tessera-$(TESSERA_VERSION)/tessera-app/target/tessera-app-$(TESSERA_VERSION)-app.jar: tessera-$(TESSERA_VERSION)
	cd tessera-$(TESSERA_VERSION) && mvn package
	cd tessera-$(TESSERA_VERSION)/tessera-app/target/ && mv tessera-app-*-app.jar tessera-app-$(TESSERA_VERSION)-app.jar

build/tessera-$(TESSERA_VERSION).tar.gz: tessera-$(TESSERA_VERSION)/tessera-app/target/tessera-app-$(TESSERA_VERSION)-app.jar
	mkdir -p build
	tar cf build/tessera-$(TESSERA_VERSION).tar -C docs/tessera .
	tar rf build/tessera-$(TESSERA_VERSION).tar -C tessera-$(TESSERA_VERSION)/tessera-app/target tessera-app-$(TESSERA_VERSION)-app.jar
	gzip build/tessera-$(TESSERA_VERSION).tar

quorum-$(QUORUM_VERSION)-darwin-64:
	git clone --branch $(QUORUM_VERSION) --depth 1 https://github.com/ConsenSys/quorum.git quorum-$(QUORUM_VERSION)-darwin-64

quorum-$(QUORUM_VERSION)-darwin-64/build/bin/geth: quorum-$(QUORUM_VERSION)-darwin-64
	cd quorum-$(QUORUM_VERSION)-darwin-64 && make all

build/quorum-$(QUORUM_VERSION)-darwin-64.tar.gz: quorum-$(QUORUM_VERSION)-darwin-64/build/bin/geth
	mkdir -p build
	tar cf build/quorum-$(QUORUM_VERSION)-darwin-64.tar -C docs/quorum .
	tar rf build/quorum-$(QUORUM_VERSION)-darwin-64.tar -C quorum-$(QUORUM_VERSION)-darwin-64/build/bin geth bootnode
	gzip build/quorum-$(QUORUM_VERSION)-darwin-64.tar

quorum-$(QUORUM_VERSION)-linux-386:
	git clone --branch $(QUORUM_VERSION) --depth 1 https://github.com/ConsenSys/quorum.git quorum-$(QUORUM_VERSION)-linux-386

quorum-$(QUORUM_VERSION)-linux-386/build/bin/geth: quorum-$(QUORUM_VERSION)-linux-386 build/.docker-build-$(VERSION)
	docker run -it -v $(CURDIR)/quorum-$(QUORUM_VERSION)-linux-386:/tmp/geth consensys/linux-build:$(VERSION) ./build-geth.sh

build/quorum-$(QUORUM_VERSION)-linux-386.tar.gz: quorum-$(QUORUM_VERSION)-linux-386/build/bin/geth
	mkdir -p build
	tar cf build/quorum-$(QUORUM_VERSION)-linux-386.tar -C docs/quorum .
	tar rf build/quorum-$(QUORUM_VERSION)-linux-386.tar -C quorum-$(QUORUM_VERSION)-linux-386/build/bin geth bootnode
	gzip build/quorum-$(QUORUM_VERSION)-linux-386.tar

crux-$(CRUX_VERSION):
	git clone --branch $(CRUX_VERSION) --depth 1 https://github.com/blk-io/crux.git crux-$(CRUX_VERSION)

crux-$(CRUX_VERSION)/bin/crux: crux-$(CRUX_VERSION)
	cd crux-$(CRUX_VERSION) && make setup && make

build/crux-$(CRUX_VERSION)-darwin-64.tar.gz: crux-$(CRUX_VERSION)/bin/crux
	mkdir -p build
	tar cf build/crux-$(CRUX_VERSION)-darwin-64.tar -C docs/crux .
	tar rf build/crux-$(CRUX_VERSION)-darwin-64.tar -C crux-$(CRUX_VERSION)/bin crux
	gzip build/crux-$(CRUX_VERSION)-darwin-64.tar

crux-$(CRUX_VERSION)-linux-386:
	git clone --branch $(CRUX_VERSION) --depth 1 https://github.com/blk-io/crux.git crux-$(CRUX_VERSION)-linux-386

build/.docker-build-$(VERSION):
	docker build -f docker/linux-build.Dockerfile -t consensys/linux-build:$(VERSION) .
	touch build/.docker-build-$(VERSION)

crux-$(CRUX_VERSION)-linux-386/bin/crux: crux-$(CRUX_VERSION)-linux-386 build/.docker-build-$(VERSION)
	docker run -it -v $(CURDIR)/crux-$(CRUX_VERSION)-linux-386:/tmp/crux consensys/linux-build:$(VERSION)

build/crux-$(CRUX_VERSION)-linux-386.tar.gz: crux-$(CRUX_VERSION)-linux-386/bin/crux
	mkdir -p build
	tar cf build/crux-$(CRUX_VERSION)-linux-386.tar -C docs/crux .
	tar rf build/crux-$(CRUX_VERSION)-linux-386.tar -C crux-$(CRUX_VERSION)-linux-386/bin crux
	gzip build/crux-$(CRUX_VERSION)-linux-386.tar

build/.docker-$(VERSION)-quorum: build/qbc-$(VERSION)-linux-386.tar.gz build/qbc-$(VERSION)-darwin-64.tar.gz
	docker build -f docker/quorum.Dockerfile -t consensys/quorum:$(VERSION) .
	docker tag consensys/quorum:$(VERSION) consensys/quorum:latest
	touch build/.docker-$(VERSION)-quorum

build/.docker-$(VERSION)-crux: build/qbc-$(VERSION)-linux-386.tar.gz build/qbc-$(VERSION)-darwin-64.tar.gz
	docker build -f docker/crux.Dockerfile -t consensys/crux:$(VERSION) .
	docker tag consensys/crux:$(VERSION) consensys/crux:latest
	touch build/.docker-$(VERSION)-crux

build/.docker-$(VERSION)-tessera: build/qbc-$(VERSION)-linux-386.tar.gz build/qbc-$(VERSION)-darwin-64.tar.gz
	docker build -f docker/tessera.Dockerfile -t consensys/tessera:$(VERSION) .
	docker tag consensys/tessera:$(VERSION) consensys/tessera:latest
	touch build/.docker-$(VERSION)-tessera

build/.docker-$(VERSION): build/.docker-$(VERSION)-quorum build/.docker-$(VERSION)-tessera build/.docker-$(VERSION)-crux
	touch build/.docker-$(VERSION)

build/.dockerpush-$(VERSION): build/.docker-$(VERSION)-tessera build/.docker-$(VERSION)-quorum build/.docker-$(VERSION)-crux
	docker login -u $(BINTRAY_USER) -p $(BINTRAY_KEY) consensys-docker-qbc.bintray.io
	docker tag consensys/quorum:$(VERSION) consensys-docker-qbc.bintray.io/consensys/quorum:$(VERSION)
	docker push consensys-docker-qbc.bintray.io/consensys/quorum:$(VERSION)
	docker tag consensys/crux:$(VERSION) consensys-docker-qbc.bintray.io/consensys/crux:$(VERSION)
	docker push consensys-docker-qbc.bintray.io/consensys/crux:$(VERSION)
	docker tag consensys/tessera:$(VERSION) consensys-docker-qbc.bintray.io/consensys/tessera:$(VERSION)
	docker push consensys-docker-qbc.bintray.io/consensys/tessera:$(VERSION)
	touch build/.dockerpush-$(VERSION)

clean:
	rm -Rf crux-*
	rm -Rf quorum-*
	rm -Rf tessera-*
	rm -Rf build

build/qbc-$(VERSION)-linux-386.tar.gz.asc: build/qbc-$(VERSION)-linux-386.tar.gz
	gpg --detach-sign -o build/qbc-$(VERSION)-linux-386.tar.gz.asc build/qbc-$(VERSION)-linux-386.tar.gz

build/qbc-$(VERSION)-darwin-64.tar.gz.asc: build/qbc-$(VERSION)-darwin-64.tar.gz
	gpg --detach-sign -o build/qbc-$(VERSION)-darwin-64.tar.gz.asc build/qbc-$(VERSION)-darwin-64.tar.gz

build/.tgzpush-$(VERSION): build/qbc-$(VERSION)-linux-386.tar.gz.asc build/qbc-$(VERSION)-darwin-64.tar.gz.asc
	curl -T build/qbc-$(VERSION)-linux-386.tar.gz -u$(BINTRAY_USER):$(BINTRAY_KEY) -H "X-Bintray-Package:qbc" -H "X-Bintray-Version:$(VERSION)" https://api.bintray.com/content/consensys/binaries/qbc/$(VERSION)/qbc-$(VERSION)-linux-386.tar.gz
	curl -T build/qbc-$(VERSION)-linux-386.tar.gz.asc -u$(BINTRAY_USER):$(BINTRAY_KEY) -H "X-Bintray-Package:qbc" -H "X-Bintray-Version:$(VERSION)" https://api.bintray.com/content/consensys/binaries/qbc/$(VERSION)/qbc-$(VERSION)-linux-386.tar.gz.asc
	curl -T build/qbc-$(VERSION)-darwin-64.tar.gz -u$(BINTRAY_USER):$(BINTRAY_KEY) -H "X-Bintray-Package:qbc" -H "X-Bintray-Version:$(VERSION)" https://api.bintray.com/content/consensys/binaries/qbc/$(VERSION)/qbc-$(VERSION)-darwin-64.tar.gz
	curl -T build/qbc-$(VERSION)-darwin-64.tar.gz.asc -u$(BINTRAY_USER):$(BINTRAY_KEY) -H "X-Bintray-Package:qbc" -H "X-Bintray-Version:$(VERSION)" https://api.bintray.com/content/consensys/binaries/qbc/$(VERSION)/qbc-$(VERSION)-darwin-64.tar.gz.asc
	touch build/.tgzpush-$(VERSION)

tag:
	git tag -s $(VERSION)

release: tag build/.dockerpush-$(VERSION) build/.tgzpush-$(VERSION)
	git push origin master --tags

test: build/.docker-$(VERSION)
	$(error TODO)
