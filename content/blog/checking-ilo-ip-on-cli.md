---
title: "ipmitool 명령어로 HP iLO IP 확인"
date: 2021-10-13T23:34:15+09:00
slug: ""
description: "CLI 환경에서 iLO IP를 확인하는 방법"
keywords: []
draft: false
tags: ["os", "linux", "hardware"]
math: false
toc: true
---

# 개요

CLI 환경에서 `ipmitool` 명령어로 HP iLO IP 주소를 확인할 수 있다.  

OS에 `ipmitool` 패키지만 설치되어 있다면 iLO IP를 원격으로도 확인 가능하다. 즉, 번거롭게 데이터센터에 들어갈 필요 없다.

<br>

# 환경

- **Vendor** : HP
- **Model** : ProLiant DL380 Gen9
- **OS** : Red Hat Enterprise Linux Server release 6.5 (Santiago)
- **Shell** : bash
- **Package** : ipmitool-1.8.11

<br>

# 배경지식

### IPMI (Intelligent Platform Management Interface)

서버 관리를 위한 관리 인터페이스로 원격지나 로컬서버의 상태를 파악하고 제어할 수 있는 기능을 제공한다. 따라서 많은 수의 서버를 관리하는 경우에 아주 유용하게 사용이 될 수 있다.  
요즘 나오는 대부분의 서버용 메인보드에서는 지원하는 기능이다.

<br>

# 해결법

### 1. ipmi 패키지 확인

```bash
$ rpm -qa | grep ipmitool
ipmitool-1.8.11-16.el6.x86_64
```

ipmitool 1.8.11 버전의 패키지가 설치되어 있다.

<br>

### 2. ipmi 서비스 시작

```bash
$ service ipmi start
Starting ipmi drivers: [  OK  ]
```

ipmi 서비스를 시작한다.

<br>

### 3. iLO IP 확인

```bash
$ ipmitool lan print
Set in Progress         : Set Complete
Auth Type Support       : 
Auth Type Enable        : Callback : 
                        : User     : 
                        : Operator : 
                        : Admin    : 
                        : OEM      : 
IP Address Source       : Static Address
IP Address              : 192.168.0.120
Subnet Mask             : 255.255.255.0
MAC Address             : 98:f2:b3:3b:fa:3e
SNMP Community String   : 
BMC ARP Control         : ARP Responses Enabled, Gratuitous ARP Disabled
Default Gateway IP      : 0.0.0.0
802.1q VLAN ID          : Disabled
802.1q VLAN Priority    : 0
RMCP+ Cipher Suites     : 0,1,2,3
Cipher Suite Priv Max   : XuuaXXXXXXXXXXX
                        :     X=Cipher Suite Unused
                        :     c=CALLBACK
                        :     u=USER
                        :     o=OPERATOR
                        :     a=ADMIN
                        :     O=OEM
```

서버 하드웨어 제조사가 HP일 경우, `ipmitool lan print` 명령어 결과에 나오는 `IP Address` 는 iLO IP와 동일한 의미이다.  

ipmi 서비스가 실행되어 있지 않을 경우, 제대로 결과를 반환하지 않으므로 결과가 잘 보이지 않는다면 ipmi 서비스 기동 상태를 확인한다.

<br>

### 4. iLO IP 설정

```bash
## (1) 고정(Static) IP 설정
$ ipmitool lan set 1 ipsrc static

## (2) IP 설정
$ ipmitool lan set 1 ipaddr 10.10.10.10

## (3) Subnet Mask 설정
$ ipmitool lan set 1 netmask 255.255.255.0

## (4) Default Gateway IP 설정
$ ipmitool lan set 1 defgw ipaddr 10.10.10.1
```

서버 하드웨어 환경에 따라 channel 번호는 반드시 `1`이 아닌 다른 수일수도 있으므로 주의하자. 

<br>

**ipmitool lan set 명령어 형식**

`ipmitool lan set` 명령어만 치면 설정 관련 명령어 전체 메뉴얼이 나오므로 참고할 수 있다.

```bash
$ ipmitool lan set

usage: lan set <channel> <command> <parameter>

LAN set command/parameter options:
  ipaddr <x.x.x.x>               Set channel IP address
  netmask <x.x.x.x>              Set channel IP netmask
  macaddr <x:x:x:x:x:x>          Set channel MAC address
  defgw ipaddr <x.x.x.x>         Set default gateway IP address
  defgw macaddr <x:x:x:x:x:x>    Set default gateway MAC address
  bakgw ipaddr <x.x.x.x>         Set backup gateway IP address
  bakgw macaddr <x:x:x:x:x:x>    Set backup gateway MAC address
  password <password>            Set session password for this channel
  snmp <community string>        Set SNMP public community string
  user                           Enable default user for this channel
  access <on|off>                Enable or disable access to this channel
  alert <on|off>                 Enable or disable PEF alerting for this channel
  arp respond <on|off>           Enable or disable BMC ARP responding
  arp generate <on|off>          Enable or disable BMC gratuitous ARP generation
  arp interval <seconds>         Set gratuitous ARP generation interval
  vlan id <off|<id>>             Disable or enable VLAN and set ID (1-4094)
  vlan priority <priority>       Set vlan priority (0-7)
  auth <level> <type,..>         Set channel authentication types
    level  = CALLBACK, USER, OPERATOR, ADMIN
    type   = NONE, MD2, MD5, PASSWORD, OEM
  ipsrc <source>                 Set IP Address source
    none   = unspecified source
    static = address manually configured to be static
    dhcp   = address obtained by BMC running DHCP
    bios   = address loaded by BIOS or system software
  cipher_privs XXXXXXXXXXXXXXX   Set RMCP+ cipher suite privilege levels
    X = Cipher Suite Unused
    c = CALLBACK
    u = USER
    o = OPERATOR
    a = ADMIN
    O = OEM
```

<br>

### 5. iLO 설정 변경사항 적용

```bash
$ ipmitool mc reset cold
```

IP 설정 적용을 위해 BMC<sup>Baseboard Management Controller</sup>를 리부팅해준다.

<br>

**BMC<sup>Baseboard Management Controller</sup>**  
IPMI<sup>Intelligent Platform Management Interface</sup> 유틸리티의 핵심 하드웨어 칩으로, 관리자들이 서버와 데스크톱에 대한 원격으로 긴급 모니터링하는데 활용한다.  
BMC 칩의 핵심기능은 CPU, Fan, 전원부(Power Supply), VGA<sup>Video Graphic Array</sup> 카드 등 각 하드웨어 부품(Component)에 설치된 센서들과 통신을 통해 상태를 모니터링하고, 발생하는 이벤트를 기록하며 원격으로 복구, 제어 등의 기능을 수행할 수도 있다.

이것으로 설정작업은 끝난다.