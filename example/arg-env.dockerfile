FROM alpine:3.16

LABEL maintainer="Yuki git@48763 <future.starshine@gmail.com>"

ENV URL=yayuyo.yt
ARG USER=Edgar

RUN set -x \
    && echo "echo -e \"\033[0;41m\${USER}'s youtube url is \\\"\${URL}\\\".\033[0m\"" >> print.sh \
    && /bin/sh print.sh

CMD [ "/bin/sh", "print.sh"]