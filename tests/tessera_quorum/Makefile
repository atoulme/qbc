.DEFAULT_GOAL := test
PERMISSIONED_NODES=
GETH_KEY=	
$(eval WORKDIR = $(shell cat .workdir))

.PHONY: clean stop test

.workdir:
	$(eval WORKDIR = $(shell mktemp -t tessera_quorum -d))
	bash config.sh $(WORKDIR) $(CURDIR)
	mkdir -p $(WORKDIR)/c1/logs $(WORKDIR)/c2/logs $(WORKDIR)/c3/logs $(WORKDIR)/c4/logs

.start: .workdir
	env WORKDIR=$(WORKDIR) docker-compose up -d
	touch .start

.check_up: .start
	$(eval OK = 200)
	$(eval HTTP_STATUS = $(shell curl -s -o /dev/null -w "%{http_code}" "http://localhost:9002/upcheck"))
	@if [ "$(HTTP_STATUS)" -eq "$(OK)" ]; then \
		echo "upcheck succeeded with HTTP_STATUS: $(HTTP_STATUS)"; \
		touch .check_up; \
	else \
		echo "upcheck failed with HTTP_STATUS: $(HTTP_STATUS)" 1>&2; \
		exit 1; \
	fi

test: .check_up
	bash runTests.sh

stop:
	docker-compose down
	rm -f .start

clean:
	rm -Rf $(TMPDIR)tessera_quorum.*
	rm -f .workdir