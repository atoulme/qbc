# Quorum By ConsenSys

Distribution of Quorum and associated projects, tested and supported by ConsenSys.

# Download

You can download binaries created with this project under:
   https://consensys.bintray.com/binaries/qbc/$VERSION

# Docker images

You can pull Docker images for Quorum, Crux, and Constellation:
```
docker pull consensys-docker-qbc.bintray.io/qbc/quorum:$VERSION
docker pull consensys-docker-qbc.bintray.io/qbc/crux:$VERSION
docker pull consensys-docker-qbc.bintray.io/qbc/constellation:$VERSION
```

# Development

## Docker

Install:
```
  $> curl -fsSL get.docker.com -o get-docker.sh
  $> sh get-docker.sh
```


Config:  

- REQUIRED: `Add /var/folders to Preferences > File Sharing`
- OPTIONAL: `Preferences > Advanced, Memory: Increase from 2 GB to 4 GB
> NOTE: Parrallel build are more resource intensive and might require this step

## Binaries

On a Mac machine, install required binaries for all projects:

`$> brew install berkeley-db leveldb libsodium maven haskell-stack go node`

You will also need java: `brew cask install java`

Install the Glasgow Haskell Compiler: `stack setup`

# Building

To clean, make tarballs, containers, and run tests:
```
$> make all
```
To make tarballs and containers:
```
$> make qbc
```
To build the qbc tarball, run:
```
$> make BUILDS=linux-64 qbc-tarballs
```
> Note: To speed up the build you can add the -j [jobs] flag to the make command

### Build Targets:

By default, the build process will generate linux-64 and darwin-64 binaries.  You can override this modifying the BUILDS variable:
```
make BUILDS=linux-64 all
```
The following build targets have been tested:
- linux-64 
- darwin-64

# Testing

Run:
```
$> make test
```

# Release

Make sure the version is correct in config.mk.

Run:
```
$> make BINTRAY_USER=<YOUR USERNAME> BINTRAY_KEY=<YOUR KEY> release
```

Once the process has run:
* Update the download links and the Docker image versions in the README.
* Increase the version in the Makefile.
* Commit and push changes.
