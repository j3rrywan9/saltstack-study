# Installation

## Debian 8

### Installation from the official SaltStack repository

Pin to minor release `2016.3.1`

Run the following command to import the SaltStack repository key:
```bash
wget -O - https://repo.saltstack.com/apt/debian/8/amd64/archive/2016.3.1/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
```

Save the following file to `/etc/apt/sources.list.d/saltstack.list`:
```
deb http://repo.saltstack.com/apt/debian/8/amd64/archive/2016.3.1 jessie main
```

### Install packages

#### Minion

Run
```bash
sudo apt-get update && sudo apt-get install -y salt-minion
```

#### Master

Run
```bash
sudo apt-get update && sudo apt-get install -y salt-master salt-minion
```

Before commands can be sent to a minion, its key must be accepted on the master.
Run the `salt-key` command to list the keys known to the Salt master:

```bash
sudo salt-key -L
```
To accept the keys and allow the minions to be controlled by the master, again use the `salt-key` command:

```bash
sudo salt-key -A
```
