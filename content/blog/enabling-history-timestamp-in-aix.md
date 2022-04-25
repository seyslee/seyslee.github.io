---
title: "AIX History 시간 설정"
date: 2021-10-23T15:16:09+09:00
lastmod: 2021-10-23T15:19:56+09:00
slug: ""
description: "IBM AIX에서 History 시간이 나오도록 설정하는 방법을 설명합니다."
keywords: []
draft: false
tags: ["os", "unix", "aix"]
math: false
toc: true
---
# 개요
IBM AIX의 ksh에서 명령어 실행기록(history)에 실행시간을 표시하도록 설정합니다.

<br>


# 환경
- **OS** : IBM AIX 7.2.0.0
- **Shell** : ksh

<br>


# 문제점
명령어 실행기록에 실행시간(Timestamp)가 표기되지 않는다.
```shell
$ fc -t
[...]
641     ? :: su - oracle
642     ? :: vi /etc/environments
643     ? :: fc -t
```
명령어 실행시간(time field)이 물음표로 표시되어 정확한 명령어 실행시간을 확인할 수 없다.  



### 명령어 실행 시간의 중요성

시스템 엔지니어가 장애처리(Troubleshooting) 시 명령어 실행시간을 통해 장애 원인을 발견하는 경우가 종종 있다.

서버 환경에서는 사람에 의해 유발되는 장애(Human Fault)가 생각보다 많이 발생하기 때문이다.

무엇보다 명령어 실행 시간을 체크하는 일은 장애처리시 간단하면서도 관리자에게 많은 정보를 제공해주기 때문에,  

실행한 명령어에 실행시간까지 기록하도록 설정해놓는다면 장기적인 관점에서 서버 관리가 더 편해진다.

<br>


# 해결법
IBM AIX 5.3 버전 이후부터 ksh에서 timestamp 기능을 지원한다.
환경설정(`/etc/environment`) 파일에 새 값을 추가해 명령어 기록에 시간을 표기할 수 있다.

### 1. 작업전 environment 파일 확인

```shell
$ cat /etc/environment
[...] 
PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:/usr/java7_64/jre/bin:/usr/java7_64/bin
TZ=Asia/Seoul
LANG=en_US
LOCPATH=/usr/lib/nls/loc
```
기존에는 `EXTENDED_HISTORY` 파라미터가 없다.




### 2. environment 파일 수정
```shell
$ cat /etc/environment
[...]
PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:/usr/java7_64/jre/bin:/usr/java7_64/bin
TZ=Asia/Seoul
LANG=en_US
LOCPATH=/usr/lib/nls/loc
EXTENDED_HISTORY=ON
```
vi 편집기로 `/etc/environment` 파일을 열고 맨 아랫줄에 `EXTENDED_HISTORY` 파라미터에 `ON` 값을 추가한다.  
`/etc/environment` 파일에 `EXTENDED_HISTORY` 파라미터를 추가하면 전체 계정에 해당 설정이 적용된다.



### 3. 로그아웃 후 재로그인
```shell
$ exit
```



### 4. 명령어 실행기록 확인

```shell
$ fc -t
662     2021/10/23 10:16:58 :: cat .sh_history | more
663     2021/10/23 10:17:07 :: ls
664     2021/10/23 10:17:16 :: vi .sh_history
665     2021/10/23 10:17:36 :: vi .sh_history
666     2021/10/23 10:17:38 :: ls
667     2021/10/23 10:17:39 :: fc -t
668     2021/10/23 10:17:44 :: vi .sh_history
669     2021/10/23 10:17:53 :: fc -t
670     2021/10/23 10:24:09 :: fc -t
671     2021/10/23 10:24:12 :: id
672     2021/10/23 10:24:13 :: clear
673     2021/10/23 10:24:15 :: fc -t
674     2021/10/23 10:24:18 :: clear
675     2021/10/23 10:24:21 :: ping 127.0.0.1
676     2021/10/23 10:24:24 :: clear
677     2021/10/23 10:24:28 :: fc -t
```
이제 명령어 실행시간이 표시된다.
`history -t` 명령어도 `fc -t` 명령어와 완전 동일한 기능을 하니 기호에 맞춰 사용하면 된다.

```shell
$ history -t
690     2021/10/23 10:32:03 :: id
691     2021/10/23 10:32:03 :: ls
692     2021/10/23 10:32:04 :: pwd
693     2021/10/23 10:32:05 :: pwd
694     2021/10/23 10:32:06 :: ls
695     2021/10/23 10:32:07 :: clear
696     2021/10/23 10:32:08 :: clear
697     2021/10/23 10:32:09 :: id
698     2021/10/23 10:32:11 :: date
699     2021/10/23 10:32:15 :: cat /etc/passwd
700     2021/10/23 10:32:16 :: clear
701     2021/10/23 10:32:17 :: clear
702     2021/10/23 10:32:18 :: id
703     2021/10/23 10:32:19 :: id
704     2021/10/23 10:32:20 :: pwd
705     2021/10/23 10:32:24 :: history -t
```