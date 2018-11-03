.DEFAULT_GOAL := test

$(eval WORKDIR = $(shell cat .workdir))

.PHONY: clean stop test

.workdir:
	$(eval WORKDIR = $(shell mktemp -t init_join.XXXXX -d))
	echo $(WORKDIR) > .workdir

.network: .workdir
	docker network create -d bridge --subnet 10.5.0.0/24 scripts_quorum_net
	touch .network
	
.init: .network
	
	bash ../../docs/scripts/init.sh 10.5.0.12 10.5.0.11 $(WORKDIR) c1 q1 $(CURDIR)/initial_account_password.txt
	sleep 5
	touch .init
	
.add_new_peer: .init
	bash ../../docs/scripts/join.sh 10.5.0.14 10.5.0.13 10.5.0.12 $(WORKDIR) c2 q2 $(CURDIR)/initial_account_password.txt
	sleep 5
	unzip -o $(WORKDIR)/configs/join.zip -d $(WORKDIR)/q1/dd/
	docker restart quorum-10.5.0.12
	cp $(WORKDIR)/configs/join.zip $(WORKDIR)/configs/init.zip
	touch .add_new_peer
	
.add_new_peer2: .add_new_peer
	bash ../../docs/scripts/join.sh 10.5.0.16 10.5.0.15 10.5.0.12 $(WORKDIR) c3 q3 $(CURDIR)/initial_account_password.txt
	sleep 5
	unzip -o $(WORKDIR)/configs/join.zip -d $(WORKDIR)/q1/dd/
	unzip -o $(WORKDIR)/configs/join.zip -d $(WORKDIR)/q2/dd/
	docker restart quorum-10.5.0.12
	docker restart quorum-10.5.0.14
	touch .add_new_peer2
	
.add_new_peer3: .add_new_peer2
	bash ../../docs/scripts/join.sh 10.5.0.18 10.5.0.17 10.5.0.12 $(WORKDIR) c4 q4 $(CURDIR)/initial_account_password.txt
	sleep 5
	unzip -o $(WORKDIR)/configs/join.zip -d $(WORKDIR)/q1/dd/
	unzip -o $(WORKDIR)/configs/join.zip -d $(WORKDIR)/q2/dd/
	unzip -o $(WORKDIR)/configs/join.zip -d $(WORKDIR)/q3/dd/
	docker restart quorum-10.5.0.12
	docker restart quorum-10.5.0.14
	docker restart quorum-10.5.0.16
	touch .add_new_peer3
	
.add_new_peer4: .add_new_peer3
	bash ../../docs/scripts/join.sh 10.5.0.20 10.5.0.19 10.5.0.12 $(WORKDIR) c5 q5 $(CURDIR)/initial_account_password.txt
	sleep 5
	unzip -o $(WORKDIR)/configs/join.zip -d $(WORKDIR)/q1/dd/
	unzip -o $(WORKDIR)/configs/join.zip -d $(WORKDIR)/q2/dd/
	unzip -o $(WORKDIR)/configs/join.zip -d $(WORKDIR)/q3/dd/
	unzip -o $(WORKDIR)/configs/join.zip -d $(WORKDIR)/q4/dd/
	docker restart quorum-10.5.0.12
	docker restart quorum-10.5.0.14
	docker restart quorum-10.5.0.16
	docker restart quorum-10.5.0.18
	touch .add_new_peer4

.check_up: .add_new_peer4
	$(eval OK = 200)
	$(eval cruxport=$(shell docker port crux-10.5.0.11 | grep 9001 | cut -d ":" -f 2))
	$(eval HTTP_STATUS = $(shell curl -s -o /dev/null -w "%{http_code}" -X POST "http://0.0.0.0:$(cruxport)/upcheck"))
	@if [ "$(HTTP_STATUS)" -eq "$(OK)" ]; then \
		echo "upcheck succeeded with HTTP_STATUS: $(HTTP_STATUS)"; \
		touch .check_up; \
	else \
		echo "upcheck failed with HTTP_STATUS: $(HTTP_STATUS)" 1>&2; \
		exit 1; \
	fi
	$(eval port1= $(shell docker port quorum-10.5.0.12 | grep 22000 | cut -d ":" -f 2))
	$(eval port2= $(shell docker port quorum-10.5.0.14 | grep 22000 | cut -d ":" -f 2))
	$(eval port3= $(shell docker port quorum-10.5.0.16 | grep 22000 | cut -d ":" -f 2))
	bash waitForStart.sh $(port1) $(port2) $(port3)

test: .check_up
	$(eval port1=$(shell docker port quorum-10.5.0.12 | grep 22000 | cut -d ":" -f 2))
	$(eval port2=$(shell docker port quorum-10.5.0.14 | grep 22000 | cut -d ":" -f 2))
	$(eval port3=$(shell docker port quorum-10.5.0.16 | grep 22000 | cut -d ":" -f 2))
	$(eval from=$(shell curl -X POST --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' http://0.0.0.0:$(port1) | jq .result[0]))
	
	$(eval to_pubkey= $(shell cat $(WORKDIR)/c2/tm.pub))
	
	bash runTests.sh $(port1) $(port2) $(port3) $(from) $(from) $(to_pubkey) $(from)
	
stop:
	rm -f .check_up
	docker rm -f crux-10.5.0.11 quorum-10.5.0.12 crux-10.5.0.13 quorum-10.5.0.14 crux-10.5.0.15 quorum-10.5.0.16 crux-10.5.0.17 quorum-10.5.0.18 crux-10.5.0.19 quorum-10.5.0.20 || true
	rm -f .init ..add_new_peer add_new_peer2
	docker network rm scripts_quorum_net || true
	rm -f .network 

clean: stop
	rm -Rf $(TMPDIR)init_join.*
	rm -f .workdir