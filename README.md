# Quorum By ConsenSys [![CircleCI](https://circleci.com/gh/ConsenSys/qbc.svg?style=svg)](https://circleci.com/gh/ConsenSys/qbc)

Distribution of Quorum and associated projects, tested and supported by ConsenSys.

# Download

You can download binaries created with this project under:
   https://consensys.bintray.com/binaries/qbc/0.3

# Docker images

You can pull Docker images for Quorum, Crux, and Constellation:
```
docker pull consensys/quorum:0.3
docker pull consensys/crux:0.3
docker pull consensys/constellation:0.3
```

# Docker example

Clone the repository and enter the `tests` folder.
Pick a scenario and run `make` in its root folder.
Run `docker ps` to see the instances running.

See requirements to run scenarios under our [development guidelines](DEVELOP.md).

# Creating a network

## Create the initial node
Clone the repository and run `docs/scripts/init.sh` in a folder where the execution will take place.

By default, the script will assume the node exposes on 0.0.0.0 and uses the current folder for installation.

You can also run `docs/scripts/init.sh 192.168.0.5 ~/workspace` for example, for the script to expose the node to the network interface 192.168.0.5 and install all data under `~/workspace`.


## Add a node to the network
When the original node is launched, it creates the file `configs/init.zip` under the initial folder.

To join the network, copy `configs/init.zip` to the current folder, and run: `docs/script/join.sh 0.0.0.0 0.0.0.0`, where the first argument is the IP to bind the new node to, and the second argument the address of the first instance for discovery purposes.

## Accept a node into the network
During the previous step, the file `configs/join.zip` should be generated under the working folder.

For the node to be added to the network, all members of the network should get a copy of that file and install it as follows:

```
unzip join.zip -d $(WORKDIR)/q1/dd/
docker restart <quorum instance>
```

The first line unzips new configurations over the current node configuration.
The second line restarts the Quorum container. 

## More

See [our complete howto](docs/HOWTO.md) for more information on network formation.

# Contribute

See [our contributing guide](CONTRIBUTING.md).

# Developing with Quorum by ConsenSys

Read more about the [development guidelines](DEVELOP.md) of this project.

