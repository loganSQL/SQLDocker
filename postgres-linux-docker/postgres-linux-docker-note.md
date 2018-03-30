# Postgres Linux Docker Note

## Build the container

    docker pull postgres
    docker run -p 5432:5432 --name test-postgres -e POSTGRES_PASSWORD=Xmas2017 -d postgres

## Goto Container
    docker exec -it test-postgres bash
    root@9e025258284b:/# su postgres
    $ psql
    ...
    \q
    exit

## check the configuration for remote login
    root@9e025258284b:/etc/postgresql# find / -name "postgresql.conf"
    /usr/lib/tmpfiles.d/postgresql.conf
    /var/lib/postgresql/data/postgresql.conf
    ...
    
    root@9e025258284b:/etc/postgresql# cd
    root@9e025258284b:~# cat /var/lib/postgresql/data/postgresql.conf|grep listen_addresses
    listen_addresses = '*'
    ...
    root@9e025258284b:~# find / -name "pg_hba.conf"
    /var/lib/postgresql/data/pg_hba.conf
    ...
    root@9e025258284b:~# cat /var/lib/postgresql/data/pg_hba.conf
    # PostgreSQL Client Authentication Configuration File
    ...
    TYPE  DATABASE        USER            ADDRESS                 METHOD
    
    # "local" is for Unix domain socket connections only
    local   all             all                                     trust
    # IPv4 local connections:
    host    all             all             127.0.0.1/32            trust
    # IPv6 local connections:
    host    all             all             ::1/128                 trust
    # Allow replication connections from localhost, by a user with the
    # replication privilege.
    local   replication     all                                     trust
    host    replication     all             127.0.0.1/32            trust
    host    replication     all             ::1/128                 trust
    
    host all all all md5

## create user and database for remote login
    root@9e025258284b:~# su postgres
    #-- 1. create a super user logan
    $ createuser -P -s -e logan
    Enter password for new role:
    Enter it again:
    SELECT pg_catalog.set_config('search_path', '', false)
    CREATE ROLE logan PASSWORD 'md55584469c41de154756016406355ac4a0' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;
    
    # -- 2. create a database logan (wsl)
    $ psql -U logan -h MYHOST postgres
    CREATE DATABASE logan;
    
    # -- 3. create another user testuser
    \c logan;
    create user testuser with password 'testuser';
    GRANT ALL PRIVILEGES ON DATABASE logan to testuser;
    desc user
    \du
    select * from pg_shadow;
    select * from pg_user;
    # -- 5 List of databases
    \l
    
    # -- USER / PERMISSION ADMIN
    SELECT version();

