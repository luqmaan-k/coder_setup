FROM alpine

RUN apk add --no-cache \
    sudo \
    curl

ARG USER=coder
RUN adduser -D -G wheel ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER}

USER ${USER}
WORKDIR /home/${USER}

