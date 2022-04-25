---
title: "lshw 패키지로 리눅스 하드웨어 정보 확인"
date: 2021-11-12T22:56:10+09:00
lastmod: 2021-11-12T23:06:40+09:00
slug: ""
description: "리눅스 서버에 lshw 패키지를 설치한 후 명령어로 하드웨어 정보를 확인하는 방법을 설명합니다."
keywords: []
draft: false
tags: ["os", "linux", "hardware"]
math: false
toc: true
---


# 개요
리눅스 서버에 `lshw`(list hardware) 패키지를 설치해 서버 모델, CPU, Memory 등의 하드웨어 정보를 원격으로 수집할 수 있다.
시스템 관리 유틸리티 패키지들을 적절한 상황에 활용하면 효율적인 시스템 관리가 가능하다.
<br>



# 환경
- **OS** : Red Hat Enterprise Linux Server release 6.x
- **Architecture** : x86_64
- **패키지 관리자** : rpm (Red hat Package Manager)
- **설치 패키지**
  - lshw B.02.17 (`lshw-2.17-1.el6.rf.x86_64.rpm`)  
  <br>


# 본론
## 패키지 설치
### 1. 설치전 정보 확인
```bash
$ arch
x86_64
```
해당 서버의 아키텍쳐는 Intel CPU 기반 64bit 아키텍쳐(`x86_64`)이다.  
<br>

### 2. 패키지 설치
```bash
$ ls -lh
합계 1.7M
-rw-rw-r-- 1 dev dev 1.7M 2021-11-12 08:35 lshw-2.17-1.el6.rf.x86_64.rpm
```
정보를 수집할 대상 서버의 아키텍쳐와 운영체제 버전에 맞는 lshw 패키지 설치파일을 업로드 해놓는다.  
패키지 설치파일은 반드시 검증된 패키지 저장소에서 받아야 한다.  
<br>

```bash
$ rpm -ivh lshw-2.17-1.el6.rf.x86_64.rpm 
경고: lshw-2.17-1.el6.rf.x86_64.rpm: Header V3 DSA/SHA1 Signature, key ID 6b8d79e6: NOKEY
준비 중...                  ########################################### [100%]
   1:lshw                   ########################################### [100%]
```
`lshw` 패키지가 설치 완료됐다.  
<br>


### 3. 설치결과 확인
```bash
$ rpm -qa lshw
lshw-2.17-1.el6.rf.x86_64
```
`lshw` 패키지가 RPM(Redhat Package Manaer)에서 조회된다. 설치된 패키지의 버전은 `2.17.1` 이다.  
<br>


```bash
$ lshw -version
B.02.17
the latest version is B.02.18
```

버전 출력으로 명령어 동작을 테스트한다.  
<br>



## 조작법
### 1. 상세정보 출력

아무 옵션 없이 `lshw` 명령어를 실행하면 모든 하드웨어의 상세 정보를 출력한다.  
```bash
$ lshw
dev-server1                 
    description: Expansion Chassis
    product: UCSC-C220-M3S
    vendor: Cisco Systems Inc
    version: A
    serial: XXX1704X1X0
    width: 64 bits
    capabilities: smbios-2.7 dmi-2.7 vsyscall64 vsyscall32
    configuration: boot=normal chassis=expansion frontpanel_password=enabled keyboard_password=disabled power-on_password=di
sabled uuid=31CB0CAD-EB83-4327-8599-83C27AD698A8
  *-core
       description: Motherboard
       product: UCSC-C220-M3S
       vendor: Cisco Systems Inc
       physical id: 0
       version: 74-10442-01
       serial: XXX1703XXX7
     *-firmware
          description: BIOS
```
<br>


### 2. 요약정보 출력
`-short` 옵션을 붙이면 전체 하드웨어의 요약정보를 출력한다.
```bash
$ lshw -short
H/W path                Device    Class      Description
========================================================
                                  system     UCSC-C220-M3S
/0                                bus        UCSC-C220-M3S
/0/0                              memory     64KiB BIOS
/0/1                              memory     
/0/1/0                            memory     8GiB DIMM DDR3 1600 MHz (0.6 ns)
/0/2                              memory     
/0/2/0                            memory     DIMM Synchronous [empty]
/0/3                              memory     
[...]
/0/13.1                           generic    Sandy Bridge Ring to PCI Express Performance Monitor
/0/13.4                           generic    Sandy Bridge QuickPath Interconnect Agent Ring Registers
/0/13.5                           generic    Sandy Bridge Ring to QuickPath Interconnect Link 0 Performance Monitor
/0/13.6                           generic    Sandy Bridge Ring to QuickPath Interconnect Link 1 Performance Monitor
```
<br>


### 3. 특정 파트 확인
클래스는 하드웨어의 특정 카테고리(Part)를 의미한다. 클래스에는 `system`, `cpu`, `memory`, `disk`, `volume`, `storage` 등이 있다.  
`-c` 또는 `-class` 옵션을 붙이면 특정 하드웨어 파트(클래스)의 정보만 출력한다.  
어떤 클래스들이 존재하는지 궁금하다면 `lshw -short` 명령어 결과의 Class 컬럼을 참조하자. 

```bash
$ lshw -c system
dev-server1                 
    description: Expansion Chassis
    product: UCSC-C220-M3S
    vendor: Cisco Systems Inc
    version: A
    serial: XXX0000X0X0
    width: 64 bits
    capabilities: smbios-2.7 dmi-2.7 vsyscall64 vsyscall32
    configuration: boot=normal chassis=expansion frontpanel_password=enabled keyboard_password=disabled power-on_password=disabled uuid=31CB0CAD-EB83-4327-8599-83C27AD698A8
```
서버 모델명(`product`), 제조사(`vendor`), 고유번호(`serial`)를 확인할 수 있다.  
<br>

```bash
$ lshw -c cpu
  *-cpu:0                 
       description: CPU
       product: Xeon
       vendor: Intel Corp.
       physical id: 32
       bus info: cpu@0
       version: Intel(R) Xeon(R) CPU E5-2667 0 @ 2.90GHz
       slot: CPU1
       size: 1200MHz
       capacity: 4GHz
       width: 64 bits
       clock: 100MHz
       capabilities: x86-64 fpu fpu_exception wp vme de pse tsc msr pae mce cx8 apic mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 x2apic popcnt aes xsave avx lahf_lm ida arat epb xsaveopt pln pts tpr_shadow vnmi flexpriority ept vpid cpufreq
       configuration: cores=6 enabledcores=6 threads=12
  *-cpu:1 DISABLED
       description: CPU [empty]
       physical id: 33
       slot: CPU2
```

CPU와 관련된 상세정보를 확인할 수 있다.  
<br>

**확인 가능한 정보**
- CPU 소켓 수(`cpu:0`, `cpu:1`)
- CPU 아키텍쳐(`x86-64`)
- CPU 모델명(`version`)
- 코어 수(`cores=6`)
- 스레드 수(`threads=12`)  
<br>

```bash
$ lshw -c memory
  *-firmware              
       description: BIOS
       vendor: Cisco Systems, Inc.
       physical id: 0
       version: C220M3.1.4.7b.0.100520120256
       date: 10/05/2012
       size: 64KiB
       capacity: 4032KiB
       capabilities: pci upgrade shadowing cdboot bootselect socketedrom edd int13floppy1200 int13floppy720 int13floppy2880 int5printscreen int9keyboard int14serial int17printer acpi usb biosbootspecification uefi
  *-memory:0 UNCLAIMED
       physical id: 1
     *-bank UNCLAIMED
          description: DIMM DDR3 1600 MHz (0.6 ns)
          product: M393B1K70DH0-YK0
          vendor: Samsung
          physical id: 0
          serial: 3592XX2X
          slot: DIMM_A1
          size: 8GiB
          width: 64 bits
          clock: 1600MHz (0.6ns)
  *-memory:1 UNCLAIMED
       physical id: 2
     *-bank UNCLAIMED
          description: DIMM Synchronous [empty]
          product: NO DIMM
          vendor: NO DIMM
          physical id: 0
          serial: NO DIMM
          slot: DIMM_A2
```
Memory Bank 의 전체 개수, 사용중인 개수, 메모리 용량, 동작클럭, 메모리 모델명, 메모리 고유번호(`serial`)까지 확인할 수 있다.  
<br>

### 4. HTML 파일로 보기
CLI 환경에서 보는게 불편한 엔지니어라면 하드웨어 정보를 HTML 파일로 저장해 웹브라우저에서 보는 방법도 있다.  

```bash
$ lshw -html >> /tmp/lshw.html
```

CLI가 더 편한 엔지니어라면 저장된 html 파일을 SFTP 등을 이용해 웹 브라우저가 실행되는 환경으로 옮겨서 실행해야하는 게 번거롭기 때문에 굳이 이 방법을 쓸 필요가 있나 의구심이 든다.  
<br>


# 결론
이 글에서 소개하는 `lshw` 패키지는 하드웨어 정보를 확인하는 다양한 방법 중 한 가지일 뿐이다. `lshw` 말고도 다양한 기능을 가진 패키지들이 널려있다.  
시스템 관리에는 정답이 없기 때문에 엔지니어 각자가 잘 알고 익숙한 방법으로 하드웨어 정보를 수집하면 된다.  