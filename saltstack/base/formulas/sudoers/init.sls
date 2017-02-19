{% set sudoers = salt['pillar.get']('sudoers', {}) %}

{%- for sudo in sudoers %}
{{ sudo }}_sudoers_file:
  file.managed:
    - name: /etc/sudoers.d/{{ sudo }}
    - source: salt://sudoers/files/sudoers.jinja
    - template: jinja
    - context:
      sudoers: {{ sudoers[sudo] }}
    - mode: 600
{% endfor %}
