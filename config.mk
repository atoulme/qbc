##################### DISTRIBUTION CONFIGURATION #####################
# High level configuration variables that will affect how the QBC 
# distribution is built.
######################################################################
# QBC is the name of the distribution
QBC_NAME = qbc
# increment the qbc version when a new release is made
VERSION = 0.4
# directory to build the qbc project
BUILDDIR = build
# list of build targets: linux|darwin-64|32
BUILDS = linux-64 darwin-64
# determined automatically from the system
HOST_OS = $(shell uname -s | tr '[:upper:]' '[:lower:]')
# not used currently
GUEST_OS = $(filter $(HOST_OS),$(BUILDS))
# variable needed for cross compiling go targets
GOOS = darwin
GOARCH = 64
# credentials needed to deploy tarballs to bintray
BINTRAY_USER = jdoe
BINTRAY_KEY = pass

####################### PROJECT CONFIGURATION #######################
# Add a new project to the QBC DIST by implementing the following template:
#   PROJECT_NAME = name of the project
#   PROJECT_VERSION = the branch/tag of the git repo
#   PROJECT_REPO = the url of the git repo
#   PROJECT_BUILD = build command
#   PROJECT_BINPATH = path to the executable (full or relative to project rootroot)
#   PROJECT_OUTFILES = executable name(s)
######################################################################
# quorum config vars
QUORUM_NAME = quorum
QUORUM_VERSION = v2.1.1-grpc
QUORUM_REPO = https://github.com/ConsenSys/quorum.git
QUORUM_BUILD = make all
QUORUM_BINPATH = build/bin
QUORUM_OUTFILES = geth bootnode
# constellation config vars
CONSTELLATION_NAME = constellation
CONSTELLATION_VERSION = v0.3.2
CONSTELLATION_REPO = https://github.com/jpmorganchase/constellation.git
CONSTELLATION_BUILD = stack --allow-different-user install && cp $(HOME)/.local/bin/constellation-node ./bin/
CONSTELLATION_BINPATH = bin
CONSTELLATION_OUTFILES = constellation-node
# crux config vars
CRUX_NAME = crux
CRUX_VERSION = v1.0.3
CRUX_REPO = https://github.com/blk-io/crux.git
CRUX_BUILD = make setup && make
CRUX_BINPATH = bin
CRUX_OUTFILES = crux
# istanbul-tools config vars
ISTANBUL_NAME = istanbul
ISTANBUL_VERSION = v1.0.2-grpc
ISTANBUL_REPO = https://github.com/consensys/istanbul-tools.git
ISTANBUL_BUILD = mkdir -p .build/src/github.com/jpmorganchase/ && ln -sf `pwd` .build/src/github.com/jpmorganchase/istanbul-tools && export GOPATH=`pwd`/.build && cd .build/src/github.com/jpmorganchase/istanbul-tools && make
ISTANBUL_BINPATH = build/bin
ISTANBUL_OUTFILES = istanbul
# Tessera config vars
TESSERA_NAME = tessera
TESSERA_VERSION = tessera-0.7.3
TESSERA_REPO = https://github.com/jpmorganchase/tessera.git
TESSERA_BUILD = mvn package
TESSERA_BINPATH = tessera-app/target
TESSERA_OUTFILES = tessera-app-0.7.3-app.jar
# blockscout config vars
BLOCKSCOUT_NAME = blockscout
BLOCKSCOUT_VERSION = master
BLOCKSCOUT_REPO = https://github.com/poanetwork/blockscout.git
BLOCKSCOUT_BUILD = "MIX_ENV=prod mix do deps.get, release --env prod"
BLOCKSCOUT_BINPATH =
BLOCKSCOUT_OUTFILES = .
