{% if grains['os_family']=="Debian" %}

include:
  - apache

{% for module in salt['pillar.get']('apache:modules:enabled', []) %}
a2enmod {{ module }}:
  cmd.run:
    - unless: ls /etc/apache2/mods-enabled/{{ module }}.load
    - order: 225
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
    - require_in:
      - module: apache-restart
      - module: apache-reload
      - service: apache
{% endfor %}

{% for module in salt['pillar.get']('apache:modules:disabled', []) %}
a2dismod -f {{ module }}:
  cmd.run:
    - onlyif: ls /etc/apache2/mods-enabled/{{ module }}.load
    - order: 225
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
    - require_in:
      - module: apache-restart
      - module: apache-reload
      - service: apache
{% endfor %}

{% elif grains['os_family']=="RedHat" %}

include:
  - apache
 
{% for module in salt['pillar.get']('apache:modules:enabled', []) %}
find /etc/httpd/ -name '*.conf' -type f -exec sed -i -e 's/\(^#\)\(\s*LoadModule.{{ module }}_module\)/\2/g' {} \;:
  cmd.run:
    - unless: httpd -M 2> /dev/null | grep "[[:space:]]{{ module }}_module"
    - order: 225
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
    - require_in:
      - module: apache-restart
      - module: apache-reload
      - service: apache
{% endfor %}

{% for module in salt['pillar.get']('apache:modules:disabled', []) %}
find /etc/httpd/ -name '*.conf' -type f -exec sed -i -e 's/\(^\s*LoadModule.{{ module }}_module\)/#\1/g' {} \;:
  cmd.run:
    - onlyif: httpd -M 2> /dev/null | grep "[[:space:]]{{ module }}_module"
    - order: 225
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
    - require_in:
      - module: apache-restart
      - module: apache-reload
      - service: apache
{% endfor %}

{% elif salt['grains.get']('os_family') == 'Suse' or salt['grains.get']('os') == 'SUSE' %}

include:
  - apache
 
{% for module in salt['pillar.get']('apache:modules:enabled', []) %}
a2enmod {{ module }}:
  cmd.run:
    - unless: egrep "^APACHE_MODULES=" /etc/sysconfig/apache2 | grep {{ module }}
    - order: 225
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
    - require_in:
      - module: apache-restart
      - module: apache-reload
      - service: apache
{% endfor %}

{% for module in salt['pillar.get']('apache:modules:disabled', []) %}
a2dismod -f {{ module }}:
  cmd.run:
    - onlyif: egrep "^APACHE_MODULES=" /etc/sysconfig/apache2 | grep {{ module }}
    - order: 225
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
    - require_in:
      - module: apache-restart
      - module: apache-reload
      - service: apache
{% endfor %}

{% endif %}
