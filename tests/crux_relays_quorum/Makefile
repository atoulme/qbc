.DEFAULT_GOAL := test
PERMISSIONED_NODES=
GETH_KEY=
$(eval WORKDIR = $(shell cat .workdir))

.PHONY: clean stop test

.workdir:
	$(eval WORKDIR = $(shell mktemp -t crux__relays_quorum -d))
	mkdir -p $(WORKDIR)/q1/logs
	mkdir -p $(WORKDIR)/q1/dd/{keystore,geth}
	echo '["enode://5c3c98e3a28a87e73ab40468212de7ab6cf0e2afa77781295925f32369c00baf30f664e52f8d152c02b069d6daa1a61f477e3c1eca64403529dfbd0c31e09524@10.5.0.15:21000?discport=0",\
	      "enode://9b98a96a8ba080ff4c7863e5fdf3211a7082b612d5897ae4eed687eec391eb421c8ed7c572ca17f257441a0cb544a7c184244dfdf9a114f5251da3dac72e7585@10.5.0.16:21000?discport=0",\
				"enode://a51690b44ab39fd83c42b5a7c087ba222970951f06655ebbba1625267fad105fd238c9f092e05b2293f526e748b2fa423b22d66296f770037393c26a9e5d3543@10.5.0.17:21000?discport=0",\
				"enode://a68df7cd75e9ea490653bdba7c6868f979944578e59c9efd2aa62878822f16f46a49a13289f6392923053be1acb3a6ec8e2fc92cae59de859fd5892071fbfa88@10.5.0.18:21000?discport=0"]'\
				 >> $(WORKDIR)/q1/dd/static-nodes.json
	cp $(WORKDIR)/q1/dd/static-nodes.json $(WORKDIR)/q1/dd/permissioned-nodes.json
	touch $(WORKDIR)/q1/passwords.txt

	cp -R $(WORKDIR)/q1 $(WORKDIR)/q2
	cp -R $(WORKDIR)/q1 $(WORKDIR)/q3
	cp -R $(WORKDIR)/q1 $(WORKDIR)/q4

	echo '{"address":"ed9d02e382b34818e88b88a309c7fe71e65f419d","crypto":{"cipher":"aes-128-ctr","ciphertext":"4e77046ba3f699e744acb4a89c36a3ea1158a1bd90a076d36675f4c883864377","cipherparams":{"iv":"a8932af2a3c0225ee8e872bc0e462c11"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"8ca49552b3e92f79c51f2cd3d38dfc723412c212e702bd337a3724e8937aff0f"},"mac":"6d1354fef5aa0418389b1a5d1f5ee0050d7273292a1171c51fd02f9ecff55264"},"id":"a65d1ac3-db7e-445d-a1cc-b6c5eeaa05e0","version":3}' >> $(WORKDIR)/q1/dd/keystore/key
	echo '{"address":"ca843569e3427144cead5e4d5999a3d0ccf92b8e","crypto":{"cipher":"aes-128-ctr","ciphertext":"01d409941ce57b83a18597058033657182ffb10ae15d7d0906b8a8c04c8d1e3a","cipherparams":{"iv":"0bfb6eadbe0ab7ffaac7e1be285fb4e5"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"7b90f455a95942c7c682e0ef080afc2b494ef71e749ba5b384700ecbe6f4a1bf"},"mac":"4cc851f9349972f851d03d75a96383a37557f7c0055763c673e922de55e9e307"},"id":"354e3b35-1fed-407d-a358-889a29111211","version":3}' >> $(WORKDIR)/q2/dd/keystore/key
	echo '{"address":"0fbdc686b912d7722dc86510934589e0aaf3b55a","crypto":{"cipher":"aes-128-ctr","ciphertext":"6b2c72c6793f3da8185e36536e02f574805e41c18f551f24b58346ef4ecf3640","cipherparams":{"iv":"582f27a739f39580410faa108d5cc59f"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"1a79b0db3f8cb5c2ae4fa6ccb2b5917ce446bd5e42c8d61faeee512b97b4ad4a"},"mac":"cecb44d2797d6946805d5d744ff803805477195fab1d2209eddc3d1158f2e403"},"id":"f7292e90-af71-49af-a5b3-40e8493f4681","version":3}' >> $(WORKDIR)/q3/dd/keystore/key
	echo '{"address":"9186eb3d20cbd1f5f992a950d808c4495153abd5","crypto":{"cipher":"aes-128-ctr","ciphertext":"d160a630a39be3ff35556055406d8ff2a635f0535fe298d62ccc812d8f7b3bd5","cipherparams":{"iv":"82fce06bc6e1658a5e81ccef3b753329"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"8d0c486db4c942721f4f5e96d48e9344805d101dad8159962b8a2008ac718548"},"mac":"4a92bda949068968d470320260ae1a825aa22f6a40fb8567c9f91d700c3f7e91"},"id":"bdb3b4f6-d8d0-4b00-8473-e223ef371b5c","version":3}' >> $(WORKDIR)/q4/dd/keystore/key

	echo '633b2ef3ed5306f05a532eb44eb84858aca470d4fde039c1c988088e48070e64' >> $(WORKDIR)/q1/nodekey
	echo 'd5b8dfced693dbb7bf858dce40e3b2a0373696ac88ccf5e1c0052e26b7d77e49' >> $(WORKDIR)/q2/nodekey
	echo '45d87820ad7792f86592a8e3494c3e78b4755a480cfad1799d6c3f28c3f0d87c' >> $(WORKDIR)/q3/nodekey
	echo 'daa89d4ae250d24b33847343d0cc0116c48331b81e28514522bb7f77f2be5676' >> $(WORKDIR)/q4/nodekey

	docker run -it -v $(WORKDIR)/q1:/var/qdata/ -v $(CURDIR)/istanbul-genesis.json:/tmp/istanbul-genesis.json \
	  consensys/quorum:latest /opt/geth --datadir /var/qdata/dd init /tmp/istanbul-genesis.json
	docker run -it -v $(WORKDIR)/q2:/var/qdata/ -v $(CURDIR)/istanbul-genesis.json:/tmp/istanbul-genesis.json \
	  consensys/quorum:latest /opt/geth --datadir /var/qdata/dd init /tmp/istanbul-genesis.json
	docker run -it -v $(WORKDIR)/q3:/var/qdata/ -v $(CURDIR)/istanbul-genesis.json:/tmp/istanbul-genesis.json \
	  consensys/quorum:latest /opt/geth --datadir /var/qdata/dd init /tmp/istanbul-genesis.json
	docker run -it -v $(WORKDIR)/q4:/var/qdata/ -v $(CURDIR)/istanbul-genesis.json:/tmp/istanbul-genesis.json \
	  consensys/quorum:latest /opt/geth --datadir /var/qdata/dd init /tmp/istanbul-genesis.json

	mkdir -p $(WORKDIR)/c1/logs $(WORKDIR)/c2/logs $(WORKDIR)/c3/logs $(WORKDIR)/c4/logs
	echo "BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo=" >> $(WORKDIR)/c1/tm.pub
	echo '{"data":{"bytes":"Wl+xSyXVuuqzpvznOS7dOobhcn4C5auxkFRi7yLtgtA="},"type":"unlocked"}' >> $(WORKDIR)/c1/tm.key

	echo "QfeDAys9MPDs2XHExtc84jKGHxZg/aj52DTh0vtA3Xc=" >> $(WORKDIR)/c2/tm.pub
	echo '{"data":{"bytes":"nDFwJNHSiT1gNzKBy9WJvMhmYRkW3TzFUmPsNzR6oFk="},"type":"unlocked"}' >> $(WORKDIR)/c2/tm.key

	echo "1iTZde/ndBHvzhcl7V68x44Vx7pl8nwx9LqnM/AfJUg=" >> $(WORKDIR)/c3/tm.pub
	echo '{"data":{"bytes":"tMxUVR8bX7aq/TbpVHc2QV3SN2iUuExBwefAuFsO0Lg="},"type":"unlocked"}' >> $(WORKDIR)/c3/tm.key

	echo "oNspPPgszVUFw0qmGFfWwh1uxVUXgvBxleXORHj07g8=" >> $(WORKDIR)/c4/tm.pub
	echo '{"data":{"bytes":"grQjd3dBp4qFs8/5Jdq7xjz++aUx/LXAqISFyPWaCRw="},"type":"unlocked"}' >> $(WORKDIR)/c4/tm.key
	
	mkdir -p $(WORKDIR)/r1/logs
	mkdir -p $(WORKDIR)/r2/logs
	
	echo $(WORKDIR) > .workdir

.start: .workdir
	env WORKDIR=$(WORKDIR) docker-compose up -d
	bash waitForStart.sh
	touch .start

.check_up: .start
	$(eval OK = 200)
	$(eval HTTP_STATUS = $(shell curl -s -o /dev/null -w "%{http_code}" -X POST "http://localhost:3011/upcheck"))
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
	rm -Rf $(TMPDIR)crux_relays_quorum.*
	rm -f .workdir