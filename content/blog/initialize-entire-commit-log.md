---
title: "git 커밋로그 전체 삭제"
date: 2022-04-15T22:33:52+09:00
lastmod: 2022-04-15T22:44:52+09:00
slug: ""
description: "중요정보나 파일이 Public 레포지터리에 노출된 상황일 때, 커밋로그를 전체를 삭제(초기화)하는 방법"
keywords: []
draft: false
tags: ["github", "dev"]
math: false
toc: true
---

# 개요
특정 레포지터리의 전체 커밋로그를 삭제(초기화)하는 방법을 설명한다.  

내 Public Repository에 크리티컬한 보안 이슈를 일으킬만한 이미지 파일이나 인증 정보 등이 노출되었을 경우 이 방법을 쓰자.

<br>

# 원리
전체 커밋로그 삭제(초기화) 원리는 간단하다.  

1. `main` 브랜치를 복제해서 `latest_branch` 브랜치를 만든다.
2. `main` 브렌치를 삭제한다.
3. `main` 브랜치가 삭제될 때 그 안에 포함된 Commit log 전체도 같이 삭제된다.
4. `latest_branch`의 이름을 `main`으로 변경한다. 끝.

<br>

**주의사항**  
<u>이 방법을 쓸 경우, 지금까지의 main 브랜치의 전체 커밋 로그(히스토리)가 사라진다.</u>  
삭제된 커밋로그는 복구할 방법이 없다는 사실을 명심한다.

<br>

# 해결법

**Checkout**
```bash
# [>] main
$ git checkout --orphan latest_branch
```
`checkout`은 새로운 브랜치를 만드는 명령어이다.  
`latest_branch`라는 이름의 브랜치를 생성한다.  

<br>

**전체 파일 Add**
```bash
# [ ] main
# [>] latest_branch
$ git add -A
```
`-A`는 전체 파일을 추가하는 옵션이다.  
전체 파일을 새로 만든 `latest_branch에 추가한다.

<br>

```bash
# [ ] main
# [>] latest_branch
$ git commit -am "Initial commit"
```
전체 파일을 그대로 새로 만든 브랜치 `latest_branch`에 Commit 한다.

<br>

**브랜치 삭제**
```bash
# [X] main
# [>] latest_branch
$ git branch -D main
```
기존 `main` 브랜치를 삭제한다. `main` 브랜치를 없애는 이유는 핵심 목적인 Commit Log 전체를 삭제하기 위해서이다.

<br>

**현재 브랜치 이름을 main으로 변경**

```bash
# [>] latest_branch --> main
$ git branch -m main
```
`-m`은 브랜치의 이름을 변경하는 옵션이다.

<br>

**강제 업데이트**
```bash
# [>] main
$ git push -f origin main
```
마지막으로 커밋한 전체 파일을 강제로 `main` 브랜치에 올린다.

<br>

**결과확인**
```bash
$ git log --graph
* commit c2af2fd2490bd4bdaeea9daaa5193deb2927a7d1 (HEAD -> main, origin/main, origin/HEAD)
| Author: seyslee <ivecloudblack@gmail.com>
| Date:   Fri Apr 15 22:09:51 2022 +0900
|
|     rebuilding site 2022년 4월 15일 금요일 22시 09분 51초 KST
|
* commit 265451476ff6acb4e9998940f8c90acbf03225cf
| Author: seyslee <ivecloudblack@gmail.com>
| Date:   Fri Apr 15 22:08:28 2022 +0900
|
|     rebuilding site 2022년 4월 15일 금요일 22시 08분 28초 KST
|
* commit 9dc438a22eddd7a6074170a0201bba0fa632c107
  Author: seyslee <ivecloudblack@gmail.com>
  Date:   Fri Apr 15 22:03:35 2022 +0900

      Initial commit
```

`--graph` 옵션은 커밋 로그 전체를 트리 형태로 그려준다.  
지금까지의 전체 커밋로그가 사라졌다. 이제 중요 정보가 노출된 커밋로그는 이 세상에서 사라졌다.  

조치 끝!

<br>

# 결론

`rm -rf .git` 명령어로 `.git` 디렉토리를 지우는 건 권장하지 않는다.  
서브모듈 설정 등도 `.git` 안에 모두 포함되어 있는데, 이것들 다시 설정 잡는 것도 번거롭고 전체 레포지터리 설정을 날리는게 위험하기도 하니까.  

애초에 작업 목적을 잘 생각해보면 우리는 레포지터리의 커밋 로그 전체를 날리고 싶었던 것이다.  
main 브랜치를 그대로 다른 브랜치에 복제 떠서 백업한 후 main 브랜치 자체를 날리는게 훨씬 간단하고 안전하다. 브랜치가 삭제될 때 그 안의 모든 커밋 로그도 같이 삭제되니까.