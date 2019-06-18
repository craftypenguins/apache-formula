{% from "apache/map.jinja" import apache with context %}


{%- macro letsencrypt_config(name) %}
{{ name }}:
  file.managed:
    - source:
      - salt://apache/files/{{ salt['grains.get']('os_family') }}/conf-available/letsencrypt.conf.jinja
      - salt://apache/files/letsencrypt.conf.jinja
    - mode: 644
    - template: jinja
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
    - require_in:
      - module: apache-restart
      - module: apache-reload
      - service: apache
{%- endmacro %}

include:
  - apache

{% if grains['os_family']=="Debian" %}

{{ letsencrypt_config("/etc/apache2/conf-available/letsencrypt.conf") }}


a2endisconf letsencrypt:
  cmd.run:
{% if salt['pillar.get']('apache:letsencrypt') is defined  %}
    - name: a2enconf letsencrypt
    - unless: test -L /etc/apache2/conf-enabled/letsencrypt.conf
{% else %}
    - name: a2disconf letsencrypt
    - onlyif: test -L /etc/apache2/conf-enabled/letsencrypt.conf
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

{% elif grains['os_family']=="FreeBSD" %}
{{ letsencrypt_config(apache.confdir+'/letsencrypt.conf') }}

{% endif %}


