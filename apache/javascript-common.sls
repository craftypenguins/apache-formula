{% from "apache/map.jinja" import apache with context %}

include:
  - apache

{%- macro javascript_config(name) %}
{{ name }}:
  file.managed:
    - mode: 644
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
    - require_in:
      - module: apache-restart
      - module: apache-reload
      - service: apache
{%- endmacro %}


{% if grains['os_family']=="Debian" %}

{{ javascript_config('/etc/apache2/conf-available/javascript-common.conf') }}
    - onlyif: test -f '/etc/apache2/conf-available/javascript-common.conf'

a2endisconf javascript-common:
  cmd.run:
{% if salt['pillar.get']('apache:javascript-common') is defined  %}
    - name: a2enconf javascript-common
    - unless: test -L /etc/apache2/conf-enabled/javascript-common.conf
{% else %}
    - name: a2disconf javascript-common
    - onlyif: test -L /etc/apache2/conf-enabled/javascript-common.conf
{% endif %}
    - order: 226
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
    - require_in:
      - module: apache-restart
      - moduel: apache-reload
      - service: apache
{% endif %}

