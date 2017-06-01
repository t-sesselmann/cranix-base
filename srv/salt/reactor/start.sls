{% if data['id'] != 'admin-minion' %}
highstate_run:
  local.state.highstate:
    - tgt: '{{ data['id'] }}'
    - kwargs:
       queue: True
minion_started:
  local.cmd.script:
    - tgt: admin-minion
    - env:
      - BATCH: 'yes'
    - arg:
      - salt://tools/minion_started.sh
      - {{ data['id'] }}
    - kwargs:
       queue: True
{% endif %}
