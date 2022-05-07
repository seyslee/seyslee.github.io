---
title: "Brocade DS6510에서 Zoning 설정하기"
date: 2021-08-23T01:09:09+09:00
slug: ""
description: "Brocade DS6510 SAN 스위치에서 Zoning 설정하기"
keywords: []
draft: false
tags: ["san", "storage"]
math: false
toc: true
---

# 개요

Brocade 제조사의 SAN Switch 장비에서 Zoning 설정 후 적용할 수 있다.

# 환경

- **Model** : Brocade DS6510
- **Kernel** : 2.6.14.2
- **Fabric OS** : v8.0.2d

# 절차

### 1. 장비 접속

Serial Cable 을 이용한 연결 또는 SSH 기본포트(TCP/22)로 접속한다.



### 2. Alias 생성

Alias 생성 작업은 필수는 아니지만, 관리자 메뉴얼 기준으로 매우 권장되는 절차다.  

사람이 이해하기 쉽게 Zone에 속한 구성 장비들의 이름을 적어놓는 절차이기 때문이다.  

- **Alias :** Switch 의 Port 번호 혹은 WWN 을 알기쉽게 별칭(Alias)으로 지정하여, Zone Member의 확인을 쉽게 합니다.

```bash
> alicreate "WEBWAS1_P2", "21:00:00:24;ff:33:a3:4c"
```



### 3. Zone 생성

```bash
> zonecreate "WEBWAS1_P2_SN87118_S5_P1_V_SN87119_S5_P1_V", "WEBWAS1_P2; SN87118_S5_P1_V; SN87119_S5_P1_V"
```



### 4. cfg 추가

**명령어 형식**

```bash
> cfgadd "<config_name>", "<zone_name>; <zone_name>; ...; <zone_name>"
```

기존에 존재하는 config에 새로 만든 zone을 추가한다. 여기서 `cfg`는 설정(Configuration)을 의미한다.



**명령어 예시**

```bash
> cfgadd "ds6510_top_cfg", "WEBWAS1_P2_SN87118_S5_P1_V_SN87119_S5_P1_V"
```



### 5. 설정 저장

설정을 저장한다.

```bash
> cfgsave
[...]
Do you want to save the Defined zoning configuration only? (yes, y, no, n): [no]
```

`cfgsave` 명령어를 수행하지 않을 경우, 휘발성 영역에 Config가 존재하므로 Switch 리부팅 시 설정한 Zone 정보가 사라지므로 주의한다.



### 6. cfg 적용

```bash
> cfgenable "ds6510_top_cfg"
```