# SaltStack

## Introduction

The two main pieces of Salt are the **Salt Master** and the **Salt Minion**.
The master is the central hub.
All minions connect to the master to receive instructions.
From the master, you can run commands and apply configurations across hundreds or thousands of minions in seconds.

The minions, as mentioned before, connects to the master and treats the master as the source of all truth.

Salt is built on two major concepts: **remote execution** and **configuration management**.
In the remote execution system, Salt leverages Python to accomplish complex tasks with single-function calls.
The configuration management system in Salt, **States**, builds upon the remote execution foundation to create repeatable, enforceable configuration for the minions.

## Installing Salt

## Configuring Salt

### Firewall configuration

Since minions connect to masters, the only firewall configuration that must be done is on the master.
By default, ports `4505` and `4506` must be able to accept incoming connections on the master.

### Salt minion configuration

Out of the box, the Salt minion is configured to connect to a master at the location `salt`.

The minion and master configuration files are located in the `/etc/salt/` directory.

### Starting the Salt master and Salt minion

### A game of ping pong

```bash
sudo salt 'myminion' sys.list_functions test
```

## Masterless Salt

Salt is also designed so that a minion can run without a master.

The command used to run commands on the minion is `salt-call`, and it can take any of the same execution module functions that we used with the `salt` command.

The `salt-call` command is used to run module functions locally on a minion instead of executing them from the master.

In order for `salt-call` to operate properly without a master, we need to tell it that there's no master.
We do this with the `--local` flag, as follows:
```bash
sudo salt-call --local test.ping
```

## The structure of a remote execution command

The basic Salt remote execution command is made up of five distinct pieces.
```bash
sudo salt --help
Usage: salt [options] '<target>' <function> [arguments]
```

Let's inspect a command that uses all of these pieces:
```bash
sudo salt --verbose '*' test.sleep 2
```

Here are the pieces of a Salt command, including the relevant pieces of the last command that we ran:
* The Salt command: `salt`
* Command-line options: `--verbose`
* Targeting string: `'*'`
* The Salt module function: `test.sleep`
* Arguments to the remote execution function: `2`

## Command-line options

In Salt, there are a few main categories of command-line options.
* Targeting options
* Output options
* Miscellaneous options

The `cmd` execution module is designed to provide ways to execute any commands or programs on the minions.

## Targeting strings

### List matching

### Grain and pillar matching

Salt can also match using data in grains or pillars.
**Grains** and **pillars** are two concepts specific to Salt.
Both are key-value data stores where we can store data about, or for use by, our minions.
We don't talk much about pillars until we get to the later chapter of states.
However, know that both grains and pillars contain arbitrary data stored in the key-value format.

#### Grains

Grains represent static data describing a minion.
```bash
sudo salt-call grains.item os_family

sudo salt-call grains.item os

sudo salt-call grains.item osfinger
```

#### Pillars

Pillar data is similar to grains except that it can be defined more dynamically and is a secure store for data.

## Remote execution modules and functions

The final piece of our remote execution command is the actual function that we want to run and arguments to this function (if there are any).
These functions are separated into logical groupings named execution modules.
All the remote execution commands in the format `<module>.<function>`.

We can obtain a list of all available execution modules using the `sys` module:
```bash
sudo salt '*' sys.list_modules
```

### Adding users

### Installing packages

```bash
sudo salt-call sys.doc pkg.install

sudo salt-call pkg.list_pkg

sudo salt-call pkg.remove
```

### Managing services

```bash
sudo salt-call service.status

sudo salt-call service.start

sudo salt-call service.stop
```

### Monitoring minion states

### Running arbitrary commands

## Execution Modules - Write Your Own Solution

## Define the State of Your Infrastructure

### Our first state

All Salt-specific files that aren't Python files end in the extension `.sls`.
By default, states are located in the `/srv/salt` directory.

State files are formatted using **YAML**.

To apply states to our minions, we actually use the `state` execution module.

This highlights a major change between execution modules and state modules.

Execution modules are iterative, while state modules are declarative.
Execution module functions perform a task.
Generally, when you call the same execution module multiple times in succession, it will run the same logic and commands under the hood each time.

State module functions, on the other hand, are designed to be idempotent.
Idempotent state modules functions are designed to do only as much as necessary to create a given state on the target minion.

In the case of our first state, we are running a state module function, `pkg.installed`.
On the other hand, `pkg.installed` tells the minion to "ensure that this package is installed".

We list the functions for a given state module with sys.list_state_functions, as follows:
```bash
sudo salt-call sys.list_state_functions pkg
```

We can look up the documentation for a state module function using `sys.state_doc`, as follos:
```bash
sudo salt-call sys.state_doc pkg.removed
```

### The pieces of a state declaration

State declarations can be broken up into multiple pieces.

We start with the ID of our state.
This is a string that must be unique across all of the states we are running at a given time.

### Expanding to encompass multiple pieces of state

### Dependencies using requisites

We'll use `file.managed`, a very flexible function to manage files on our minions.
```bash
sudo salt-call sys.state_doc file.managed
```

Here, we've introduced the `salt://` protocol in our `source` arguments.
These paths refer to files that the minion will request from the master.
Again, these files are stored by default in `/srv/salt`.

## Expanding Our States with Jinja2 and Pillar

### Jinja2

Jinja2 is a templating language for Python.
Templating provides a mechanism by which you can create content for files using code blocks to generate content dynamically.

There are two main types of Jinja2 syntaxes used in Salt.
The first is variable, which uses double curly braces.

Jinja2 also has access to basic control statements.
Control statement blocks use a curly brace and percentage sign, which is depicted in the following code:
```jinja
{% %}
```

The first step is to change the package name and service name depending on the grains of the minion.
Luckily, Salt provides us with a grains dictionary in our Jinja2 templating.

If you add a minus sign (-) to the start or end of a block (e.g. a For tag), a comment, or a variable expression, the whitespaces before or after that block will be removed.

### Defining secure minion-specific data in pillar

There is no mechanism in the state files for per-minion access control.
Any file or data that you put in `/srv/salt` is immediately available for approved minions.

Thus, we need a system to give minion-sensitive data.
That system is Salt is called the `pillar` system.

Much like grains, which we have talked about before, the pillar system is just like a key-value store in Salt.
However, each minion gets its own set of pillar data, encrypted on a per-minion basis, which makes it suitable for sensitive data.

Our pillar files are stored in a separate directory from our state files.
By default, this directory is `/srv/pillar`.
Note that pillar files also have the `.sls`file extension.
Note that these files are defined using YAML.
However, the structure of these pillar files is much more freedom.
We're just defining data in the form of a dictionary.

Now that we have our pillar data defined, we need to tell the master which minions will receive which data.
We do this using a special file `/srv/pillar/top.sls`, which we call a Top file, as follows:
```yaml
base:
  '*':
    - core
  'os_family: debian':
    - match: grain
    - ssh_key
```
The first thing you might notice is that the Top file is also formatted using YAML.

The first level of indentation defines environments.

At the next level of indentation, we define a series of targeting strings.

The second targeting string ('`os_family: debian`') is a grain target.
So, the first item in the list under that targeting string must define that we're using grain matching instead of globbing.

Pillar data is automatically refreshed whenever you run any states.
However, it's sometimes useful to explicitly refresh the pillar data.
We use a remote execution function named `saltutil.refresh_pillar` for this purpose.

If we've done everything correctly, we can query our minions for their pillar data using the `pillar.items` remote execution function:
```bash
sudo salt-call pillar.items
```

#### Using pillar data in states

```yaml
{% for user in pillar['users'] %}
add_{{ user }}:
  user.present:
    - name: {{ user }}
{% endfor %}
```
Note that we use a Jinja2 `for` loop to create a state for each user we need to add on our systems.

## The Highstate and Environments

### The highstate

The complete set of state files included in the Top file is referred to as the **highstate**.
Thus, it shouldn't surprise you that we use the remote execution function `state.highstate` to run the highstate, as shown in the following example:
```bash
sudo salt '*' state.highstate

sudo salt-call state.show_highstate
```

```bash
sudo salt-call state.show_top
```
Return the top data that the minion will use for a highstate.

### Environments

Salt provides a concept of environments to further organize our states.
Until now, we've been using the default `base` environment.
However, we can configure as many environments as we need to organize our infrastructure and give each environment its own directory/directories.

Note that we still only have one `top.sls` file even though we now have two environments.
This is because even though the Top file lives in the same place as the rest of our states, it transcends environments because it defines environments.

You can have a different Top file in each environment; however, keep in mind that when you run a highstate, the Top files from all environments will be combined into a single set of top data.
So it is recommended that you either have a single Top file in the `base` environment or have a Top file in each environment that defines *only* that environment.

### Formula

A collection of Salt state and Salt pillar files that configure an application or system component.
Most formulas are made up of several Salt states spread across multiple Salt state files.

Salt Formulas are designed to work out of the box with no additional configuration.
However, many Formula support additional configuration and customization through Pillar.
Examples of available options can be found in a file named `pillar.example` in the root directory of each Formula repository.

One of the most common uses for Jinja is to pull external data into the state file.
External data can come from anywhere like API calls or database queries, but it most commonly comes from flat files on the file system or Pillar data from the Salt Master. For example:
```jinja
{% import_yaml "postgres/defaults.yaml" as defaults %}

{# or #}

{% set some_data = salt.pillar.get('some_data', {'sane default': True}) %}
```
This is usually best done with a variable assignment in order to separate the data from the state that will make use of the data.

Jinja is extremely powerful for programmatically generating Salt states.

Separate Jinja control flow statements from the states as much as possible to create readable states.
Limit Jinja within states to simple variable lookups.

A strong convention in Salt Formulas is to place platform-specific data, such as package names and file system paths, into a file named `map.jinja` that is placed alongside the state files.

The `grains.filter_by` function performs a lookup on that table using the `os_family` grain (by default).

The result is that the variable is assigned to a *subset* of the lookup table the current platform.
This allows state to reference, for example, the name of a package without worrying about the underlying OS.
The syntax for referencing a value is a normal dictionary lookup in Jinja, such as `{{ mysql['service'] }}` or the shorthand `{{ mysql.service }}`.

Values defined in the map file can be fetched for the current platform in any state file using the following syntax:
```yaml
{% from "mysql/map.jinja" import mysql with context %}

mysql-server:
  pkg.installed:
    - name: {{ mysql.server }}
  service.running:
    - name: {{ mysql.service }}
```

It is considered a best practice to make formulas expect **all** formula-related parameters to be placed under second-level `lookup` key, within a main namespace designated for holding data for particular service/software/etc, managed by the formula.

Allow static values within lookup tables to be overridden.
This is a simple pattern which once again increases flexibility and reusability for state files.

The `merge` argument in `filter_by` specifies the location of a dictionary in Pillar that can be used to override values returned from the lookup table.
If the value exists in Pillar it will take precedence.

The `filter_by` function performs a simple dictionary lookup but also allows for fetching data from Pillar and overriding data stored in the lookup table.

A smoke test for invalid Jinja, invalid YAML, or an invalid Salt state structure can be performed by with the `state.show_sls` function:
```bash
sudo salt-call state.show_sls postgres
```

### State

A reusable declaration that configures a specific part of a system.
Each Salt state is defined using a state declaration.

### State Declaration

A top level section of a state file that lists the state function calls and arguments that make up a state.
Each state declaration starts with a unique ID.

### State file

A file with an SLS extension that contains one or more state declarations.

Salt states are generic by design, and describe only *how* a configuration should be achieved.

Top file describes *where* states should be applied.

States and the Top file work together to create the core of SaltStack's configuration management capability.

The Top file is used to apply multiple state files to your Salt minions during a highstate.
The states that are applied to each system are determined by the targets that are specified in the Top file.

### Grains

Grains are static information SaltStack collects about the underlying managed system.
SaltStack collects grains for the operating system, domain name, IP address, kernel, OS type, memory, and many other system properties.

You can add your own grains to a Salt minion by placing them in the **/etc/salt/grains** file on the Salt master, or in the Salt minion configuration file under the **grains** section.

You can use the **grains.ls** command to list all of the grains on a Salt minion.

### Pillar

Salt pillar is a system that lets you define secure data that are 'assigned' to one or more minions using targets.

Salt pillar uses a Top file to match Salt pillar data to Salt minions.

#### Salt Pillar in Salt States

Salt pillar keys are available in a dictionary in Salt states.

#### Salt Pillar on the Command-line

For testing or for ad hoc management, you can pass Salt pillar values directly on the command line.
These values override any value that might be set in a Salt pillar file.

### Includes

To keep your Salt states modular and reusable, each configuration task should be described only once in your Salt state tree.
If you need to use the same configuration task in multiple places, you can use include.

Note that you don't need to include the .sls extension.

If the Salt state file that you want to include is in a subdirectory in your Salt state tree, use a dot (.) as a directory separator:
```yaml
include:
  - dir.sls1
```

Included Salt states are inserted at the top of the current file and are processed first.

If a Salt state always needs some other state, then using an include is a better choice.
If only some systems should receive both Salt states, including both states in the Top file gives you the flexibility to choose which systems receive each.

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

