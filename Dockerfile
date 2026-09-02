FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    curl \
    file \
    git \
    openssh-client \
    procps \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash linuxbrew \
    && mkdir -p /work \
    && chown -R linuxbrew:linuxbrew /work \
    && printf 'linuxbrew ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/linuxbrew \
    && chmod 0440 /etc/sudoers.d/linuxbrew

USER linuxbrew
WORKDIR /work

ENV HOME=/home/linuxbrew
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}

CMD ["/bin/bash"]
