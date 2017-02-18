# Installation

## Debian 8

Pin to minor release `2016.3.1`

Run the following command to import the SaltStack repository key:
```bash
wget -O - https://repo.saltstack.com/apt/debian/8/amd64/archive/2016.3.1/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
```

Save the following file to `/etc/apt/sources.list.d/saltstack.list`:
```
deb http://repo.saltstack.com/apt/debian/8/amd64/archive/2016.3.1 jessie main
```

Run `sudo apt-get update`

```bash
sudo apt-get salt-master salt-minion
```

```bash
sudo salt-key -L

sudo salt-key -A
```
