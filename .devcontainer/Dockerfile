FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG NVIM_VERSION=stable

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    clang \
    cmake \
    curl \
    fd-find \
    g++ \
    gcc \
    gdb \
    gettext \
    git \
    golang-go \
    lldb \
    lua5.1 \
    luarocks \
    make \
    ninja-build \
    nodejs \
    npm \
    pkg-config \
    python-is-python3 \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    ripgrep \
    shellcheck \
    shfmt \
    unzip \
    xclip \
    yarnpkg \
    zip \
  && ln -sf /usr/bin/fdfind /usr/local/bin/fd \
  && npm install -g \
    eslint_d \
    neovim \
    pnpm \
    prettier \
    prettierd \
    typescript \
    typescript-language-server \
    yarn \
  && curl -fsSL -o /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" \
  && tar -C /opt -xzf /tmp/nvim.tar.gz \
  && ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim \
  && rm -rf /var/lib/apt/lists/* /tmp/nvim.tar.gz

ENV EDITOR=nvim
