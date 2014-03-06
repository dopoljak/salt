tomcat7:
  pkg.installed 
 
tomcat7-admin:
  pkg.installed


zoman:
  user:
    - present


#tomcat_config:
#  file.append:
#    - name: /etc/default/tomcat7
#    - text: CATALINA_PID=/var/run/tomcat7.pid 

tomcat_server_config:
  file.managed:
    - name: /usr/share/tomcat7/conf/server.xml
    - source: salt://conf/server.xml
    - user: root
    - group: tomcat7
    - mode: 640
    - template: jinja

tomcat_users_config:
  file.managed:
    - name: /etc/tomcat7/tomcat-users.xml
    - source: salt://conf/tomcat-users.xml
    - user: root
    - group: tomcat7
    - mode: 640
    - template: jinja
    - defaults:
      user: {{ salt['pillar.get']('tomcat-manager:user') }}
      passwd: {{ salt['pillar.get']('tomcat-manager:passwd') }}

tomcat-service:
  service:
    - running
    - name: tomcat7
    - enable: True
    - watch:
        - pkg: tomcat7
        - pkg: tomcat7-admin
        - file: tomcat_users_config
        - file: tomcat_server_config 
#        - file: tomcat_config
wait-for-tomcatmanager:
  tomcat:
    - wait
    - timeout: 700
    - require:
      - service: tomcat-service

locker-service:
  tomcat:
    - war_deployed
    - name: /locker-service
    - war: salt://war-files/locker-service-1.0.0.war
    - require:
      - tomcat: wait-for-tomcatmanager
