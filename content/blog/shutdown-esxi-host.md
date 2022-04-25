---
title: "ESXi 호스트 서버 끄기"
date: 2021-10-25T19:57:09+09:00
lastmod: 2021-10-25T20:19:35+09:00
slug: ""
description: "VMware ESXi 호스트 서버를 CLI 환경에서 종료(Shutdown)하는 방법을 소개합니다."
keywords: []
draft: false
tags: ["os", "vmware"]
math: false
toc: true
---

# 개요
VMware ESXi 호스트 서버를 종료할 수 있다.

<br>

# 배경지식

### ESXi 호스트의 Shutdown
VMware ESXi 호스트 서버의 경우 일반 x86 리눅스 서버처럼 `shutdown -h now` 명령어로 서버를 끌 수 없다.  

`shutdown` 명령어 자체가 존재하지 않기 때문이다.

```shell
# shutdown -h now
-sh: shutdown: not found
```
반면 `reboot` 명령어는 ESXi에서도 존재하고 잘 실행되기 때문에 테스트 차원으로 실행해서는 안되니 주의!

<br>

# 환경
- **OS** : VMware ESXi 5.1.0
- **Shell** : sh (ESXi shell)
- **ID** : root

<br>

# 해결법

호스트 서버의 종료를 위해서 해당 호스트를 유지보수 모드(Maintenance Mode)로 전환한 후, `esxcli` 명령어를 실행해 종료한다.



### 1. root 로그인
```shell
$ login root
Password: <root 패스워드 입력>
The time and date of this login have been sent to the system logs.

VMware offers supported, powerful system administration tools.  Please
see www.vmware.com/go/sysadmintools for details.

The ESXi Shell can be disabled by an administrative user. See the
vSphere Security documentation for more information.

#
```
유저 계정일 경우 `login root` 명령어로 root 로그인을 한다.  
서버 종료(Shutdown)나 서버 재시작(reboot)은 반드시 root 권한에서 진행되어야 한다.



### 2. 구동중인 VM 리스트 확인
```shell
# esxcli vm process list
#
```
결과가 출력되지 않는다면 해당 호스트에서 구동중인 가상머신(VM, Virutal Machine)이 없는 상태이다.  

해당 호스트 위에서 구동중인 가상머신이 있을 경우 vSphere Client를 이용해 미리 다른 호스트로 옮겨놓자.



### 3. 유지보수 모드 확인
```shell
# esxcli system maintenanceMode get
Disabled
```
`Disabled` : 유지보수 모드가 비활성화되어 있음



### 4. 유지보수 모드 활성화
```shell
# esxcli system maintenanceMode set --enable true
```
유지보수 모드 값을 `true`로 설정한다.
유지보수 모드가 설정되면 vSphere Client에서도 호스트 아이콘이 바리게이트가 쳐진 호스트 아이콘으로 변경된다. 
반대로 유지보수 모드를 끄는 방법은 `esxcli system maintenanceMode set --enable false` 를 실행한다.

```shell
# esxcli system maintenanceMode get
Enabled
```
`Enabled` : 유지보수 모드가 활성화되었다.



### 5. 서버 종료

#### 실행 명령어 예시
```shell
# esxcli system shutdown poweroff --reason="Memory replacement."
```

작업사유(`--reason`)에는 반드시 서버 종료조치(shutdown)하는 사유를 상세히 적어준다.  

애초에 작업사유를 입력하지 않으면 명령어가 실행되지 않는다.



#### poweroff 명령어 사용법 확인

```shell
# esxcli system shutdown poweroff
Error: Missing required parameter -r|--reason

Usage: esxcli system shutdown poweroff [cmd options]

Description: 
  poweroff              Power off the system. The host must be in maintenance mode.

Cmd options:
  -d|--delay=<long>     Delay interval in seconds
  -r|--reason=<str>     Reason for performing the operation (required)
```

호스트 서버의 poweroff 실행을 위해서는 작업 사유(`--reason`) 값을 필수적으로 입력해야 서버가 꺼진다.  
사유를 입력하지 않을 경우 작업사유를 입력하라는 에러 메세지가 나오면서, shutdown 명령어가 실행되지 않는다.

````shell
# esxcli system shutdown poweroff
Error: Missing required parameter -r|--reason
[...]
````