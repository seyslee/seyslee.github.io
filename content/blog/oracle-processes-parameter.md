---
title: "Oracle processes 파라미터 변경"
date: 2021-10-06T23:48:09+09:00
slug: ""
description: "ORA-12516 에러를 해결하기 위해 Oracle processes 값을 변경하고 적용하는 방법을 설명합니다."
keywords: []
draft: false
tags: ["database", "oracle"]
math: false
toc: true
---

# 개요

ORA-12516 에러를 해결하기 위해 Oracle DB 리소스 파라미터의 Processes 값을 변경하고 적용할 수 있다.

# 환경

- **OS** : Red Hat Enterprise Linux Server release 5.5 (Tikanga)
- **Shell** : bash
- **DB** : Oracle Database 10g Enterprise Edition Release 10.2.0.4.0 - Production

# 증상

```sql
SQL> select count(*) from adm.share_table@link_datanet
                                     *
ERROR at line 1:
ORA-12516: TNS:listener could not find available handler with matching protocol
stack
```

다른 서버에서 문제가 발생한 서버에 DB Link 조회시 에러 메세지를 반환해 조회할 수 없는 문제이다.

# 원인

`ORA-12516: TNS:listener could not find available handler with matching protocol stack` 에러가 발생하는 가장 대표적인 원인은 오라클 DB에 붙을 수 있는 프로세스 혹은 세션의 개수가 최대치에 도달했기 때문이다.  

이미 접속되어 있는 세션은 잘 동작하지만 새로운 프로그램이 DB에 접속할 때 DB는 이미 자신이 허용할 수 있는 연결의 최대치에 도달했기 때문에 에러를 반환하고 연결 실패가 발생한다.


# 조치방법

### 1. sqlplus 접속

```sql
$ sqlplus / as sysdba

SQL*Plus: Release 10.2.0.4.0 - Production on Wed Oct 6 11:00:47 2021

Copyright (c) 1982, 2007, Oracle.  All Rights Reserved.

Connected to:
Oracle Database 10g Enterprise Edition Release 10.2.0.4.0 - Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options

SQL>
```



### 2. 리소스 파라미터 확인

```sql
SQL> SET LINESIZE 200;
SQL> SELECT * FROM V$RESOURCE_LIMIT;

RESOURCE_NAME                  CURRENT_UTILIZATION MAX_UTILIZATION INITIAL_ALLOCATION   LIMIT_VALUE
------------------------------ ------------------- --------------- -------------------- --------------------
processes                                      247             250        250                  250
sessions                                       250             255        280                  280
enqueue_locks                                   20              37       3840                 3840
enqueue_resources                               21              81       1452            UNLIMITED
ges_procs                                        0               0          0                    0
ges_ress                                         0               0          0            UNLIMITED
ges_locks                                        0               0          0            UNLIMITED
ges_cache_ress                                   0               0          0            UNLIMITED
ges_reg_msgs                                     0               0          0            UNLIMITED
ges_big_msgs                                     0               0          0            UNLIMITED
ges_rsv_msgs                                     0               0          0                    0

RESOURCE_NAME                  CURRENT_UTILIZATION MAX_UTILIZATION INITIAL_ALLOCATION   LIMIT_VALUE
------------------------------ ------------------- --------------- -------------------- --------------------
gcs_resources                                    0               0          0                    0
gcs_shadows                                      0               0          0                    0
dml_locks                                        0              79       1232            UNLIMITED
temporary_table_locks                            0               3  UNLIMITED            UNLIMITED
transactions                                     3              21        308            UNLIMITED
branches                                         2              18        308            UNLIMITED
cmtcallbk                                        0               2        308            UNLIMITED
sort_segment_locks                               0               5  UNLIMITED            UNLIMITED
max_rollback_segments                           12              15        308                65535
max_shared_servers                               1               1  UNLIMITED            UNLIMITED
parallel_max_servers                             0               0        160                 3600
```

`processes` 값이 최대 250개 중 현재 247을 사용중이다.



**processes, sessions 값의 의미**

`processes`는 동시에 Oracle에 연결할 수 있는 OS 사용자 프로세스의 최대 수를 지정하는 값이다.  

`processes` 값에는 백그라운드 프로세스, Job 프로세스, 병렬 실행 프로세스 등의 수가 포함된다.  

`processes` 값을 변경하면 `sessions` 값도 자동으로 (`processes` x 1.1) + 5 로 설정된다.



### 3. spfile 존재유무 확인

```sql
SQL> SHOW PARAMETER SPFILE;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /oracle/10g/dbs/spfiledba.ora
```

**spfile**

- spfile은 Server Parameter File의 약자로 데이터베이스 관련 파라미터 설정 파일이다.
- spfile은 Oracle 9i 버전부터 지원되는 기능이므로 존재하지 않는다면 DB 버전을 확인한다.
- spfile은 `ALTER SYSTEM` 명령어를 통해 운영중에 파라미터를 수정 할 수 있다. spfile의 장점은 서버를 재시작하지 않고 운영중에 변경사항을 반영 가능하다는 점이다.
- spfile은 기본적으로 binary 파일이기 때문에 텍스트 편집기(vi editor, nano 등)를 이용해 수정하면 다시 사용할 수 없다.



### 4. spfile 설정 확인

```bash
$ strings /oracle/10g/dbs/spfiledba.ora
[...]
*.open_cursors=300
*.pga_aggregate_target=241172480
*.processes=250
*.remote_login_passwordfile='EXCLUSIVE'
*.resource_limit=TRUE
*.resource_manager_plan=''
*.service_names='dba','DBA.REGRESS.RDBMS.DEV.US.ORACLE.COM'
*.sga_target=608174080
*.undo_management='AUTO'
*.undo_retention=900
*.undo_tablespace='UNDOTBS1'
*.user_dump_dest='/oracle/admin/dba/udump'
*.utl_file_dir='/BACKUP/logminer'
```

spfile은 binary 형식의 파일이므로 cat 명령어가 아닌 strings 명령어를 사용해 읽어야한다.

spfile을 확인해보니 현재 `processes` 값이 250이다.



### 5. 리소스 파라미터 수정

**명령어 형식**

```bash
SQL> alter system set processes=<INT> scope=spfile;
```

**실제 명령어**

```bash
SQL> alter system set processes=400 scope=spfile;

System altered.
```

`processes` 값을 400으로 변경한다. `System altered` 메세지가 출력되면 정상 적용된 것이다.



### 6. spfile 변경 확인

```bash
$ strings /oracle/10g/dbs/spfiledba.ora
[...]
*.open_cursors=300
*.pga_aggregate_target=241172480
*.processes=400
*.remote_login_passwordfile='EXCLUSIVE'
*.resource_limit=TRUE
*.resource_manager_plan=''
*.service_names='dba','DBA.REGRESS.RDBMS.DEV.US.ORACLE.COM'
*.sga_target=608174080
*.undo_management='AUTO'
*.undo_retention=900
*.undo_tablespace='UNDOTBS1'
*.user_dump_dest='/oracle/admin/dba/udump'
*.utl_file_dir='/BACKUP/logminer'
```

`processes` 값이 400으로 변경되었다.



### 7. DB 재기동

**중지 명령어**

```sql
SQL> shutdown immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.
```

**기동 명령어**

```sql
SQL> startup;
ORACLE instance started.

Total System Global Area  608174080 bytes
Fixed Size                  1268896 bytes
Variable Size             373293920 bytes
Database Buffers          226492416 bytes
Redo Buffers                7118848 bytes
Database mounted.
Database opened.
```



### 8. 리소스 파라미터 변경 확인

```sql
SQL> SET LINESIZE 200;
SQL> SELECT * FROM V$RESOURCE_LIMIT;

RESOURCE_NAME                  CURRENT_UTILIZATION MAX_UTILIZATION INITIAL_ALLOCATION   LIMIT_VALUE
------------------------------ ------------------- --------------- -------------------- --------------------
processes                                       77              86        400                  400
sessions                                        80              89        445                  445
enqueue_locks                                   19              30       5790                 5790
enqueue_resources                               19              48       2176            UNLIMITED
ges_procs                                        0               0          0                    0
ges_ress                                         0               0          0            UNLIMITED
ges_locks                                        0               0          0            UNLIMITED
ges_cache_ress                                   0               0          0            UNLIMITED
ges_reg_msgs                                     0               0          0            UNLIMITED
ges_big_msgs                                     0               0          0            UNLIMITED
ges_rsv_msgs                                     0               0          0                    0

RESOURCE_NAME                  CURRENT_UTILIZATION MAX_UTILIZATION INITIAL_ALLOCATION   LIMIT_VALUE
------------------------------ ------------------- --------------- -------------------- --------------------
gcs_resources                                    0               0          0                    0
gcs_shadows                                      0               0          0                    0
dml_locks                                        0              51       1956            UNLIMITED
temporary_table_locks                            0               3  UNLIMITED            UNLIMITED
transactions                                     0              11        489            UNLIMITED
branches                                         0               8        489            UNLIMITED
cmtcallbk                                        0               1        489            UNLIMITED
sort_segment_locks                               0               3  UNLIMITED            UNLIMITED
max_rollback_segments                           13              13        489                65535
max_shared_servers                               1               1  UNLIMITED            UNLIMITED
parallel_max_servers                             0               0        160                 3600

22 rows selected.
```

`processes` 의 LIMIT_VALUE 값이 250에서 400으로 변경되었다.  

`processes` 파라미터의 영향을 받는 `sessions` LIMIT_VALUE 값도 (`processes` x 1.1) + 5 의 결과인 445로 변경되었다.