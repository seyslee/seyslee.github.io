---
title: "Cockpit 로그인 메세지 비활성화"
date: 2021-08-23T22:22:15+09:00
lastmod: 2021-10-27T21:33:20+09:00
slug: ""
description: "CentOS 8에서 로그인 시 발생하는 Cockpit의 불필요한 motd(message of the day) 메세지를 비활성화하는 방법"
keywords: []
draft: false
tags: ["os", "linux"]
math: false
toc: true
---

# 환경

- **OS** : CentOS Linux release 8.3.2011
- **Shell** : Bash
- **Package** : cockpit

<br>

# 증상

서버에 로그인할 때마다 세션에 불필요한 Welcome Message 출력된다. Cockpit 을 사용하지 않으니 메세지를 표출되지 않도록 영구 삭제한다.

```bash
Activate the web console with: systemctl enable --now cockpit.socket
[testserver ~]#
```

<br>

# 배경지식

### Cockpit

Cockpit의 사전적 의미는 비행기 조종석을 의미한다.  

리눅스 환경에서 Cockpit 은 Fedora Project 에서 나온 웹 UI 기반의 모니터링 및 관리 툴이다.  

Cockpit을 이용하면 별도 프로그램 설치 없이도 웹 브라우저를 통해 리눅스 서버에 원격접속하고 관리할 수 있다. 참고로 Cockpit Web Console의 기본포트는 TCP 9090이다.  

### 서비스 최소화의 원칙

모든 서버는 최소한의 서비스로만 운영되어야 한다. 아무리 기능이 유용해도 사용하지 않는 서비스라면 반드시 비활성화(Disable) 조치를 한다. 서비스 최소화의 목적에는 크게 2가지가 있다. 보안 향상과 불필요한 자원 낭비를 방지하기 위함이다.  

내가 근무하는 데이터센터는 이 원칙을 지키기 위해 Cockpit 서비스를 사용하지 않는다.

<br>

# 해결법

### 1. motd 디렉토리 이동

motd란 message of the day의 줄임말로 유저가 로그인시 특정 메시지를 뛰우는걸 말한다. CentOS에서는 `/etc/motd` 파일에 전달할 메시지를 적어 놓는다.  

`motd.d` 는 어플리케이션 개별로 motd 메세지를 모아놓은 디렉토리이다.

```bash
[testserver ~]# cd /etc/motd.d
```

### 2. motd 파일 확인

`motd.d` 디렉토리 안에 `cockpit` 링크 파일이 들어있는 걸 확인할 수 있다.

```bash
[testserver motd.d]# ls
lrwxrwxrwx. 1 root root 17. 8월 25일  2020  cockpit -> /run/cockpit/motd
```

### 3. motd 파일 삭제

```bash
[testserver motd.d]# rm -f cockpit
[testserver motd.d]#
```

`rm -f` : 삭제 여부를 묻지 않고 강제(force)로 파일을 삭제한다.

### 4. 로그인 테스트

다시 로그인해보면 Cockpit 관련 motd 메세지가 출력되지 않는다.

```bash
Last login: Tue May 11 20:09:04 2021 from 10.10.10.10
[testserver ~]$
```

<br>

# 참고자료

https://www.programmersought.com/article/14417225140/