# Configuration

## Master

The configuration file for the Salt master is located at `/etc/salt/master` by default.

### Master file server settings

Salt runs a lightweight file server written in ZeroMQ to deliver files to minions.
This file server is built into the master daemon and does not require a dedicated port.

The file server works on environments passed to the master.
Each environment can have multiple root directories.
The subdirectories in the multiple file roots cannot match, otherwise the downloaded files will not be able to be reliably ensured.
A base environment is required to house the top file.

```yaml
user: root

file_roots:
  base:
    - /srv/salt/base/states
    - /srv/salt/base/formulas
  REW:
    - /srv/salt/REW/states
    - /srv/salt/REW/formulas
    - /srv/salt/base/states
    - /srv/salt/base/formulas

top_file_merging_strategy: same

env_order: ['base', 'REW']

default_top: REW
```

