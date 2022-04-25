---
title: "macOS xcrun: error 해결법"
date: 2021-10-27T01:13:09+09:00
lastmod: 2021-10-27T01:21:05+09:00
slug: ""
description: "macOS 업데이트 이후 git 명령어 실행시 발생하는 xcrun: error의 해결법을 소개합니다."
keywords: []
draft: false
tags: ["dev"]
math: false
toc: true
---



# 환경

- **Model** : MacBook Pro (13inch, M1, 2020)

- **OS** : macOS Monterey 12.0.1

  ```bash
  $ sw_vers
  ProductName:	macOS
  ProductVersion:	12.0.1
  BuildVersion:	21A559
  ```

- **Shell** : zsh

- **터미널** : macOS 기본 터미널

<br>



# 증상

macOS Catalina 11.6에서 macOS Monterey 12.0.1로 소프트웨어 업데이트를 한 이후부터 `git` 명령어를 실행하면 에러 메세지가 반환되며 실행할 수 없다.

```bash
$ git commit -m 'rebuilding site 2021년 10월 27일 수요일 00시 34분 04초 KST'

xcrun: error: invalid active developer path (/Library/Developer/CommandLineTools), missing xcrun at: /Library/Developer/CommandLineTools/usr/bin/xcrun
```

`git commit` 명령어 뿐만 아니라 `git push` 또한 동일한 에러 메세지이다.

```bash
$ git push origin master

xcrun: error: invalid active developer path (/Library/Developer/CommandLineTools), missing xcrun at: /Library/Developer/CommandLineTools/usr/bin/xcrun
```

<br>

# 원인

macOS에서 OS 업데이트가 진행될때마다 자주 발생되는 xcode cli 관련 호환성 이슈이다.

대표적인 개발툴인 git, make, gcc가 영향을 받는다.

<br>

# 해결법

### 1. Xcode CLI 설치

Xcode CLI만 따로 설치해서 문제를 해결할 수 있다.

```bash
$ xcode-select --install
xcode-select: note: install requested for command line developer tools
```

이후 GUI 환경에서 [설치] 버튼을 눌러 명령어 라인 개발자 도구(Command line developer tools)를 설치하면 된다.

설치후에 이전에 안됐던 명령어가 잘 실행되는 지 테스트해본다.



### 2. Xcode CLI 초기화

Xcode CLI를 설치해도 증상이 동일하다고 하면 xcode CLI를 초기화한다. 초기화시에는 root 권한이 필요하다.

```bash
$ sudo xcode-select --reset
Password: [패스워드 입력]
```



### 3. git 명령어 테스트

```bash
$ git commit -m 'rebuilding site 2021년 10월 27일 수요일 00시 45분 23초 KST'
[...]
 2 files changed, 28 insertions(+), 3 deletions(-)
```

```bash
$ git push origin master
Enumerating objects: 9, done.
Counting objects: 100% (9/9), done.
Delta compression using up to 8 threads
Compressing objects: 100% (5/5), done.
Writing objects: 100% (5/5), 1.33 KiB | 1.33 MiB/s, done.
[...]
   5936bbc..902284d  master -> master
```

Xcode CLI를 설치완료 후 에러 메세지 없이 `git` 명령어가 실행된다.
