{% from "collectd/map.jinja" import collectd_settings with context %}

include:
  - collectd

# mah...
# https://github.com/saltstack/salt/issues/40048
python2_pip_package:
  pkg:
    - installed
    - name: python2-pip

python3_pip_package:
  pkg:
    - installed
    - name: python3-pip

collectd-gluster-module:
  pip.installed:
    - require:
      - pkg: python3_pip_package
        - bin_env: '/usr/bin/pip3'
    - name: collectd
    - name: psutil == 5.4.0
    - require_in:
      - service: collectd-service
    - watch_in:
      - service: collectd-service
  cmd.run:
    - name: |
        rm -rf /tmp/foo
        mkdir /tmp/foo
        cd /tmp/foo
        git clone https://github.com/gluster/gluster-collectd.git
        mkdir {{ collectd_settings.moduledirconfig }}/gluster-collectd
        cp gluster-collectd/src/*.py  {{ collectd_settings.moduledirconfig }}/gluster-collectd/
        cp gluster-collectd/types/types.db.gluster /usr/share/collectd/types.db.gluster
  
  
{{ collectd_settings.plugindirconfig }}/gluster.conf:
  file.managed:
    - source: salt://collectd/files/gluster.conf
    - user: {{ collectd_settings.user }}
    - group: {{ collectd_settings.group }}
    - mode: 644
    - template: jinja
    - watch_in:
      - service: collectd-service

