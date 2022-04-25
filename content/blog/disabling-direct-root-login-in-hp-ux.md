---
title: "HP-UX root 직접 로그인 금지"
date: 2021-07-31T09:42:09+09:00
lastmod: 2021-10-27T21:19:35+09:00
slug: ""
description: "HP-UX에서 root로 바로 로그인 방지하는 설정 방법"
keywords: []
draft: false
tags: ["os", "unix", "hpux"]
math: false
toc: true
---

# 개요

HP-UX 운영체제에서 SSH root 로그인 금지 설정을 할 수 있다.  

<br>

# 환경

- **OS** : HP-UX B.11.31
- **Shell** : sh (POSIX Shell)

<br>

# 설정방법

### 1. 설정파일 확인

SSH 설정파일의 기본 경로는 `/opt/ssh/etc/sshd_config` 이다.  

```bash
> vi /opt/ssh/etc/sshd_config
[...]
PermitRootLogin yes
```

`PermitRootLogin yes` 를  `no` 로 변경

```bash
> vi /opt/ssh/etc/sshd_config
[...]
PermitRootLogin no
```

### 2. SSH 서비스 중지

변경된 SSH 설정을 적용하기 위해서 SSH 서비스(`secsh`)를 중지한 후, 다시 기동시킨다.

SSH를 중지하더라도 이미 로그인 상태인 원격 세션은 끊기지 않는다.

```bash
> /sbin/init.d/secsh stop
HP-UX Secure Shell stopped
```

### 3. SSH 서비스 시작

```bash
> /sbin/init.d/secsh start
HP-UX Secure Shell started
```

### 4. SSH 서비스 확인

```bash
> ps -ef | grep ssh
```

<br>

# 참고자료

[How to Disable Root SSH Login in HP-UX?](https://www.dbappweb.com/2017/07/20/disable-root-shh-login-hp-ux/)
