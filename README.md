# Learning SaltStack

## Mastering SaltStack

Grains were originally designed to describe the static components of a minion, so that execution modules could detect how to behave appropriately.

A number of grains will automatically be discovered by Salt.

Grains are loaded when the minion process starts up, and then cached in memory.

Custom grains can be defined as well.
It is now more common to define static grains in a file called grains (`/etc/salt/grains` on Linux and some Unix platforms).
Using this file has some advantages:
* Grains are stored in a central, easy-to-find location
* Grains can be modified by the grains execution module

To add or modify a grain in the grains file, use the `grains.setval` function.

In most instances, pillars behave in much the same way as grains, with on important difference: they are defined on the master, typically in a centralized location.
Be default, this is the `/srv/pillar/` directory on Linux machines.
Because one location contains information for multiple minions, there must be a way to target that information to the minions.
Because of this, SLS files are used.

The `top.sls` file for pillars is identical in configuration and function to the `top.sls` file for states: first an environment is declared, then a target, then a list of SLS files that will be applied to that target.

Pillar SLS files are much simpler than state SLS files, because they serve only as a static data store.

Be default, state SLS files will be sent through the Jinja renderer, and then the yaml renderer.

There are two parts of the state system that are in effect.
**High data** refers generally to data as it is seen by the user.
**Low data** refers generally to data as it is ingested and used by Salt.

Each state represents a piece of high data.

When combined with other states, they form an SLS file.

When these files are tied together using includes and further glued together for use inside an environment using a `top.sls` file, they form a high state.

When the `state.highstate` function is executed, Salt will compile all relevant SLS files inside `top.sls` and any includes into a single definition, called a high state.
This can be viewed by using the `state.show_highstate` function.

## Commands

```bash
sudo salt-call --versions-report

sudo salt-call state.apply ctdna.sudo

sudo salt-call state.apply postgres

sudo salt-call state.apply devtools.ruby

sudo salt-call grains.item portal_frontend:postgres_password

sudo salt-call pillar.get sudoers

sudo salt-call pillar.get postgres

sudo salt-call pillar.get postgres:lookup:pkg
```

## References

[Salt Formulas](https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html)

[Salt Module Index](https://docs.saltstack.com/en/latest/salt-modindex.html)

