---
title: "쿠버네티스 cordon, drain"
date: 2021-11-14T15:26:40+09:00
lastmod: 2021-11-14T16:15:40+09:00
slug: ""
description: "쿠버네티스 노드의 pod 스케줄링을 제어하는 명령어인 cordon, drain, uncordon에 대해 자세히 알아본다."
keywords: []
draft: false
tags: ["devops", "kubernetes"]
math: false
toc: true
---

# 개요

![](./1.jpg)

`cordon`, `uncordon`, `drain` 명령어를 통해 쿠버네티스 클러스터를 구성하는 노드의 파드 스케줄링을 제어할 수 있다. 주로 노드의 패치 작업이나 하드웨어 유지보수 작업 시에 파드 스케줄링을 사용한다.

<br>

# 환경

- **Hardware** : MacBook Pro (13", M1, 2020)
- **OS** : macOS Monterey 12.0.1
- **Docker Desktop 4.1.1** (쿠버네티스 기능 활성화됨)
- **minikube v.1.24.0** (Homebrew로 설치)
  * **멀티노드 구성** : 1대의 마스터 노드(Control Plane) + 3대의 워커 노드


<br>



# 본론

## cordon

`kubectl cordon`은 지정한 노드에 이미 배포된 Pod는 그대로 유지하면서 이후 추가적인 Pod 스케줄링에서 제외하는 명령어이다.  

cordon 설정된 시점 이후부터 해당 노드에는 추가로 pod가 배포되지 않는다.  

<br>



### 설정방법

```bash
$ kubectl cordon <노드 이름>
```

<br>



### 예제

#### 노드 확인

```bash
$ kubectl get no
NAME        STATUS                     ROLES                  AGE     VERSION
mnlab       Ready,SchedulingDisabled   control-plane,master   2d16h   v1.22.3
mnlab-m02   Ready                      <none>                 43s     v1.22.3
mnlab-m03   Ready                      <none>                 29s     v1.22.3
mnlab-m04   Ready                      <none>                 16s     v1.22.3
```
현재 시나리오에는 클러스터 노드 4대(Master node 1 + Worker node 3)가 존재한다.

<br>



#### cordon 설정

`mnlab-m04` 노드에 cordon을 설정했다.

```bash
$ kubectl cordon mnlab-m04
node/mnlab-m04 cordoned
```

<br>



```bash
$ kubectl get no
NAME        STATUS                     ROLES                  AGE     VERSION
mnlab       Ready,SchedulingDisabled   control-plane,master   2d17h   v1.22.3
mnlab-m02   Ready                      <none>                 12m     v1.22.3
mnlab-m03   Ready                      <none>                 11m     v1.22.3
mnlab-m04   Ready,SchedulingDisabled   <none>                 11m     v1.22.3
```

`cordon` 처리한 `mnlab-m04` 노드가 스케줄링 비활성화(`SchedulingDisabled`) 상태로 빠졌다.  

<br>



#### deployment 생성

이제 `mnlab-m04` 노드에 pod가 배포 안되는지 직접 확인하기 위해 deployment를 생성해본다.

```bash
$ cat deploy-nginx.yaml
apiVersion: apps/v1
kind: Deployment            # 타입은 Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 5               # 5개의 Pod를 유지한다.
  selector:                 # Deployment에 속하는 Pod의 조건
    matchLabels:            # label의 app 속성의 값이 nginx 인 Pod를 찾아라.
      app: nginx
  template:
    metadata:
      labels:
        app: nginx          # labels 필드를 사용해서 app: nginx 레이블을 붙힘
    spec:
      containers:           # container에 대한 정의
      - name: nginx         # container의 이름
        image: nginx:1.7.9  # Docker Hub에 업로드된 nginx:1.7.9 이미지를 사용
        ports:
        - containerPort: 80
```

5개의 nginx pod를 생성하는 deployment yaml 파일이다.  

컨테이너 이미지는 Docker Hub에 공식 등록된 `nginx:1.7.9`를 사용한다.  

<br>



```bash
$ kubectl apply -f deploy-nginx.yaml
deployment.apps/nginx-deployment created
```

작성한 yaml 파일로 deployment를 생성했다.  

<br>



#### 배포 결과확인

deployment로 pod 5대를 생성했지만 `mnlab-m04` 노드에는 pod가 1대도 배포되지 않았다!

```bash
$ kubectl get all -o wide
NAME                                    READY   STATUS    RESTARTS   AGE   IP           NODE        NOMINATED NODE   READINESS GATES
pod/nginx-deployment-5d59d67564-5jz9r   1/1     Running   0          12s   10.244.1.3   mnlab-m02   <none>           <none>
pod/nginx-deployment-5d59d67564-grwwc   1/1     Running   0          12s   10.244.2.3   mnlab-m03   <none>           <none>
pod/nginx-deployment-5d59d67564-pmsfr   1/1     Running   0          12s   10.244.2.2   mnlab-m03   <none>           <none>
pod/nginx-deployment-5d59d67564-qwnht   1/1     Running   0          12s   10.244.1.4   mnlab-m02   <none>           <none>
pod/nginx-deployment-5d59d67564-xc8tv   1/1     Running   0          12s   10.244.1.2   mnlab-m02   <none>           <none>

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   15h   <none>

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES        SELECTOR
deployment.apps/nginx-deployment   5/5     5            5           12s   nginx        nginx:1.7.9   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES        SELECTOR
replicaset.apps/nginx-deployment-5d59d67564   5         5         5       12s   nginx        nginx:1.7.9   app=nginx,pod-template-hash=5d59d67564
```

<br>



#### cordon 해제

```bash
$ kubectl uncordon mnlab-m04
node/mnlab-m04 uncordoned
```

`mnlab-m04` 노드의 cordon이 해제되었다.  

<br>

```bash
$ kubectl get no
NAME        STATUS                     ROLES                  AGE     VERSION
mnlab       Ready,SchedulingDisabled   control-plane,master   2d17h   v1.22.3
mnlab-m02   Ready                      <none>                 15m     v1.22.3
mnlab-m03   Ready                      <none>                 14m     v1.22.3
mnlab-m04   Ready                      <none>                 14m     v1.22.3
```

이후부터 `mnlab-m04` 노드에 pod가 다시 배포될 수 있다.  

<br>



## drain

`kubectl drain`은 지정한 노드에 이미 배포된 pod를 제거한 후 다른 노드에 재배치하는 명령어이다. (참고로 쿠버네티스에서 pod를 옮기는 기능은 존재하지 않는다. 파드를 다른 노드에 다시 생성할 뿐이다.)  

drain 설정된 노드에는 pod가 다른 노드로 재배치된 후 스케줄링이 비활성화(`SchedulingDisabled`)되어 이후 어떠한 pod도 배포되지 않는다. 노드의 하드웨어 작업이나 리부팅이 필요할 경우, 먼저 drain으로 pod를 다른 노드로 재배치한 후 원하는 유지보수 작업을 수행하면 된다.

<br>



**주의사항** : ReplicationController, ReplicaSet, Deployment, StatefulSet 등의 컨트롤러에서 관리하지 않는 <u>개별 파드(Static pod)의 경우 drain 실행시 다른 노드에 재배포 되지않고 삭제만 발생하므로 데이터가 손실될 수 있다.</u>  

<br>



**drain을 실행하면 발생하는 일**

1. 해당 노드에 더 이상 pod 배포를 하지 않도록 스케줄링 비활성화 (`SchedulingDisabled`)
2. 노드에 이미 배포된 pod를 모두 삭제
3. 삭제된 pod는 새로운 정상 노드에서 재생성됨

drain은 cordon 기능에 pod를 다른 노드로 재배치하는 기능 2개가 결합된 거라고 이해하면 쉽다.

<br>



### 설정방법

```bash
$ kubectl drain <노드 이름> --ignore-daemonsets
```

<br>



### 예제

#### 노드 확인

```bash
$ kubectl get no
NAME        STATUS                     ROLES                  AGE     VERSION
mnlab       Ready,SchedulingDisabled   control-plane,master   2d17h   v1.22.3
mnlab-m02   Ready                      <none>                 29m     v1.22.3
mnlab-m03   Ready                      <none>                 28m     v1.22.3
mnlab-m04   Ready                      <none>                 28m     v1.22.3
```

현재 시나리오에는 클러스터 노드 4대(Master node 1 + Worker node 3)가 존재한다.  

<br>



#### deployment 배포

cordon 예제에서 쓴 deployment를 똑같이 배포해놓았다.

```bash
$ kubectl get all -o wide
NAME                                    READY   STATUS    RESTARTS   AGE   IP           NODE        NOMINATED NODE   READINESS GATES
pod/nginx-deployment-5d59d67564-2jdjt   1/1     Running   0          6s    10.244.1.7   mnlab-m02   <none>           <none>
pod/nginx-deployment-5d59d67564-4qjvt   1/1     Running   0          6s    10.244.2.7   mnlab-m03   <none>           <none>
pod/nginx-deployment-5d59d67564-6qjg5   1/1     Running   0          6s    10.244.3.3   mnlab-m04   <none>           <none>
pod/nginx-deployment-5d59d67564-j78cp   1/1     Running   0          6s    10.244.2.8   mnlab-m03   <none>           <none>
pod/nginx-deployment-5d59d67564-j8wft   1/1     Running   0          6s    10.244.1.8   mnlab-m02   <none>           <none>

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   15h   <none>

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES        SELECTOR
deployment.apps/nginx-deployment   5/5     5            5           6s    nginx        nginx:1.7.9   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES        SELECTOR
replicaset.apps/nginx-deployment-5d59d67564   5         5         5       6s    nginx        nginx:1.7.9   app=nginx,pod-template-hash=5d59d67564
```

5개의 pod가 `mnlab-m02`, `mnlab-m03`, `mnlab-m04` 노드에 골고루 배포되어 있는 상태이다. 이 상태에서 `mnlab-m04` 노드를 drain 해본다.  

<br>



#### drain

```bash
$ kubectl drain mnlab-m04 --ignore-daemonsets
node/mnlab-m04 cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/kindnet-jgdz8, kube-system/kube-proxy-9fxn7
evicting pod default/nginx-deployment-5d59d67564-6qjg5
pod/nginx-deployment-5d59d67564-6qjg5 evicted
node/mnlab-m04 evicted
```

현재 시나리오 기준으로 Worker node마다 시스템 관련 Pod인 `kindnet`과 `kube-proxy`가 존재한다.  

drain 실행시 `--ignore-daemonsets` 옵션을 줘서 데몬셋에 의해 생성된 시스템 Pod는 drain에서 제외한다.

<br>



```bash
$ kubectl get no
NAME        STATUS                     ROLES                  AGE     VERSION
mnlab       Ready,SchedulingDisabled   control-plane,master   2d17h   v1.22.3
mnlab-m02   Ready                      <none>                 31m     v1.22.3
mnlab-m03   Ready                      <none>                 31m     v1.22.3
mnlab-m04   Ready,SchedulingDisabled   <none>                 31m     v1.22.3
```

`mnlab-m04` 노드가 스케줄링 비활성화 상태(`SchedulingDisabled`)로 빠졌다. 더 이상 해당 노드에 pod가 스케줄링되어 생성되지 않는다는 의미이다.  

<br>



#### 결과확인

`mnlab-m04` 노드에 있던 pod 1대가 삭제된 후 다른 노드로 재배포되었다.  

```bash
$ kubectl get all -o wide
NAME                                    READY   STATUS    RESTARTS   AGE   IP           NODE        NOMINATED NODE   READINESS GATES
pod/nginx-deployment-5d59d67564-2jdjt   1/1     Running   0          91s   10.244.1.7   mnlab-m02   <none>           <none>
pod/nginx-deployment-5d59d67564-4qjvt   1/1     Running   0          91s   10.244.2.7   mnlab-m03   <none>           <none>
pod/nginx-deployment-5d59d67564-j78cp   1/1     Running   0          91s   10.244.2.8   mnlab-m03   <none>           <none>
pod/nginx-deployment-5d59d67564-j8wft   1/1     Running   0          91s   10.244.1.8   mnlab-m02   <none>           <none>
pod/nginx-deployment-5d59d67564-nn699   1/1     Running   0          20s   10.244.1.9   mnlab-m02   <none>           <none>

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   15h   <none>

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES        SELECTOR
deployment.apps/nginx-deployment   5/5     5            5           91s   nginx        nginx:1.7.9   app=nginx

NAME                                          DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES        SELECTOR
replicaset.apps/nginx-deployment-5d59d67564   5         5         5       91s   nginx        nginx:1.7.9   app=nginx,pod-template-hash=5d59d67564
```

<br>



#### 해제
해제 방법은 cordon과 동일하게 `uncordon` 명령어로 스케줄링 비활성화를 해제한다.
```bash
$ kubectl uncordon mnlab-m04
node/mnlab-m04 uncordoned
```
<br>



`mnlab-m04` 노드에 스케줄링 비활성화(`SchedulingDisabled`) 상태가 사라졌다. 이후부터는 다시 해당 노드로 pod가 배포될 것이다.

```bash
$ kubectl get no
NAME        STATUS                     ROLES                  AGE     VERSION
mnlab       Ready,SchedulingDisabled   control-plane,master   2d17h   v1.22.3
mnlab-m02   Ready                      <none>                 48m     v1.22.3
mnlab-m03   Ready                      <none>                 48m     v1.22.3
mnlab-m04   Ready                      <none>                 47m     v1.22.3
```
