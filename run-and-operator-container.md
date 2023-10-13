# 容器的運行與操作

本篇會分成三個小節介紹：

- [`docker run`](#run)
- [`docker-compose`](#docker-compose)
- [`docker exec`](#exec)

## Run

容器化應用的好處之一，是在運行容器化應用時，只需要使用簡單的指令 - `docker run`，就可以快速創建啟用該應用容器容器。下面指令是運行名為 *nginx* 的容器： 

```bash
$ docker run \
    --name nginx \
    -p 80:80 \
    -d nginx:1.23.3-alpine
```

- `--name`: 指定容器的名稱，唯一性。
- `-p`: 設置容器的監聽埠映射。
- `-d`: 將容器背景執行。
- `nginx:1.23.3-alpine`: 指定鏡像名稱 `nginx` 及標籤 `1.23.3-alpine`。

> 如果要刪除該容器：
>
> ```bash
> docker rm -f nginx
> ```

上述所使用的鏡像，是公開在 [docker hub](https://hub.docker.com/_/nginx/tags) 上，所以只要點擊網頁進入，在搜索標籤，就能看到所使用的鏡像。所以想要使用其他應用程序的容器，也可以在上面搜索是否有官方或其他人提供鏡像。

如果想要替換配置，那麼我們可以將配置檔直接掛載到容器內：

```bash
$ docker run \
    --name nginx \
    -p 80:80 \
    -v $(pwd)/conf.d:/etc/nginx/conf.d \
    -d nginx:1.23.3-alpine
```

這時候再使用瀏覽器訪問 `localhost`，就會發現轉跳到 `yayuyo` 的 youtube 頻道，或是使用下面指令測試：

```
$ curl localhost -LI
```

> 如果要把 Log 從容器拉出來，也是先掛載目錄/檔案到容器內，讓應用寫在掛載的目錄/檔案就可以。

## Docker-compose

如果環境中的容器總是使用指令運行，其實會造成管理上的問題，例如：當初到底執行的指令，到底加了哪一些選項？以及掛載的檔案放在哪？

這些事情雖然都可以利用 `docker inspect` 查看，然後反推出原本運行的指令，但這實在很費時...，而且可能會有疏忽，導致有意想不到的驚喜發生。

所以在這推薦使用 `docker-compose`，使用下面指令下載和設置 `docker-compose`：

```bash
$ sudo curl -fSsL https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
```

之後只要把容器運行所需的設置選項寫進 `docker-compose.yaml`（[範例](./docker-compose.yml)），再執行下面指令就能運行容器：

```
$ docker-compose [-f compose-file-name] up -d 
```

移除容器也很簡單：

```
$ docker-compose [-f compose-file-name] down -v
```

## Exec

容器在運行時，有時候需要確認裡面的應用和配置，就會使用 `docker exec` 進行操作，指令如下：

```
$ docker exec -it [container-id-or-name] CMD
```

假如今天運行的容器名稱為 `nginx`，想要確認 `nginx.conf`：

```
$ docker exec nginx cat /etc/nginx/nginx.conf
```

或者是利用 shell 互動操作容器系統：

```
$ docker exec -it nginx /bin/sh
```

> 在最後面接的指令是一種 shell，常用的 `bash` 和 `zsh` 等，不一定會在容器內支援，所以很常會使用 `/bin/sh`

使用後會發現終端輸出與當前目錄，和下指令前原本不一樣，因為這時的操作就是在容器裡：

```
# uname -a
# cd /etc/nginx
# cat nginx.conf
```

> 記住，如果容器內的檔案不是透過系統掛載而來，那麼所有修改將會隨著容器一併刪除。
