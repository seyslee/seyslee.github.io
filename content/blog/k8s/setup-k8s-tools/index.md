---
title: "필수 쿠버네티스 관리 툴"
date: 2022-03-21T23:34:40+09:00
lastmod: 2022-03-26T01:01:40+09:00
slug: ""
description: "쿠버네티스를 쉽고 효율적으로 관리하기 위해 k9s, kubecolor 등의 유틸리티 툴을 설치하고 사용하는 방법을 안내합니다."
keywords: []
draft: false
tags: ["dev", "kubernetes"]
math: false
toc: true
---

# 개요
멀티 클러스터 기반의 쿠버네티스를 관리할 때 생산성<sup>Productivity</sup>을 높여주는 플러그인들을 설치하고 사용하는 방법을 안내하는 문서이다.

<br>

# 환경
- **OS** : macOS Monterey 12.3 (M1 Pro)
- **Shell** : zsh + oh-my-zsh
- **Terminal** : iTerm 2
- **mac용 패키지 관리자** : Homebrew 3.4.3

<br>

# 전제조건
**brew**  
macOS 패키지 관리자인 brew가 이미 설치된 환경.

<br>

# 플러그인 목록
### 1. k9s
#### 설명
쿠버네티스 전체 관리 툴. 알록달록한 컬러 표시, 표시된 정보가 실시간으로 바뀌는 Interactive 기능, TUI<sup>Terminal User Interface</sup> 기반이라 `kubectl` 명령어 입력 없이 방향키와 단축키만으로 클러스터와 관련된 모든 작업이 가능해진다.

#### 설치방법
homebrew로 설치한다.
```bash
$ brew install k9s
```

#### 사용법 예시
쿠버네티스 클러스터에 접근 가능한 환경에서 아래 명령어를 실행하면 k9s 관리 창이 뜬다.
```bash
$ k9s
```  
![](./1.png)  
위 스크린샷은 k9s에서 전체 파드를 보고 있는 화면이다.  

자세한 k9s 조작법은 [k9s 깃허브 레포지터리](https://github.com/derailed/k9s)를 참고한다.

<br>

### 2. kubecolor
#### 설명
가독성 향상 플러그인. kubectl 명령어 결과의 각 컬럼에 색깔을 표시해서 출력해준다. kubectl 명령어 결과값에 가독성을 높여줌.  

2022년 3월 기준으로, 만든 사람이 플러그인 업데이트를 잘 안하고 있는 것으로 확인됨.

#### 설치방법
homebrew로 설치한다.
```bash
$ brew install kubecolor
```

#### 사용법 예시
```bash
$ kubecolor get pod
```
  
`kubectl` 명령어에 컬러 표시를 항상 적용하고 싶다면, 쉘 설정파일 안에 alias 설정을 추가하면 더 편하게 사용 가능하다. 아래는 zsh 기준의 설정방법.
```bash
$ vi ~/.zshrc
...
# kubecolor
alias kubectl=kubecolor
...
```
<br>

### 3. krew
#### 설명
패키지 관리자. krew는 kubectl 플러그인 패키지 매니저이다. 쿠버네티스 전용 homebrew라고 이해하면 된다.

#### 설치방법
homebrew로 설치한다.
```bash
$ brew install krew
```

#### 사용법 예시
```bash
$ kubectl krew list
PLUGIN          VERSION
ctx             v0.9.4
krew            v0.4.3
ns              v0.9.4
tree            v0.4.1
```
krew로 설치한 플러그인 목록을 출력하는 명령어이다.

```
$ kubectl krew update
```
krew로 설치한 플러그인 전체의 최신 버전을 확인하는 명령어.


<br>

### 4. stern
#### 설명
여러 대의 파드, 컨테이너 동시 모니터링 가능. stern과 비슷한 기능을 하는 플러그인으로는 kail이 있다.

#### 설치방법
homebrew로 설치한다.
```bash
$ brew install stern
```

#### 사용법
```bash
$ stern -n prometheus sample-prom-pod
```
`-n` : 네임스페이스 지정  
`sample-prom-pod` : (예시) 파드 이름에 `sample-prom-pod`가 포함된 파드들의 로그만 실시간 모니터링<sup>tail</sup>한다.

<br>

### 5. tree
#### 설명
kubernetes 리소스 간의 관계를 트리형태로 쉽게 표현해준다.

#### 설치방법
krew로 설치한다.
```bash
$ kubectl krew install tree
```

#### 사용법 예시
```bash
$ kubectl tree deploy sample-redis
NAMESPACE  NAME                                    READY  REASON  AGE
sample     Deployment/sample-redis                 -              138d
sample     ├─ReplicaSet/sample-redis-000df0b0    -              138d
sample     ├─ReplicaSet/sample-redis-x00x0c000   -              125d
sample     └─ReplicaSet/sample-redis-xx0b00xxc   -              67d
sample       └─Pod/sample-redis-xx5x00xxc-zqbrk  True           2d12h
```
특정 Deployment에 속한 ReplicaSet과 Pod 정보를 트리 형태로 표현해준다.

<br>

### 6. kubectx & kubens
쿠버네티스의 컨텍스트를 여러개 사용하고 있거나, 네임스페이스를 여러개 사용하고 있을 때 필요한 플러그인들이다. 몇 글자 안되는 짧은 명령어로 클러스터 간의 이동, 네임스페이스 간의 이동이 가능하므로 멀티 클러스터 환경을 관리하는 엔지니어라면 반드시 사용하는 걸 추천한다.  

#### 설명
kubectx는 컨텍스트를 쉽게 변경할 수 있도록 도움을 준다. `kubectl config use-context dev-cluster` 같은 긴 명령어를 사용하지 않아도 된다. 

kubens는 기본 네임스페이스를 변경할 수 있도록 도와준다. 이 두 도구 모드 [Tab] 완성기능을 지원한다. 그 뿐만 아니라, fzf<sup>fuzzy finder</sup>를 설치하면 대화식 메뉴를 제공하기 때문에, 더 편하게 사용할 수 있다.

#### 설치방법
krew로 설치한다.
```bash
$ kubectl krew install kubectx
$ kubectl krew install kubens
```
설치 후 툴은 `kubectl ctx` 및 `kubectl ns` 명령어로 사용할 수 있다.  
`kubectl` 명령어가 `k`로 alias 설정되어 있다면 `k ctx`, `k ns`로 더 축약해서 사용 가능하다.  

#### 사용법 예시

fzf 플러그인이 같이 설치되어 있는 상태에서 실행하면, 아래처럼 방향키를 통해 이동해서 선택 가능한 대화식 메뉴로 동작한다.
```bash
$ kubectl ctx
> docker-desktop
  dev-cluster
  qa-cluster
  prod-cluster
  4/4
```

```bash
$ kubectl ns
  default
  redis
> prometheus
  grafana
  nginx
  5/5
```

<br>

### 7. kubectl 자동완성
#### 설명
kubectl 자동완성은 플러그인은 아니고, kubectl에서 기본 지원하는 기능으로 추가 설치는 필요없다.

#### 설정방법
아래는 kubectl 자동완성 기능 설정 방법이다. (zsh 기준)
```bash
$ vi ~/.zshrc
...
# kubectl autocompletion
source <(kubectl completion zsh)
...
```

zsh 시작 시 `kubectl`의 자동완성 기능을 기본 활성화한다.

```bash
$ source ~/.zshrc
```
변경한 설정내용을 바로 적용한다.

이제 kubectl 명령어 입력 후 [tab] 키를 눌러본다.
```
$ kubectl [tab]
```

[tab] 키를 누르면 아래와 같이 `kubectl` 명령어 다음에 올 수 있는 하위 명령어 리스트가 출력된다. 이 상태에서 [tab] 키를 한 번 더 누르면 대화형 메뉴처럼 방향키와 엔터로 선택 가능하다.
```
$ kubectl
alpha          -- Commands for features in alpha
annotate       -- 자원에 대한 주석을 업데이트합니다
api-resources  -- Print the supported API resources on the server
api-versions   -- Print the supported API versions on the server, in the form of "group/version"
apply          -- Apply a configuration to a resource by file name or stdin
attach         -- Attach to a running container
...
```

#### 참고사항
내 경우는 kubecolor랑 kubectl 자동완성<sup>autocomplete</sup>을 동시에 사용하면 버그가 발생했다. 따라서 두 기능을 같이 사용하는 것은 권장하지 않는다.  

현재 이 이슈는 3월 28일 기준으로 아직 해결되지 않은 상태이다. 해당 깃허브 이슈는 [autocompletion bug #78](https://github.com/hidetatz/kubecolor/issues/78)에 등록되어 있다.

<br>

# P.S.
유용한 쿠버네티스 플러그인을 추가로 발견할 때마다 글을 업데이트하고 있습니다.  
이 외에 공유하고 싶은 쿠버네티스 플러그인이 있다면 언제든 댓글로 남겨주세요.  