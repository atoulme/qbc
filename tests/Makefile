SHELL := /bin/bash

test:
	@echo "Make sure all containers are stopped"
	@cd constellation_quorum && ( make stop && cd .. || cd .. )
	@cd crux_quorum && ( make stop && cd .. || cd .. )
	@cd crux_relays_quorum && ( make stop && cd .. || cd .. )
	@cd tessera_quorum && ( make stop && cd .. || cd .. )
	@echo "Run Tests"
	@cd constellation_quorum && make clean && ( make test && make stop || make stop )
	@cd crux_quorum && make stop && make clean && ( make test && make stop || make stop )
	@cd crux_relays_quorum && make stop && make clean && ( make test && make stop || make stop )
	@cd tessera_quorum && make stop && make clean && ( make test && make stop || make stop )