---
title: "리눅스에서 EMC Networker 에이전트 설치"
date: 2021-07-31T14:39:52+09:00
slug: ""
description: "리눅스 서버에 EMC Networker 백업 에이전트를 설치하는 방법"
keywords: []
draft: false
tags: ["linux", "os"]
math: false
toc: true
---

# 개요

EMC Networker 솔루션을 통해 백업을 받기 위해 백업 에이전트를 설치할 수 있다.  

# 환경

* **OS** : Red Hat Enterprise Linux release 6.5
* **Shell** : bash

# 설치절차

### 1. rpm 설치파일 업로드
```bash
[root@testserver1 rpm]# ls
lgtoclnt-18.2.0.5-1.x86_64.rpm  lgtoxtdclnt-18.2.0.5-1.x86_64.rpm
```



### 2. 패키지 설치

반드시 `lgtoclnt` 를 먼저 설치후, `lgtoxtdclnt` 를 설치해야 정상적으로 완료된다.  



**lgtoclnt 패키지 설치**  

```bash
[root@testserver1 rpm]# rpm -ivh lgtoclnt-18.2.0.5-1.x86_64.rpm 
warning: lgtoclnt-18.2.0.5-1.x86_64.rpm: Header V3 RSA/SHA1 Signature, key ID c5dfe03d: NOKEY
Preparing...                ########################################### [100%]
   1:lgtoclnt               ########################################### [100%]
```

`lgtoclnt` 패키지 설치가 정상적으로 완료되었다.  

  

**lgtoxtdclnt 패키지 설치** 

```bash
[root@testserver1 rpm]# rpm -iv lgtoxtdclnt-18.2.0.5-1.x86_64.rpm 
warning: lgtoxtdclnt-18.2.0.5-1.x86_64.rpm: Header V3 RSA/SHA1 Signature, key ID c5dfe03d: NOKEY
Preparing...                ########################################### [100%]
   1:lgtoxtdclnt            ########################################### [100%]
[root@testserver1 rpm]# 
```

`lgtoxtdclnt` 패키지 설치가 정상적으로 완료되었다.  



### 3. 호스트 파일 수정

`/etc/hosts` 파일에 추가할 내용  
- 백업 관리서버의 IP 주소, Hostname
- 자기 자신의 IP 주소, Hostname

```bash
[root@testserver1 rpm]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
[...]

### EMC NETWORKER ###
1.1.1.1  testserver1
2.2.2.2  BACKUP_MANAGEMENT_SERVER_HOSTNAME
```



### 4. NetWorker 서비스 시작

```bash
[root@testserver1 ~]# service networker start
[root@testserver1 ~]#
```



### 5. NetWorker 프로세스 확인

```bash
[root@testserver1 ~]# ps -ef | grep nsr
root     53433     1  0 13:14 ?        00:00:00 /usr/sbin/nsrexecd
```

NetWorker 데몬인  `nsrexecd` 프로세스가 구동중이다.
