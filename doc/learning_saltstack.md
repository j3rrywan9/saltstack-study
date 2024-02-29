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

Sometimes, we just want to match a list of minions for a given command, without any fancy matching.
This is easily possible using the list matcher.
The list matcher is invoked with the `-L` or `--list` command-line option and takes a comma-separated list of minions, as shown in the following code:
```shell
# sudo salt -L 'myminion' test.ping

# sudo salt -L 'myminion,yourminion,theirminion' test.ping
```

##### Grain and pillar matching

Salt can also perform minion matches data in grains or pillars.
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
What do we mean by this?
Execution module functions perform a task.
In general, when you call the same execution module multiple times in succession, it will run the same logic and commands under the hood each time.

State module functions, on the other hand, are designed to be idempotent.
An idempotent operation is one that only changes the result the first time it is applied.
Subsequent applications do not continue to apply changes.
Idempotent state module functions are designed to do only as much work as necessary to create a given state on the target minion.

In the case of our first state, we are running a state module function, `pkg.installed`.
Note the language change from execution modules.
`pkg.install` tells the minion to "install this package".
On the other hand, `pkg.installed` tells the minion to "ensure that this package is installed".
Under the hood, `pkg.install` is just running `apt-get install <package>` whereas `pkg.installed` actually calls out to the `pkg` execution module to find out whether the package is installed and only installs it if there's a need.
It does the minimum amount of work to bring your minion into the correct state, nothing more.

We list the functions for a given state module with sys.list_state_functions, as follows:
```bash
sudo salt-call sys.list_state_functions pkg
```

We can look up the documentation for a state module function using `sys.state_doc`, as follos:
```bash
sudo salt-call sys.state_doc pkg.removed
```

### The pieces of a state declaration

Just as with our remote execution commands, state declarations can be broken up into multiple pieces.
Here is our state from before:
```yaml
install_apache:
  pkg.installed:
    - name: apache2
```

Here is information about how the pieces line up and what each piece of the state declaration is called:
```yaml
<ID Declaration>:
  <State Module>.<Function>:
    - name: <name>
    - <Function Arg>
    - <Function Arg>
    - <Function Arg>
    - <Requisite Declaration>:
      - <Requisite Reference>
```
The preceding reference and more advanced examples can be found in the Salt documentation at http://docs.saltstack.com/en/latest/ref/states/highstate.html#large-example.

We haven't talked about requisites yet, so ignore that section for the moment.

We start with the ID of our state.
This is a string that must be unique across all of the states we are running at a given time.

Finally, we have our function arguments.
The first argument is always `name`, followed by any additional arguments required for the state.

### Expanding to encompass multiple pieces of state

### Dependencies using requisites

#### The `require` requisite

The most basic requisite is `require`, which allows you to specify that one state requires another state to be run successfully first.

#### The `watch` requisite

To keep our example simple, we'll just create a couple of Apache configuration files that give our server a status page.
To do this, we'll explore another state module that is very commonly used in Salt: the `file` module.
Specifically, we'll use `file.managed`, a very flexible function to manage files on our minions.
Here's what you get when you use the `file.managed` function:
```shell
sudo salt '*' sys.state_doc file.managed
```

For these states, we will need source files that the master will transfer to the minions as part of the state execution.
By default, the master will serve all files (state files and other files needed by the minions) out of the `/srv/salt/` directory that we've been using.

Here, we've introduced the `salt://` protocol in our `source` arguments.
These paths refer to files that the minion will request from the master.
Again, these files are stored by default in `/srv/salt`.

#### Other requisites

## Chapter 5. Expanding Our States with Jinja2 and Pillar

In the previous chapter, you learned about the state system and wrote your first state.

### Adding a new minion

### Jinja2

Jinja2 is a templating language for Python.
Templating provides a mechanism by which you can create content for files using code blocks to generate content dynamically.

There are two main types of Jinja2 syntaxes used in Salt.
The first is variable, which uses double curly braces (the spaces around `foo` are for readability and are note required), and which is shown in the following code:
```jinja
{{ foo }}
{{ foo.bar }}
{{ foo['bar'] }}
{{ get_data() }}
```

Jinja2 also has access to basic control statements.
Control statement blocks use a curly brace and percentage sign, which is depicted in the following code:
```jinja
{% %}
```

Instead, let's use the power of Jinja2 to make our state platform agnostic by dynamically choosing the correct content for our state files.

The first step is to change the package name and service name depending on the grains of the minion.
Luckily, Salt provides us with a grains dictionary in our Jinja2 templating.
Here are the changes we will be making to the first two states in our `/srv/salt/apache.sls` file:
```yaml
install_apache:
  pkg.installed:
{% if grains['os_family'] == 'Debian' %}
    - name: apache2
{% elif grains['os_family'] == 'RedHat' %}
    - name: httpd
{% endif %}
```

If you add a minus sign (-) to the start or end of a block (e.g. a For tag), a comment, or a variable expression, the whitespaces before or after that block will be removed.

### Defining secure minion-specific data in pillar

So far, we've only been defining the state of our infrastructure using state files.
However, there is no mechanism in the state files for per-minion access control.
Any file or data that you put in `/srv/salt` is immediately available for approved minions.

Thus, we need a system to give minion-sensitive data.
That system is Salt is called the `pillar` system.

Much like grains, which we have talked about before, the pillar system is just like a key-value store in Salt.
However, each minion gets its own set of pillar data, encrypted on a per-minion basis, which makes it suitable for sensitive data.

Our pillar files are stored in a separate directory from our state files.
By default, this directory is `/srv/pillar`.

Let's define some pillar data.
Inside `/srv/pillar`, we're going to create a couple of files.
The first file is going to be `/srv/pillar/core.sls`.
Note that pillar files also have the `.sls`file extension.
Here are the contents of our `core.sls` file:
```yaml
foo: bar
users:
  - larry
  - moe
  - curly
some_more_data: data
```
Note that these files, much like our state files, are defined using YAML.
However, the structure of these pillar files is much more freeform.
We're just defining data in the form of a dictionary.
The data itself is arbitrary and will look different for most infrastructures.

Now that we have our pillar data defined, we need to tell the master which minions will receive which data.
We do this using a special file `/srv/pillar/top.sls`, which we call a topfile, as follows:
```yaml
base:
  '*':
    - core
  'os_family: debian':
    - match: grain
    - ssh_key
```
There are a lot of new concepts in this file, despite it only being six lines long.
The first thing you might notice is that the topfile is also formatted using YAML.
It also follows a specific pattern.

The first level of indentation defines environments.
We're going to gloss over that for now since we're only using the default environment, named `base`, at the moment.

At the next level of indentation, we define a series of targeting strings.

The second targeting string (`'os_family: debian'`) is a grain target.
So, the first item in the list under that targeting string must define that we're using grain matching instead of globbing (`- match: grain`).
Therefore, all of our Debian distribution minions will get the pillar data defined in `ssh_key.sls` (`- ssh_key`).

Pillar data is automatically refreshed whenever you run any states.
However, it's sometimes useful to explicitly refresh the pillar data.
We use a remote execution function named `saltutil.refresh_pillar` for this purpose.
Here's how we explicitly refresh pillar data:
```shell
sudo salt '*' saltutil.refresh_pillar
```

If we've done everything correctly, we can query our minions for their pillar data using the `pillar.items` remote execution function:
```shell
sudo salt '*' pillar.items
```

#### Using pillar data in states

Let's finish up this chapter with an example that will show how can use our pillar data in our state files using Jinja2.

Create a new state file, `/srv/salt/users_and_ssh.sls`, as shown in the following code:
```yaml
{% for user in pillar['users'] %}
add_{{ user }}:
  user.present:
    - name: {{ user }}
{% endfor %}

{% if 'my_ssh_key' in pillar %}
manage_my_ssh_key:
  file.managed:
    - name: /root/.ssh/{{ pillar['my_ssh_key_name'] }}
    - contents_pillar: my_ssh_key
    - show_diff: False
{% endif %}
```
Note that we use a Jinja2 `for` loop to create a state for each user we need to add on our systems.
We also only create the ssh key file if the minion has the correct pillar data using a Jinja2 `if` statement.
Also note that we didn't actually use a source file for our `file.managed` call here;
instead, we told the minion to just insert the contents of a pillar key in that file (`my_ssh_key`).

## Chapter 6. The Highstate and Environments

### The highstate

Until now, we have only been running a single state file at a time using `stats.sls`.
However, this doesn't scale very well once we have many state files to manage our entire infrastructure.
We want to be able to split different pieces of our state into different files to make them more modular.
How can we accomplish this?

In the previous chapter, you learned how to target your pillar files to different minions using a `top.sls` file or topfile.
Topfiles can also be used in the state system to target different state files to different minions.

Let's create our topfile now, which is in `/srv/salt/top.sls`, as follows:
```yaml
base:
  '*minion':
    - apache
  'os_family:debian':
    - match: grain
    - users_and_ssh
```
Note that this file is structured almost exactly like the topfile that we used for our pillar data.
At the top level (first line), we define our environment.

Within the environment, we define a series of targeting strings.
Again, unless otherwise specified, the targeting string is using globbing to match minions.

Once we've saved the previous file, we're ready to run it.
The complete set of state files included in the topfile is referred to as the **highstate**.
Thus, it shouldn't surprise you that we use the remote execution function `state.highstate`, to run the highstate, as shown in the following example:
```shell
sudo salt '*' state.highstate
```

```shell
sudo salt-call state.show_top
```
Return the top data that the minion will use for a highstate.

#### Environments

Salt provides a concept of environments to further organize our states.
Until now, we've been using the default `base` environment.
However, we can configure as many environments as we need to organize our infrastructure and give each environment its own location in the filesystem.

We configure the locations of our environments on the master in the master configuration file, `/etc/salt/master`.
If you look for the `File Server Settings` section in the default master configuration file, you can see some example configurations.
We're going to keep ours very simple and just add a single new environment.
Somewhere in your master configuration file, add the following lines:
```yaml
file_roots:
  base:
    - /srv/salt
  webserver:
    - /srv/web
```

Note that we still only have one `top.sls` file even though we now have two environments.
This is because even though the topfile lives in the same place as the rest of our states, it transcends environments because it defines environments.

You can have a different topfile in each environment; however, keep in mind that when you run a highstate, the topfiles from all environments will be combined into a single set of top data.
So, it is recommended that you either have a single topfile in the `base` environment or have a topfile in each environment that defines only that environment.

##### Environments in pillar

Environments work almost identically in the pillar system.
