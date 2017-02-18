# Salt Formulas

A collection of Salt state and Salt pillar files that configure an application or system component.
Most formulas are made up of several Salt states spread across multiple Salt state files.

## Configuring formula using pillar

Salt Formulas are designed to work out of the box with no additional configuration.
However, many Formula support additional configuration and customization through Pillar.
Examples of available options can be found in a file named `pillar.example` in the root directory of each Formula repository.

## Gather external data

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
