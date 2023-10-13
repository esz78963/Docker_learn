# Dockerfile 指令集

Docker 依照 dockerfile 建置鏡像時，會讀取每行的開頭指令，以執行相對應的動作。

dcokerfile 常用的指令列表：

- [FROM](#from)
- [ARG & ENV](#arg--env)
- [COPY](#copy)
- [RUN](#run)
- [CMD](#cmd)
- [ENTRYPOINT](#entrypoint)
- [HEALTHCHECK](#healthcheck)


## 基礎容器操作指令

該篇著重在 dockefile 指令，但為了測試其指令功能對鏡像或容器的作用，會使用到下面三項操作容器的指令：

### 運行容器：

```bash 
$ docker run [--name <container-name>] <image-name>
```

- `--name`：自訂義容器名稱。

### 查看容器狀態

```bash
$ docker ps -a
```

- `-a`：查看所有容器。

### 刪除容器：

```bash
$ docker rm --force <container-name-or-id>
```

- `--force`：強制執行

***請務必在每個指令小節測試完畢後，將實驗用的容器刪除。***

## FROM

從指定的鏡像製作鏡像。

```dockerfile
FROM <image>[:<tag>|@<digest>] [AS <name>]
```

指定 `alpine:3.16.3` 作為基底：

```dockerfile
FROM alpine:3.16.3
```

或是 `@` 添加雜湊：

```dockerfile
FROM alpine@sha256:3d426b0bfc361d6e8303f51459f17782b219dece42a1c7fe463b6014b189c86d
```

> 一般情況為了方便撰寫/閱讀，都不會使用該方式。但如果有資安考量，應該選擇這樣的標示。

## ARG & ENV

### ARG

設置在指令列中使用的變數。

```dockerfile
ARG <name>[=<default value>]
```

### ENV

在所製作的鏡像的系統中設置環境變數。

```dockerfile
ENV <key> <value>
ENV <key>=<value> ...
```

### [範例](example/arg-env.dockerfile)

使用下列指令建置鏡像，並運行容器：

```bash
$ docker build -t arg-env \
    -f example/arg-env.dockerfile \
    --progress plain \
    --no-cache \
    ./example 
$ docker run --name arg-env arg-env
```

主要比較**鏡像建置過程**與**容器運行結果**中，執行 `/bin/sh print.sh` 的輸出。

#### 鏡像

```bash
Edgar's youtube url is "yayuyo.yt".
```

#### 容器

```bash
's youtube url is "yayuyo.yt".
```

因為 `ENV` 和 `ARG` 所執行的涵蓋範圍不同，所以容器的輸出少了 `Edgar` 字串。

## COPY

新增/複製檔案至製作的鏡像中。

```dockerfile
COPY [--chown=<user>:<group>] <src>... <dest>
```

```dockerfile
COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
```

## RUN

在製作鏡像的容器中，執行想要的 [shell](https://zh.wikipedia.org/wiki/殼層) 指令。

```dockerfile
RUN <command>
```

### [範例](example/run.dockerfile)

使用下列指令建置鏡像，並運行容器：

```bash
$ docker build -t nginx:run \
    -f example/run.dockerfile \
    --no-cache \
    ./example 
```

在建置過程中，會發現每執行一個指令，都是建置一層。所以我們應該適當的進行合併：

```bash
RUN apk update \
    && apk add nginx \
    && mkdir /run/nginx
```

***合併[範例](example/run.dockerfile)中的 `RUN`，並再次建置並觀察。***

## CMD

基於該鏡像運作容器時，該容器運行的目標指令。僅有最後一項 `CMD` 能生效。

```dockerfile
CMD ["executable","param1","param2"]
CMD command param1 param2
```

### [範例](example/cmd.dockerfile)

使用下列指令建置鏡像，並運行容器：

```bash
$ docker build -t nginx:cmd \
    -f example/cmd.dockerfile \
    --no-cache \
    ./example 
$ docker run --name nginx -p 80:80 -d nginx:cmd
```

主要觀察容器的狀態：

```bash
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
c344c9f0a3e3        nginx:cmd           "nginx"             4 seconds ago       Exited (0) 2 seconds ago                       nginx
```

會發現欄位 `STATUS` 是已退出，這裡肯定困惑容器為什麼會退出？因為在 dockerfile 中的 `CMD`，其目的就只是執行 `nginx`，當容器執行完成就會退出（從 `Exited (0)` 可以看出指令是正常執行結束）。

將配置改成如下[1][2]：

```dcokerfile
CMD ["nginx", "-g", "daemon off;"]
```

## ENTRYPOINT

基於該鏡像運作容器時，將會把 `CMD` 串接之後，作為該容器運行的目標指令。僅有最後一項 `ENTRYPOINT` 能生效。

```dockerfile
ENTRYPOINT ["executable", "param1", "param2"]
ENTRYPOINT command param1 param2
```

實際上運作會變成：

```dockerfile
ENTRYPOINT ["executable", "param1", "param2"] <CMD ["param1", "param2"]>
```

### [範例](example/entrypoint.dockerfile)

使用下列指令建置鏡像，並運行容器：

```bash
$ docker build -t curl:entrypoint \
    -f example/entrypoint.dockerfile \
    --no-cache \
    ./example 
```

觀察想要代入的指令：

```bash
$ docker run curl:entrypoint -s
127.0.0.1
```

> `docker run <image-name>` 後面所接的字串，將會覆蓋鏡像中的 CMD 指令。

但如果我們將[範例](example/entrypoint.dockerfile)中的 `ENTRYPOINT` 置換成 `CMD`：

```bash
$ docker build -t curl:cmd \
    -f example/entrypoint.dockerfile \
    --no-cache \
    ./example 
$ docker run curl:cmd curl ifconfig.me -s
127.0.0.1
```

***可以反覆交互操作，以理解其差異及用法。***

## HEALTHCHECK

基於該鏡像創建容器後，docker 會按照其設定替容器健康檢查。僅有最後一項 `HEALTHCHECK` 能生效。

```dockerfile
HEALTHCHECK [OPTIONS] CMD command
```

### 選項

| 名稱 | 預設 | 描述 |
| - | - | - |
| --interval=DURATION | 30s | 運行檢查的間隔 |
| --timeout=DURATION | 30s | 檢查運行的最大時限 |
| --start-period=DURATION | 0s | 初始化的開始時間 |
| --retries=N | 3t | 嘗試幾次失敗後，回報不健康 |

### [範例](example/healthcheck.dockerfile)

使用下列指令建置鏡像，並運行容器：

```bash    
$ docker build -t nginx:healthcheck \
    -f example/healthcheck.dockerfile \
    --no-cache \
    ./example 
$ docker run --name nginx -p 80:80 -d nginx:healthcheck
```

主要觀察容器的狀態：

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                    PORTS                NAMES
d1af5665c23d        nginx:healthcheck   "nginx -g 'daemon of…"   14 seconds ago      Up 13 seconds (healthy)   0.0.0.0:80->80/tcp   nginx
```

***執行健康檢查，必須瞭解容器中的應用，才知道該如何設置。***

## 參考

[1] Charles Duffy, 
    [HOW TO RUN NGINX WITHIN A DOCKER CONTAINER WITHOUT HALTING?](
    https://stackoverflow.com/questions/18861300/how-to-run-nginx-within-a-docker-container-without-halting), 
    Sep 17 2013, English

[2] NGINX, [CORE FUNCTIONALITY](http://nginx.org/en/docs/ngx_core_module.html#daemon), English

---
- Docker ,[DOCKERFILE REFERENCE](https://docs.docker.com/engine/reference/builder/), Eglish
