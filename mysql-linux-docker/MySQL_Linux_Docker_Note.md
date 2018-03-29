# MySQL Linux Docker Note
## Docker Image / Container Build
    # Pull image
    docker pull mysql
    #
    # Mapping container port to host port
    # disable virus checking like endpoint encryption software if needed
    # Run container
    docker run -d -p 3306:3306 --name=test-mysql --env="MYSQL_ROOT_PASSWORD=Xmas2017" mysql
    #
    docker logs test-mysql
    #
    docker inspect test-mysql | findstr "IPAddress"
    #
    docker stop test-mysql
    #
    docker start test-mysql

## Connect and Test
### 1. Connect and Test inside Container
    #
    docker exec test-mysql cat /etc/hosts
    # 
    docker exec -it test-mysql bash
    # inside container bash shell
    which mysql
    mysql -uroot -pXmas2017
    cat /etc/mysql/mysql.conf.d/mysqld.cnf

    # add the following line to allow listen to all ips
    # for remote connection from another host
    echo 'bind-address   = 0.0.0.0' >> /etc/mysql/mysql.conf.d/mysqld.cnf

### 2. Connect in wsl
    # install mysql-client if needed
    sudo apt-get install mysql-client
    # connect using $(hostname) on linux host
    mysql -uroot -h$(hostname) -p
    #
```
mysql> select version();

mysql> SHOW GLOBAL VARIABLES LIKE 'PORT';

mysql> SHOW GLOBAL VARIABLES LIKE 'SOCKET';

mysql> SHOW GLOBAL VARIABLES LIKE 'hostname';
mysql> show variables like 'skip%';

mysql> create database logandb;
#-- testuser @ localhost
mysql> create user 'testuser'@'localhost' identified by 'testuser';
#-- testuser from all the hosts
mysql> create user 'testuser'@'%' identified by 'testuser';
#-- all permission on all database
mysql> grant all on *.* to 'testuser'@'localhost';
mysql> grant all on *.* to 'testuser'@'%';
#--grant all on logandb.* to 'testuser'@'%';
mysql> select host,user from mysql.user;
+-----------+---------------+
| host      | user          |
+-----------+---------------+
| %         | root          |
| %         | testuser      |
| localhost | mysql.session |
| localhost | mysql.sys     |
| localhost | root          |
| localhost | testuser      |
+-----------+---------------+

#---- from another host WSL
mysql -utestuser -h REMOTE_HOST -p
```

## Link to container test-mysql as mysqldb
    docker stop test-mysql
    docker ps
    docker rm test-apache-php
    # rerun the container with a link to sql
    docker run -d -p 80:80 --name test-apache-php -v C:\logan\test\testdata:/var/www/html --link test-mysql:mysqldb logansql/linux-apache-php-ext
    
    # test PHP HTTP
    dir C:\logan\test\testdata
```
Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        3/22/2018   8:05 PM             92 dbconfig.php
-a----        3/22/2018   2:28 PM            120 hello.php
-a----        3/23/2018  10:38 AM           4272 PDOMySQLTest1.php
-a----        3/22/2018   2:35 PM            103 phpinfo.php
-a----        3/22/2018   8:03 PM            295 phpmysqlconnect.php
-a----        3/23/2018  12:56 PM           3030 testDB_backup.sql
-a----        3/22/2018   7:52 PM            524 testmysql1.php
```
[http://localhost/hello.php](http://localhost/hello.php)

[http://localhost/phpinfo.php](http://localhost/phpinfo.php)
    
    
# test mysql inside Container: test-apache-php

    docker exec -it test-apache-php bash
```
mysql -utestuser -h mysqldb -ptestuser
mysql>
mysql> use logandb
Database changed
mysql> CREATE TABLE IF NOT EXISTS products (
    ->          productID    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    ->          productCode  CHAR(3)       NOT NULL DEFAULT '',
    ->          name         VARCHAR(30)   NOT NULL DEFAULT '',
    ->          quantity     INT UNSIGNED  NOT NULL DEFAULT 0,
    ->          price        DECIMAL(7,2)  NOT NULL DEFAULT 99999.99,
    ->          PRIMARY KEY  (productID)
    ->        );
Query OK, 0 rows affected (0.06 sec)

mysql> INSERT INTO products VALUES (1001, 'PEN', 'Pen Red', 5000, 1.23);
Query OK, 1 row affected (0.04 sec)
mysql> select database() as db, user() as user;
+--------+---------------------+
| db     | user                |
+--------+---------------------+
| testDB | testuser@172.17.0.3 |
+--------+---------------------+
1 row in set (0.00 sec)

mysql> status
--------------
mysql  Ver 14.14 Distrib 5.5.59, for debian-linux-gnu (x86_64) using readline 6.3

Connection id:          2
Current database:       testDB
Current user:           testuser@172.17.0.3
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         5.7.21 MySQL Community Server (GPL)
Protocol version:       10
Connection:             mysqldb via TCP/IP
Server characterset:    latin1
Db     characterset:    latin1
Client characterset:    latin1
Conn.  characterset:    latin1
TCP port:               3306
Uptime:                 2 hours 30 min 19 sec

Threads: 1  Questions: 52  Slow queries: 0  Opens: 110  Flush tables: 1  Open tables: 103  Queries per second avg: 0.005
```

### test from PHP: dbconfig.php
```
<?php
$username="testuser";
$password="testuser";
$dbname="logandb";
$host="mysqldb"
?>
```

[http://localhost/PDOMySQLTest1.php](http://localhost/PDOMySQLTest1.php) [sourcecode](<https://github.com/loganSQL/SQLDocker/blob/master/mysql-linux-docker/PDOMySQLTest1.php>)

Verify the mysql
```
mysql> use testDB;
Database changed
mysql> show tables;
+------------------+
| Tables_in_testDB |
+------------------+
| MyGuests         |
+------------------+
1 row in set (0.00 sec)

mysql> select * from MyGuests;
+----+-----------+----------+-------------------+---------------------+
| id | firstname | lastname | email             | reg_date            |
+----+-----------+----------+-------------------+---------------------+
|  1 | John      | Doe      | john@example.com  | 2018-03-29 19:26:26 |
|  2 | Logan     | Henry    | logan@example.com | 2018-03-29 19:26:26 |
|  3 | John      | Doe      | john@example.com  | 2018-03-29 19:26:26 |
|  4 | Mary      | Moe      | mary@example.com  | 2018-03-29 19:26:26 |
|  5 | Julie     | Dooley   | julie@example.com | 2018-03-29 19:26:26 |
|  6 | John      | Doe      | john@example.com  | 2018-03-29 19:26:26 |
|  7 | Mary      | Moe      | mary@example.com  | 2018-03-29 19:26:26 |
|  8 | Julie     | Dooley   | julie@example.com | 2018-03-29 19:26:26 |
|  9 | John      | Doe      | john@example.com  | 2018-03-29 19:26:56 |
| 10 | Logan     | Henry    | logan@example.com | 2018-03-29 19:26:56 |
| 11 | John      | Doe      | john@example.com  | 2018-03-29 19:26:56 |
| 12 | Mary      | Moe      | mary@example.com  | 2018-03-29 19:26:56 |
| 13 | Julie     | Dooley   | julie@example.com | 2018-03-29 19:26:56 |
| 14 | John      | Doe      | john@example.com  | 2018-03-29 19:26:56 |
| 15 | Mary      | Moe      | mary@example.com  | 2018-03-29 19:26:56 |
| 16 | Julie     | Dooley   | julie@example.com | 2018-03-29 19:26:56 |
+----+-----------+----------+-------------------+---------------------+
```
## MySQL DB Administration
### 1. Maintaining MySQL Database Tables

ANALYZE TABLE Table_NAME;  => up to date key distribution for Query Optimizer
OPTIMIZE TABLE table_name; =>  optimize the table to avoid this defragmenting problem
CHECK TABLE table_name; => check the integrity of database tables
REPAIR TABLE table_name; => repair some errors occurred in database tables

### 2. backup a MySQL database

    # Full Backup
    mysqldump -u [username] –p[password] [database_name] > [dump_file.sql]
    
    mysqldump -p -u testuser -h mysqldb testDB > testDB_backup.sql

    # Structure Only (no-data)
    mysqldump -u [username] –p[password] –no-data [database_name] > [dump_file.sql]
    
    # data only (no-create-info)
    mysqldump -u [username] –p[password] –no-create-info [database_name] > [dump_file.sql]
    
    # MultipleDB
    mysqldump -u [username] –p[password]  [dbname1,dbname2,…] > [dump_file.sql]
    
    # All-database
    mysqldump -u [username] –p[password] –all-database > [dump_file.sql]

### 3. Restore DB
    mysql -u <user> -p < db_backup.dump
If the dump is of a single database you may have to add a line at the top of the file:
    
    USE <database-name-here>;
If it was a dump of many databases, the use statements are already in there.

    C:\> mysql -u root -p
    
    mysql> create database mydb;
    mysql> use mydb;
    mysql> source db_backup.dump;


    mysql -utestuser -h mysqldb -p
    Enter password:
    ...
    mysql> use testDB_restore;
    Database changed
    mysql> source testDB_backup.sql;
    ...
    mysql> show tables;
    +--------------------------+
    | Tables_in_testDB_restore |
    +--------------------------+
    | MyGuests                 |
    +--------------------------+
    1 row in set (0.00 sec)
    
    mysql> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | logandb            |
    | mysql              |
    | performance_schema |
    | sys                |
    | testDB             |
    | testDB_restore     |
    +--------------------+
    7 rows in set (0.00 sec)

##	MYSQL Configuation	
### Configuration Files

    root@9a719b54cee9:/# ls -l /etc/mysql/my.cnf
    lrwxrwxrwx 1 root root 24 Mar 14 07:47 /etc/mysql/my.cnf -> /etc/alternatives/my.cnf
    
    root@9a719b54cee9:/# cat /etc/mysql/my.cnf
    !includedir /etc/mysql/conf.d/
    !includedir /etc/mysql/mysql.conf.d/
    
    root@9a719b54cee9:/# ls -l /etc/mysql/conf.d/
    -rw-r--r-- 1 root root 43 Mar 14 07:47 docker.cnf
    -rw-r--r-- 1 root root  8 Jul  9  2016 mysql.cnf
    -rw-r--r-- 1 root root 55 Jul  9  2016 mysqldump.cnf
    root@9a719b54cee9:/# ls -l /etc/mysql/mysql.conf.d/
    total 4
    -rw-r--r-- 1 root root 1216 Mar 15 15:50 mysqld.cnf
    
    root@9a719b54cee9:/# cat  /etc/mysql/mysql.conf.d/mysqld.cnf
### The MySQL  Server configuration file.
    #
    # For explanations see
    # http://dev.mysql.com/doc/mysql/en/server-system-variables.html
    
    [mysqld]
    pid-file        = /var/run/mysqld/mysqld.pid
    socket          = /var/run/mysqld/mysqld.sock
    datadir         = /var/lib/mysql
    #log-error      = /var/log/mysql/error.log
    
    # By default we only accept connections from localhost
    #bind-address   = 127.0.0.1
    # Disabling symbolic-links is recommended to prevent assorted security risks
    symbolic-links=0
    bind-address   = 0.0.0.0

### DataDir

```mysql> SHOW GLOBAL VARIABLES like 'datadir';
+---------------+-----------------+
| Variable_name | Value           |
+---------------+-----------------+
| datadir       | /var/lib/mysql/ |
+---------------+-----------------+
1 row in set (0.00 sec)

root@9a719b54cee9:/# ls -l /var/lib/mysql
total 188488
-rw-r----- 1 mysql mysql       56 Mar 15 14:36 auto.cnf
-rw------- 1 mysql mysql     1675 Mar 15 14:36 ca-key.pem
-rw-r--r-- 1 mysql mysql     1107 Mar 15 14:36 ca.pem
-rw-r--r-- 1 mysql mysql     1107 Mar 15 14:36 client-cert.pem
-rw------- 1 mysql mysql     1675 Mar 15 14:36 client-key.pem
-rw-r----- 1 mysql mysql      537 Mar 23 01:31 ib_buffer_pool
-rw-r----- 1 mysql mysql 50331648 Mar 23 16:59 ib_logfile0
-rw-r----- 1 mysql mysql 50331648 Mar 15 14:36 ib_logfile1
-rw-r----- 1 mysql mysql 79691776 Mar 23 16:59 ibdata1
-rw-r----- 1 mysql mysql 12582912 Mar 23 16:56 ibtmp1
drwxr-x--- 2 mysql mysql     4096 Mar 22 19:55 logandb
drwxr-x--- 2 mysql mysql     4096 Mar 15 14:36 mysql
drwxr-x--- 2 mysql mysql     4096 Mar 15 14:36 performance_schema
-rw------- 1 mysql mysql     1679 Mar 15 14:36 private_key.pem
-rw-r--r-- 1 mysql mysql      451 Mar 15 14:36 public_key.pem
-rw-r--r-- 1 mysql mysql     1107 Mar 15 14:36 server-cert.pem
-rw------- 1 mysql mysql     1675 Mar 15 14:36 server-key.pem
drwxr-x--- 2 mysql mysql    12288 Mar 15 14:36 sys
drwxr-x--- 2 mysql mysql     4096 Mar 23 14:08 testDB
drwxr-x--- 2 mysql mysql     4096 Mar 23 16:59 testDB_restore
```
### ibdata1
```
The file ibdata1 is the system tablespace for the InnoDB infrastructure.
It contains several classes for information vital for InnoDB
	Table Data Pages
	Table Index Pages
	Data Dictionary
	MVCC Control Data 
	Undo Space
	Rollback Segments
	Double Write Buffer (Pages Written in the Background to avoid OS caching)
	Insert Buffer (Changes to Secondary Indexes)
```
[XtraDB-InnoDB-internals](https://www.scribd.com/document/31337494/XtraDB-InnoDB-internals-in-drawing)

```
You can divorce Data and Index Pages from ibdata1 by enabling innodb_file_per_table. 
This will cause any newly created InnoDB table to store data and index pages in an external .ibd file.

Example
datadir is /var/lib/mysql
CREATE TABLE mydb.mytable (...) ENGINE=InnoDB;, creates /var/lib/mysql/mydb/mytable.frm 
innodb_file_per_table enabled, Data/Index Pages Stored in /var/lib/mysql/mydb/mytable.ibd
innodb_file_per_table disabled, Data/Index Pages Stored in ibdata1
```
```
mysql> SHOW GLOBAL VARIABLES like 'innodb_file%%';
+--------------------------+-----------+
| Variable_name            | Value     |
+--------------------------+-----------+
| innodb_file_format       | Barracuda |
| innodb_file_format_check | ON        |
| innodb_file_format_max   | Barracuda |
| innodb_file_per_table    | ON        |
+--------------------------+-----------+
4 rows in set (0.01 sec)

root@9a719b54cee9:/# ls -l /var/lib/mysql/testDB
total 112
-rw-r----- 1 mysql mysql  8704 Mar 23 14:08 MyGuests.frm
-rw-r----- 1 mysql mysql 98304 Mar 23 14:38 MyGuests.ibd
-rw-r----- 1 mysql mysql    65 Mar 23 14:08 db.opt
```
### iblog files (a.k.a. ib_logfile0, ib_logfile1)
```
If you want to know what the ib_logfile0 and ib_logfile1 are for, they are the InnoDB Redo Logs. They should never be erased or resized until a full normal shutdown of mysqld has taken place. 
If mysqld ever crashes, just start up mysqld. It will read across ib_logfile0 and ib_logfile1 to check for any data changes that were not posted to the the double write buffer in ibdata1. 
It will replay (redo) those changes. Once they are replayed and stored, mysqld becomes ready for new DB Connections.
```
### Error Log

There are three types of logs:
	The Error Log: It contains information about errors that occur while the server is running (also server start and stop)
	The General Query Log: This is a general record of what mysqld is doing (connect, disconnect, queries)
	The Slow Query Log: ?t consists of "slow" SQL statements (as indicated by its name).
By default no log files are enabled in MYSQL. All errors will be shown in the syslog.(/var/log/syslog)

#### To Enable them just follow below steps

**step1**: Go to this file(/etc/mysql/conf.d/mysqld_safe_syslog.cnf) and remove or comment those line.
**step2**: Go to mysql conf file(/etc/mysql/my.cnf ) and add following lines

    # To enable error log add following 
    
    [mysqld_safe]
    log_error=/var/log/mysql/mysql_error.log
    
    [mysqld]
    log_error=/var/log/mysql/mysql_error.log
    
    # To enable general query log add following
    
    general_log_file        = /var/log/mysql/mysql.log
    general_log             = 1
    
    # To enable Slow Query Log add following
    
    log_slow_queries       = /var/log/mysql/mysql-slow.log
    long_query_time = 2
    log-queries-not-using-indexes

**step3**: save the file and restart mysql using following commands
	service mysql restart

#### To enable logs at runtime

login to mysql client (mysql -u root -p ) and give:

    SET GLOBAL general_log = 'ON';
    SET GLOBAL slow_query_log = 'ON';

Ref: [How to](http://www.pontikis.net/blog/how-and-when-to-enable-mysql-logs)

### Display log results

#### Error log
-----------
    tail -f /var/log/syslog

REMARK: If you do not specify Error log file, MySQL keeps Error log at data dir (usually /var/lib/mysql in a file named {host_name}.err).

#### General Query log

    tail -f /var/log/mysql/mysql.log

REMARK: If you do not define General log file, MySQL keeps General log at data dir (usually /var/lib/mysql in a file named {host_name}.log).

#### Slow Query log
---------------
    tail -f /var/log/mysql/mysql-slow.log
REMARK: If you do not specify Slow Query log file, MySQL keeps Slow Query log at data dir (usually /var/lib/mysql in a file named {host_name}-slow.log).

## References
[MySQL Tutorial](https://www.ntu.edu.sg/home/ehchua/programming/sql/MySQL_Beginner.html)
