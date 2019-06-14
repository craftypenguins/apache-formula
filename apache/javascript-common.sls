{% from "apache/map.jinja" import apache with context %}

include:
  - apache


{% if grains['os_family']=="Debian" %}

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

