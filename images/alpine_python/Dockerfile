FROM python:3.12-alpine

RUN apk add --no-cache \
    sudo \
    curl \
    bash \
    libstdc++ \
    gcc \
    g++ \
    libc6-compat

ARG USER=coder
RUN adduser -D -G wheel ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER}

USER ${USER}
WORKDIR /home/${USER}

