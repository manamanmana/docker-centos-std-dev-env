## Preperation
# 1. Place your id_rsa and id_rsa.pub on the same directory with this file.
# 2. How to build
#    Example:
#    docker build --build-arg DEV_USER=gaku -t manamanmana/centos-std-dev-env:2016-09-22 .
# 3. How to run
#    Example:
#    docker run -d -p 10022:22 \
#               -v /Users/gaku/shared/private/docker/docker-centos-std-dev-env/some-project:/home/gaku/some-project \
#               -v /Users/gaku/shared/private/docker/docker-centos-std-dev-env/goland:/home/gaku/goland \
#               --name centos-std-dev-env-container manamanmana/centos-std-dev-env:2016-09-22
FROM centos
MAINTAINER manamanmana manamanmana@gmail.com

# @NOTE
# Build time args: need to pass through with docker build --build-arg 
# or docker-compose build: args directive.
ARG DEV_USER

# ===================================================================
# Base environments
# ===================================================================

RUN yum -y update

# Add EPEL repository
RUN yum -y install epel-release && \
    sed -ri 's/enabled=1/enabled=0/g' /etc/yum.repos.d/epel.repo

# Add Remi repository
RUN rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

# Group install for needed for basic admin operation and development environment
RUN yum --setopt=group_package_types=optional groupinstall 'Development Tools' -y
RUN yum --setopt=group_package_types=optional groupinstall 'System Administration Tools' -y
RUN yum -y install bison \
                   telnet \
                   wget

# ===================================================================
# Database clients
# ===================================================================

# MySQL Client
RUN yum -y install http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm && \
    sed -ri 's/enabled=1/enabled=0/g' /etc/yum.repos.d/mysql-community.repo
RUN yum -y --enablerepo=mysql56-community install mysql mysql-devel

# PostgreSQL Client
RUN yum install postgresql-contrib.x86_64 postgresql-devel.x86_64 -y

# Redis
# @NOTE Change the download version what you need.
RUN cd /tmp && wget http://download.redis.io/releases/redis-3.2.3.tar.gz && \
    tar xvzf redis-3.2.3.tar.gz && cd redis-3.2.3 && make && \
    mkdir /etc/redis && cp redis.conf /etc/redis/6379.conf && cd src &&\
    cp redis-server redis-cli redis-sentinel redis-benchmark redis-check-aof /usr/local/bin
RUN cd /tmp && rm -rf redis-3.2.3*


# ===================================================================
# Setup users environment
# ===================================================================

# Root password 
# @NOTE Please change anything you like
RUN echo 'root:root' | chpasswd

# DEV_USER : set through build args
# @NOTE Please change DEV_USER password to anything you like
RUN useradd -m "${DEV_USER}"
RUN echo "${DEV_USER}:${DEV_USER}" | chpasswd

# sudo
RUN yum install sudo -y && \
    echo "${DEV_USER} ALL=(ALL) NOPASSWD:ALL" >> "/etc/sudoers.d/${DEV_USER}"

# .ssh
RUN mkdir /home/"${DEV_USER}"/.ssh && chown "${DEV_USER}" /home/"${DEV_USER}"/.ssh && \
    chmod 700 /home/"${DEV_USER}"/.ssh
# @NOTE Please place id_rsa on the same dir with Dockerfile of Host
COPY id_rsa /home/"${DEV_USER}"/.ssh/
# @NOTE Please place id_rsa.pub on the same dir with Dockerfile of Host
COPY id_rsa.pub /home/"${DEV_USER}"/.ssh/
RUN chown "${DEV_USER}" /home/"${DEV_USER}"/.ssh/id_rsa && \
    chmod 600 /home/"${DEV_USER}"/.ssh/id_rsa && \
    chown "${DEV_USER}" /home/"${DEV_USER}"/.ssh/id_rsa.pub
RUN cp /home/"${DEV_USER}"/.ssh/id_rsa.pub /home/"${DEV_USER}"/.ssh/authorized_keys && \
    chmod 600 /home/"${DEV_USER}"/.ssh/authorized_keys && \
    chown "${DEV_USER}" /home/"${DEV_USER}"/.ssh/authorized_keys

# tmux and vim
RUN yum -y install ctags \
                   git \
                   tmux \
                   vim
USER "${DEV_USER}"
ENV HOME "/home/${DEV_USER}"
WORKDIR $HOME
# Install NeoBundle
RUN mkdir -p .vim/bundle && \
    git clone https://github.com/Shougo/neobundle.vim .vim/bundle/neobundle.vim
# For Jedi Python Vim Plugin
RUN cd .vim/bundle && git clone --recursive https://github.com/davidhalter/jedi-vim.git
# Copy .vimrc
COPY .vimrc /home/"${DEV_USER}"/
USER root
RUN chown "${DEV_USER}" /home/"${DEV_USER}"/.vimrc




# ===================================================================
# sshd
# ===================================================================
RUN yum -y install openssh-server && \
    sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    sed -ri 's/#Port 22/Port 22/g' /etc/ssh/sshd_config && \
    sed -ri 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/g' /etc/ssh/sshd_config && \
    sed -i -e 's/^\(session.*pam_loginuid.so\)/#\1/g' /etc/pam.d/sshd && \
    sshd-keygen

# ===================================================================
# Each Language Environments
# ===================================================================
RUN yum -y install bzip2-devel \
                   openssl-devel \
                   readline-devel \
                   sqlite-devel \
                   zlib-devel
# anyenv
USER "${DEV_USER}"
ENV HOME "/home/${DEV_USER}"
WORKDIR $HOME
RUN git clone https://github.com/riywo/anyenv .anyenv
RUN echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> .bash_profile && \
    echo 'eval "$(anyenv init -)"' >> .bash_profile
RUN exec /bin/bash -l
# Ruby
# -- rbenv
RUN .anyenv/bin/anyenv install rbenv
RUN exec /bin/bash -l
# -- ruby
# @NOTE Please install any ruby version you like
ENV RBENV_ROOT "/home/${DEV_USER}/.anyenv/envs/rbenv"
ENV PATH "/home/${DEV_USER}/.anyenv/envs/rbenv/bin:$PATH"
RUN .anyenv/envs/rbenv/bin/rbenv install 2.3.1 && \
    .anyenv/envs/rbenv/bin/rbenv rehash && \
    .anyenv/envs/rbenv/bin/rbenv global 2.3.1
RUN .anyenv/envs/rbenv/shims/gem install bundler --no-ri --no-doc #Bundler
RUN .anyenv/envs/rbenv/shims/gem install rubocop refe2 --no-ri --no-doc # Fir vim plugins
# Python
# -- pyenv
RUN .anyenv/bin/anyenv install pyenv
RUN exec /bin/bash -l
# -- python
# @NOTE Please install any python version you like

# -- python
# @NOTE Please install any python version you like
ENV PYENV_ROOT "/home/${DEV_USER}/.anyenv/envs/pyenv"
ENV PATH "/home/${DEV_USER}/.anyenv/envs/pyenv/bin:$PATH"
RUN .anyenv/envs/pyenv/bin/pyenv install 2.7.12 && \
    .anyenv/envs/pyenv/bin/pyenv install 3.5.2 && \
    .anyenv/envs/pyenv/bin/pyenv rehash && \
    .anyenv/envs/pyenv/bin/pyenv global 2.7.12
RUN .anyenv/envs/pyenv/shims/pip install --upgrade pip && \
    .anyenv/envs/pyenv/shims/pip install virtualenv
# NodeJS
# -- ndenv
RUN .anyenv/bin/anyenv install ndenv
RUN exec /bin/bash -l
# -- NodeJS
# @NOTE Please install any NodeJS version you like
ENV NDENV_ROOT "/home/${DEV_USER}/.anyenv/envs/ndenv"
ENV PATH "/home/${DEV_USER}/.anyenv/envs/ndenv/bin:$PATH"
RUN .anyenv/envs/ndenv/bin/ndenv install v4.5.0 && \
    .anyenv/envs/ndenv/bin/ndenv install v6.5.0 && \
    .anyenv/envs/ndenv/bin/ndenv rehash && \
    .anyenv/envs/ndenv/bin/ndenv global v4.5.0
RUN .anyenv/envs/ndenv/shims/npm install -g eslint # For vim plugin
# Golang
# -- goenv
RUN .anyenv/bin/anyenv install goenv
RUN exec /bin/bash -l
# -- Go
# @NOTE Please install any go version you like
ENV GOENV_ROOT "/home/${DEV_USER}/.anyenv/envs/goenv"
ENV PATH "/home/${DEV_USER}/.anyenv/envs/goenv/bin:$PATH"
RUN .anyenv/envs/goenv/bin/goenv install 1.6.3 && \
    .anyenv/envs/goenv/bin/goenv install 1.7 && \
    .anyenv/envs/goenv/bin/goenv rehash && \
    .anyenv/envs/goenv/bin/goenv global 1.7
RUN echo 'export GOROOT=$(go env GOROOT)' >> .bash_profile # GOROOT
RUN echo 'export GOPATH=~/goland' >> .bash_profile && \
    echo 'export PATH=$PATH:$GOPATH/bin' >> .bash_profile && \
    exec /bin/bash -l

# ===================================================================
# Execute sshd
# ===================================================================
USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

