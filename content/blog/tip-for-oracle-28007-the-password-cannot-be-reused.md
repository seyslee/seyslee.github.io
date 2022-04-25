---
title: "🔒 ORA-28007: the password cannot be reused 조치방법"
date: 2021-09-04T17:38:12+09:00
slug: ""
description: "ORA-28007: the password cannot be reused 에러 메세지에 대한 조치방법"
keywords: []
draft: false
tags: ["database", "oracle", "security"]
math: false
toc: true
---

# 문제점

DB 계정의 패스워드를 갱신할 때 `ORA-28007: the password cannot be reused` 에러 메세지가 출력되면서 패스워드를 갱신할 수 없는 문제를 해결한다.

**에러 메세지의 예시**

```sql
SQL> ALTER USER MAXGAUGE IDENTIFIED BY "...";
ALTER USER MAXGAUGE IDENTIFIED BY "...";
*
ERROR at line 1:
ORA-28007: the password cannot be reused
```


# 사유
`ORA-28007: the password cannot be reused`는 동일한 패스워드를 Limit 개수만큼 변경했을 때 발생하는 오류이다.


# 환경
* **OS** : Red Hat Enterprise Linux Server release 5.10 (Tikanga)
* **ID** : oracle
* **Shell** : bash
* **Database** : Oracle Database 11g Release 11.2.0.3.0 - Production


# 절차
### 1. Oracle 접속
oracle 계정으로 접속한다.

```bash
$ id
uid=501(oracle) gid=501(dba) groups=501(dba)
```

sysdba 권한을 얻어 sys 계정 접속한다.
```bash
$ sqlplus sys as sysdba

SQL*Plus: Release 11.2.0.3.0 Production on Thu Sep 2 13:28:01 2021

Copyright (c) 1982, 2011, Oracle.  All rights reserved.

Enter password:

Connected to:
Oracle Database 11g Release 11.2.0.3.0 - Production

SQL> 
```



### 2. 계정의 프로필 확인

```sql
SQL> set linesize 200;
SQL> SELECT USERNAME, ACCOUNT_STATUS, PROFILE FROM DBA_USERS WHERE USERNAME='MAXGAUGE';

USERNAME                       ACCOUNT_STATUS                   PROFILE
------------------------------ -------------------------------- ------------------------------
MAXGAUGE                       EXPIRED                          DEFAULT
```
MAXGAUGE 계정이 만료된(`EXPIRED`) 상태이며, `Default` Profile 을 사용하는 걸 확인할 수 있다.



### 3. 프로필 설정확인
```sql
SQL> SELECT * FROM DBA_PROFILES WHERE PROFILE='DEFAULT';
PROFILE                        RESOURCE_NAME                    RESOURCE LIMIT
------------------------------ -------------------------------- -------- ----------------------------------------
DEFAULT                        COMPOSITE_LIMIT                  KERNEL   UNLIMITED
DEFAULT                        SESSIONS_PER_USER                KERNEL   UNLIMITED
DEFAULT                        CPU_PER_SESSION                  KERNEL   UNLIMITED
DEFAULT                        CPU_PER_CALL                     KERNEL   UNLIMITED
DEFAULT                        LOGICAL_READS_PER_SESSION        KERNEL   UNLIMITED
DEFAULT                        LOGICAL_READS_PER_CALL           KERNEL   UNLIMITED
DEFAULT                        IDLE_TIME                        KERNEL   UNLIMITED
DEFAULT                        CONNECT_TIME                     KERNEL   UNLIMITED
DEFAULT                        PRIVATE_SGA                      KERNEL   UNLIMITED
DEFAULT                        FAILED_LOGIN_ATTEMPTS            PASSWORD 3
DEFAULT                        PASSWORD_LIFE_TIME               PASSWORD 90
DEFAULT                        PASSWORD_REUSE_TIME              PASSWORD 356
DEFAULT                        PASSWORD_REUSE_MAX               PASSWORD 10
DEFAULT                        PASSWORD_VERIFY_FUNCTION         PASSWORD VERIFY_FUNCTION
DEFAULT                        PASSWORD_LOCK_TIME               PASSWORD 3
DEFAULT                        PASSWORD_GRACE_TIME              PASSWORD 5
```

**암호 재사용 방지와 관련된 설정값**

아래 두 설정값은 사용자가 지정된 기간 동안 암호를 재사용하지 못하게 한다. 아래의 한 가지 방법으로 구현할 수 있다.

* `PASSWORD_REUSE_TIME` : 주어진 날 수 동안 암호를 재사용할 수 없도록 지정. (PASSWORD_REUSE_TIME 값이 5일 경우, 5일 안에는 똑같은 암호를 사용할 수 없다.)

* `PASSWORD_REUSE_MAX` : 사용했던 암호를 기억하는 횟수. 사용했던 암호를 재사용하는 걸 방지하는 목적의 설정값.

  

### 4. 보안설정 해제

불가피하게 패스워드 재사용이 필요할 경우, 암호 재사용 방지와 관련된 설정값을 해제한다.

```sql
SQL> ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_TIME UNLIMITED;

Profile altered.
```
```sql
SQL> ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_MAX UNLIMITED;

Profile altered.
```



### 5. 패스워드 갱신

**명령어 형식**

```sql
SQL> ALTER USER MAXGAUGE IDENTIFIED BY "<갱신할 패스워드>";
```

**명령어 예시**
```sql
SQL> ALTER USER MAXGAUGE IDENTIFIED BY "change!me!please";

User altered.
```



### 6. 계정 상태 확인

```sql
SQL> SELECT USERNAME, ACCOUNT_STATUS, PROFILE FROM DBA_USERS WHERE USERNAME='MAXGAUGE';

USERNAME                       ACCOUNT_STATUS                   PROFILE
------------------------------ -------------------------------- ------------------------------
MAXGAUGE                       OPEN                             DEFAULT
```
MAXGAUGE 계정이 잠금해제(`OPEN`) 상태로 변경되었다.



### 7. 보안설정 원복하기

해제했던 암호 재사용 방지 관련 설정값을 다시 돌려놓는다.

```sql
SQL> ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_TIME 356;

Profile altered.
```
```sql
SQL> ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_MAX 10;

Profile altered.
```



# 결론

불가피하게 패스워드 재사용이 필요할 경우 위 방법을 사용한다.  

그러나 무분별한 패스워드 재사용은 보안 취약점이다. 불편하더라도 완전히 새로운 패스워드로 갱신해버리는 것이 안전하며 정상적인 조치 방법이다.