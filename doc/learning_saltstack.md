# Learning SaltStack - Second Edition

## Chapter 1. Diving In - Our First Salt Commands

### Introducing Salt

Before installing Salt, we should learn the basic architecture of Salt deployment.

The two main pieces of Salt are the **Salt Master** and the **Salt Minion**.
The master is the central hub.
All minions connect to the master to receive instructions.
From the master, you can run commands and apply configurations across hundreds or thousands of minions in seconds.

The minions, as mentioned before, connects to the master and treats the master as the source of all truth.
Although minions can exist without a master, the full power of Salt is realized when you have minions and the master working together.

Salt is built on two major concepts: **remote execution** and **configuration management**.
In the remote execution system, Salt leverages Python to accomplish complex tasks with single-function calls.
The configuration management system in Salt, **States**, builds upon the remote execution foundation to create repeatable, enforceable configuration for the minions.

With this bird's-eye view in mind, let's get Salt installed so that we can start learning how to use it to make managing our infrastructure easier!

### Installing Salt

### Configuring Salt

Now that we have the master and the minion installed on our machine, we must do a couple of pieces of configuration in order to allow them to talk to each other.
From here on out, we're back to using a single Ubuntu 14.04 machine with both master and minion installed on the machine.

#### Firewall configuration

Since minions connect to masters, the only firewall configuration that must be done is on the master.
By default, ports `4505` and `4506` must be able to accept incoming connections on the master.

#### Salt minion configuration

Out of the box, the Salt minion is configured to connect to a master at the location `salt`.
The reason for this default is that, if DNS is configured correctly such that salt resolves to the master's IP address, no further configuration is needed.
The minion will connect successfully to the master.

The minion and master configuration files are located in the `/etc/salt/` directory.

#### Starting the Salt master and Salt minion

### A game of ping pong

The `test` module actually has a few other useful functions.
To find out about them, we're actually going to use another module, `sys`, as follows:
```bash
sudo salt 'myminion' sys.list_functions test
```

## Masterless Salt

However, Salt is also designed so that a minion can run without a master.

To start, we'll leave our master running.
The command used to run commands on the minion is `salt-call`, and it can take any of the same execution module functions that we used with the `salt` command, as follows:
```bash
sudo salt-call test.ping
```

The example shown previously will take a fairly long time to terminate.
Basically, `salt-call` is trying to establish a connection with the master just in case it needs to copy files from the master or other similar operations.

In order for `salt-call` to operate properly without a master, we need to tell it that there's no master.
We do this with the `--local` flag, as follows:
```bash
sudo salt-call --local test.ping
```
Success!
You can now operate a Salt minion without a master!

## Chapter 2. Controlling Your Minions with Remote Execution

### The structure of a remote execution command

The basic Salt remote execution command is made up of five distinct pieces.
We can easily see them if we look at the usage text for the `salt` command, which is as follows:
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

#### Command-line options

In Salt, there are a few main categories of command-line options.
* Targeting options
* Output options
* Miscellaneous options

The `cmd` execution module is designed to provide ways to execute any commands or programs on the minions.
You will see that `cmd.run_all` returns all the pieces of the return of that command as a dictionary, including `pid` of the command, the return code, the contents of `stdout`, and the contents of `stderr`.
This particular command is a great example of how different types of data are displayed in the various outputters.

#### Targeting strings

##### Glob matching

##### List matching

##### Grain and pillar matching

Salt can also match using data in grains or pillars.
**Grains** and **pillars** are two concepts specific to Salt.
Both are key-value data stores where we can store data about, or for use by, our minions.
We don't talk much about pillars until we get to the later chapter of states.
However, know that both grains and pillars contain arbitrary data stored in the key-value format.

###### Using grains

Grains represent static data describing a minion.
For example, minions have a grain named `os_family`, which describes the family of operating systems to which a minion belongs.
For example, Ubuntu machines are a member of the Debian `os_family`.
Here's how grains can be retrieved on the command line:
```bash
sudo salt '*' grains.item os_family
```

###### Using pillars

Pillar data is similar to grains, except that it can be defined more dynamically and is a secure store for data.

##### Compound matching

#### Remote execution modules and functions

The final piece of our remote execution command is the actual function that we want to run and arguments to this function (if there are any).
These functions are separated into logical groupings named execution modules.
All the remote execution commands in the format `<module>.<function>`.

We can obtain a list of all available execution modules using the `sys` module:
```bash
sudo salt '*' sys.list_modules
```

##### Adding users

##### Installing packages

```bash
sudo salt-call sys.doc pkg.install

sudo salt-call pkg.list_pkg

sudo salt-call pkg.remove
```

##### Managing services

```bash
sudo salt-call service.status

sudo salt-call service.start

sudo salt-call service.stop
```

##### Monitoring minion states

##### Running arbitrary commands

## Chapter 3. Execution Modules - Write Your Own Solution

In this chapter, we will expand on Salt's remote execution system by diving into the code.
You will learn the following things:
* What an execution module is made up of (and inspect some of the execution modules that ship with Salt)
* How to write our own execution module functions
* The extra tools that are easily available to us in the context of execution modules
* How to sync our execution modules to our minions

### Exploring the source

## Chapter 4. Define the State of Your Infrastructure

In the previous chapter, we finished our deep dive of the remote execution system inside Salt.
Remote execution is the foundation upon which all of the rest of Salt rests.
In this chapter, you will learn about one of the most important systems: "the state system."
You will learn the following:
* How states are structured and how to write our first state
* About the various pieces of the state declaration
* How to expand our state declarations to encompass multiple pieces of a state
* About ordering states with requisites

### Our first state

Without further ado, let's write our first state.
All Salt-specific files that aren't Python files end in the extension `.sls`.
By default, the states are located in the `/srv/salt/` directory.
We created this directory in the previous chapter, but if you didn't follow along there, make this directory now, as follows:
```bash
mkdir -p /srv/salt
cd /srv/salt
```

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

### Environments

Salt provides a concept of environments to further organize our states.
Until now, we've been using the default `base` environment.
However, we can configure as many environments as we need to organize our infrastructure and give each environment its own directory/directories.

Note that we still only have one `top.sls` file even though we now have two environments.
This is because even though the Top file lives in the same place as the rest of our states, it transcends environments because it defines environments.

You can have a different Top file in each environment; however, keep in mind that when you run a highstate, the Top files from all environments will be combined into a single set of top data.
So it is recommended that you either have a single Top file in the `base` environment or have a Top file in each environment that defines *only* that environment.

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

## Chapter 5. Expanding Our States with Jinja2 and Pillar

### Adding a new minion

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
