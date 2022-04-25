---
title: "도커 파일시스템 정리"
date: 2022-03-16T13:07:20+09:00
lastmod: 2022-03-16T13:07:10+09:00
slug: ""
description: "쿠버네티스 워커 노드가 파일시스템 사용률이 높을 때, docker system prune 명령어를 실행해서 Docker 오브젝트를 정리하여 파일시스템 공간을 확보할 수 있다."
keywords: []
draft: false
tags: ["os", "linux", "docker"]
math: false
toc: true
---

# 개요
쿠버네티스 워커 노드가 파일시스템 사용률이 높을 때, `docker system prune` 명령어를 실행해서 Docker 오브젝트를 정리하여 파일시스템 공간을 확보할 수 있다.

<br>

# 환경
- **OS** : Amazon Linux 2
- **Shell** : bash
- **ID** : ec2-user

<br>

# 해결방법
```bash
$ id
uid=1000(ec2-user) gid=1000(ec2-user) groups=1000(ec2-user),4(adm),10(wheel),190(systemd-journal),1950(docker)
```
EC2 Instance에 ec2-user로 로그인한다.

<br>

파일시스템 사용률을 확인한다.
```bash
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        7.7G     0  7.7G   0% /dev
tmpfs           7.7G     0  7.7G   0% /dev/shm
tmpfs           7.7G  1.4M  7.7G   1% /run
tmpfs           7.7G     0  7.7G   0% /sys/fs/cgroup
/dev/nvme0n1p1  100G   81G   20G  81% /
tmpfs           1.6G     0  1.6G   0% /run/user/0
```
100GB EBS<sup>Elastic Block Storage</sup>가 붙어있는 노드이다. root 파일시스템(`/`)의 사용률이 `81%`로 높다.

<br>

도커에서 사용중인 파일 시스템 현황을 확인한다. 정리하여 확보할 수 있는 공간(`RECLAIMABLE`)이 꽤 많다.
```bash
$ docker system df
TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
Images              107                 20                  67.56GB             59.56GB (88%)
Containers          46                  21                  2.952GB             2.763GB (93%)
Local Volumes       16                  10                  4.433MB             230.9kB (5%)
Build Cache         0                   0                   0B                  0B
```

<br>

사용하지 않는 모든 Docker object들을 정리한다.
```bash
$ docker system prune -af
```
**명령어 옵션 설명**  
`-a` : Dangling 이미지 말고도 사용하지 않는 컨테이너 이미지들을 모두 삭제  
`-f` : 실행할 것인지에 대한 여부를 묻지 않고 바로 실행한다.

<br>

```bash
$ docker system prune -af
Deleted Containers:
b2da4de9da8e92a0000068846aec0000e7f4b82df4dde011408cac40499a4769
a1d989685169fb1eb0000000ab00000f041c77e0cbea0155e5da24a494bb86f4
....

Total reclaimed space: 63.92GB
```
사용하지 않는 Docker 오브젝트 일괄 삭제한 결과, 63.92GB 공간을 확보했다.

<br>

정리 후 파일시스템 사용률을 다시 확인해보니, 81% → 11% 로 크게 떨어졌다.
```bash
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        7.7G     0  7.7G   0% /dev
tmpfs           7.7G     0  7.7G   0% /dev/shm
tmpfs           7.7G  1.4M  7.7G   1% /run
tmpfs           7.7G     0  7.7G   0% /sys/fs/cgroup
/dev/nvme0n1p1  100G   11G   90G  11% /
tmpfs           1.6G     0  1.6G   0% /run/user/0
```

```bash
$ docker system df
TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
Images              16                  16                  6.589GB             590.3MB (8%)
Containers          30                  21                  273.7MB             2B (0%)
Local Volumes       19                  7                   4.435MB             622.6kB (14%)
Build Cache         0                   0                   0B                  0B
```

<br>

# 결론

서버의 주기적인 파일시스템 정리는 인프라 관리의 핵심 업무 중 하나이니 잘 알아두고 실무에 써먹자.  

파일시스템 정리와 같은 업무는 반복적이고 단순하기 때문에 자동화하기 좋은 사례이다. OS에서 cron 설정을 걸거나, AWS 서비스를 이용해 이제 자동화를 고민해보자.

만약 OS 영역에서 cron을 활용해 자동화를 하고 싶다면, [이 글](https://alexgallacher.com/prune-unused-docker-images-automatically/)을 참고하면 좋다.

<br>

# 참고자료
Docker의 prune 사용법: 사용하지 않는 Docker 오브젝트 일괄 삭제 [[링크](https://www.lainyzine.com/ko/article/docker-prune-usage-remove-unused-docker-objects/)]