---
title: "AIX 계정잠금 해제"
date: 2021-10-20T21:04:15+09:00
Lastmod: 2021-10-20T21:09:10+09:00
slug: ""
description: "IBM AIX에서 잠긴 계정을 확인하고 잠금 해제하는 방법을 설명합니다."
keywords: []
draft: false
tags: ["os", "unix", "aix"]
math: false
toc: true
---

# 개요
IBM AIX에서 계정이 잠긴 여부를 확인하고 잠긴 계정을 해제할 수 있다.

<br>

# 증상
OS 계정이 잠겨서 원격 로그인(SSH)이 불가능한 상황

<br>

# 환경
- **OS** : IBM AIX 7.2.0.0
- **Shell** : ksh

<br>

# 해결방안
쉘에서 명령어를 실행해 계정의 잠금상태를 확인하고 잠금을 해제하면 된다.  
계정 패스워드 제어와 관련된 작업이기 때문에 반드시 root 권한을 얻어 실행해야만 한다.  

### 1. 로그인 실패회수 확인
**명령어 형식**
```bash
$ lsuser -a <속성명> <계정명>
```

<br>

**명령어 예시**
```bash
$ lsuser -a unsuccessful_login_count devuser1
devuser1 unsuccessful_login_count=6
```
`devuser1` 계정에서 로그인을 6번 실패한 이력이 있다.

<br>

### 2. 계정상태 확인
**명령어 형식**
```bash
$ lsuser -a <속성명> <계정명>
```

<br>

**명령어 예시**
```bash
$ lsuser -a account_locked devuser1
devuser1 account_locked=true
```
devuser1 계정의 `account_locked` 값이 `true`이므로 계정이 잠긴 상태이다.

<br>

### 3. 로그인 실패회수 초기화
`devuser1` 계정의 로그인 실패회수(`unsuccessful_login_count`) 값을 0으로 설정하여 초기화한다.  
```bash
$ chsec -f /etc/security/lastlog -a unsuccessful_login_count=0 -s devuser1
```
**명령어 옵션**  
`-f` : 파일명(File) 옵션  
`-a` : 속성 옵션(Attribute)  
`-s` : 계정명(Stanza)  



<br>

### 4. 계정잠금 해제

**명령어 형식**
```bash
$ chuser <속성명>=<값> <계정명>
```

**명령어 예시**
```bash
$ chuser account_locked=false devuser1
devuser1 account_locked=false
```
`account_locked` 속성값을 `true`에서 `false`로 변경해서 devuser1 계정 잠금을 해제한다.  

<br>

# 추가정보

이 부분부터는 본문인 '잠긴 OS 계정 풀기' 메뉴얼과는 무관하나 알고 있으면 유용한 명령어이다.

<br>

## A. 계정 잠그는 방법
종종 서버의 보안강화를 목적으로 관리자가 장기간 사용하지 않는 운휴 계정을 잠금처리할 때 사용한다.

### 1. 계정 잠금 실행 
```bash
$ chuser account_locked=true devuser1
```
<br>

### 2. 계정상태 확인
```bash
$ lsuser -a account_locked devuser1
devuser1 account_locked=true
```
`devuser1` 계정의 `account_locked` 값이 true이므로 현재 계정이 잠긴 상태이다.

<br>

## B. 계정 잠금 임계값 설정
무차별 대입 공격(brute-force attack)은 특정 암호를 풀기 위해 가능한 모든 값을 대입해 암호를 뚫는 공격 기법이다.  
무작위 대입 공격을 방어하는 대표적인 방법은 서버 보안설정에서 계정 잠금 임계값을 설정하는 것이다.  
아래는 AIX 서버에서 여러번 로그인 실패시 계정이 잠기는 설정방법이다.

### 1. user 설정파일 확인
```bash
$ cat /etc/security/user
[...]
default:
        loginretries = 0
```
`loginretries` : 계정 잠금 임계값 (계정 잠그기 전 로그인 시도 횟수)
`loginretries = 0`은 로그인 시도 가능 횟수가 무제한이며, 계정 잠금 임계값이 설정되지 않은 상태를 의미한다.

<br>

### 2. 계정 잠금 임계값 수정
```bash
$ vi /etc/security/user
[...]
default:
        loginretries = 5
```
vi 편집기를 사용해서 `loginretries` 값을 0에서 5로 수정한다. 기본적<sup>default</sup>으로 모든 계정이 5번 로그인이 실패하면, 계정이 잠기게 된다.

작업 끝.