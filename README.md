docker-oracle-xe-11g
============================

Oracle Express Edition 11g Release 2 on Ubuntu 14.04.1 LTS
This **Dockerfile** is a [trusted build](https://registry.hub.docker.com/u/rafaelri/oracle-xe-11g/) of [Docker Registry](https://registry.hub.docker.com/).

Slimmed down oracle-xe installation image that sets up database upon first start.

### Installation
```
docker pull rafaelri/oracle-xe-11g
```

Run exposing ports 8080 and 1521 and with /var/lib/oracle volume for storing data:
```
docker run -d -v /home/myuser/oracle:/var/lib/oracle -p 8081:8080 -p 49161:1521 rafaelri/oracle-xe-11g
```

Connect database with following setting:
```
hostname: localhost
port: 49161
sid: xe
username: system
password: $ORACLE_PASSWORD
```

Environment variable for replacing system password:
```
ORACLE_PASSWORD
```

Volumes for storing persistent data
```
/var/lib/oracle
```
