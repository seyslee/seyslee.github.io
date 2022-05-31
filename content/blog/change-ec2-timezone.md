---
title: "EC2 타임존 변경"
date: 2022-05-31T19:52:10+09:00
lastmod: 2022-02-31T19:52:15+09:00
slug: ""
description: "Amazon Linux 2 EC2의 타임존을 한국 표준시(KST)로 바꾸는 방법을 소개합니다."
keywords: []
draft: false
tags: ["linux", "aws"]
math: false
toc: true
---

# 개요

EC2 인스턴스의 표준시를 변경하는 방법을 소개합니다.

종종 EC2 인스턴스의 시간을 한국 표준시로 변경해야하는 경우가 있습니다.

제 최근 사례로는 EC2 인스턴스 로컬에서 돌리는 테스트 코드로 인해 생성되는 로그 시간이 협정 세계시<sup>UTC, Universal Time Coordinated</sup>가 아닌 한국 표준시<sup>KST, Korea Standard Time</sup>로 찍히도록 해야하는 상황 등이 있었습니다.

<br>

# 환경

- **OS** : Amazon Linux 2
- **Shell** : bash

<br>

# 설정방법

Amazon Linux 2 인스턴스는 기본적으로 UTC<sup>협정 세계시</sup> 표준 시간대로 설정됩니다.

<br>

### OS 버전 확인

현재 접속한 인스턴스의 운영체제가 Amazon Linux 2 임을 확인합니다.

```bash
$ id
uid=1000(ec2-user) gid=1000(ec2-user) groups=1000(ec2-user),4(adm),10(wheel),190(systemd-journal)
```

```bash
$ cat /etc/os-release
NAME="Amazon Linux"
VERSION="2"
ID="amzn"
ID_LIKE="centos rhel fedora"
VERSION_ID="2"
PRETTY_NAME="Amazon Linux 2"
...
```
운영체제 버전이 `Amazon Linux 2`입니다.

<br>

### 현재 타임존 확인

```bash
$ timedatectl
      Local time: Tue 2022-05-31 08:58:34 UTC
  Universal time: Tue 2022-05-31 08:58:34 UTC
        RTC time: Tue 2022-05-31 08:58:35
       Time zone: n/a (UTC, +0000)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: n/a
```
현재 설정된 `Time zone` 값이 `n/a`이면 협정 세계시<sup>UTC</sup>를 의미합니다.

<br>

### 타임존 변경

이 예제에서는 타임존을 서울 `Asia/Seoul`로 설정하겠습니다.

<br>

**타임존 목록 확인**

```bash
$ timedatectl list-timezones | grep -i seoul
Asia/Seoul
```

<br>

**타임존 변경**

타임존을 `Asia/Seoul`로 변경합니다.

```bash
$ sudo timedatectl set-timezone Asia/Seoul
```

<br>

### 타임존 설정 재확인

`Time zone` 값이 `n/a (UTC, +0000)`에서 `Asia/Seoul (KST, +0900)`으로 변경되었습니다.

```bash
$ timedatectl
      Local time: Tue 2022-05-31 17:58:59 KST
  Universal time: Tue 2022-05-31 08:58:59 UTC
        RTC time: Tue 2022-05-31 08:59:00
       Time zone: Asia/Seoul (KST, +0900)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: n/a
```

<br>

`date` 명령어로 현재 시간을 확인합니다.

```bash
$ date
Tue May 31 17:59:01 KST 2022
```

`date` 결과도 한국 표준시<sup>KST</sup>로 출력되는 걸 확인할 수 있습니다.

<br>

**중요**

위 과정에서 조치한 EC2 타임존 설정은 영구적용이기 때문에 EC2 인스턴스가 리부팅된 후에도 계속 유지됩니다.

```bash
$ uptime
 19:49:56 up 0 min,  0 users,  load average: 0.13, 0.03, 0.01
```

<br>

```bash
$ timedatectl
      Local time: Tue 2022-05-31 19:49:58 KST
  Universal time: Tue 2022-05-31 10:49:58 UTC
        RTC time: Tue 2022-05-31 10:49:59
       Time zone: Asia/Seoul (KST, +0900)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: n/a
```

EC2 인스턴스를 리부팅한 뒤에도 여전히 `Time zone` 값이 `Asia/Seoul (KST, +0900)` 입니다.

<br>

# 참고자료

**AWS 공식문서**  
[Amazon Linux의 표준 시간대 변경](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/set-time.html#change_time_zone)