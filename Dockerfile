FROM ubuntu:20.04
LABEL maintainer="sysadmins@cs50.harvard.edu"
ARG DEBIAN_FRONTEND=noninteractive
ARG VCS_REF


# Avoid "delaying package configuration, since apt-utils is not installed"
RUN apt update && apt install --yes apt-utils


# Environment
RUN apt update && \
    apt install --yes locales && \
    locale-gen "en_US.UTF-8" && dpkg-reconfigure locales


# Unminimize system
RUN yes | unminimize


# Install Ubuntu packages
RUN apt update && \
    apt install --no-install-recommends --yes \
        astyle \
        bash-completion \
        ca-certificates `# for curl` \
        clang \
        coreutils `# for fold` \
        curl \
        dos2unix \
        dnsutils `# For nslookup` \
        gdb \
        git \
        git-lfs \
        jq \
        less \
        make \
        man \
        man-db \
        nano \
        openssh-client `# For ssh-keygen` \
        psmisc `# For fuser` \
        sudo \
        unzip \
        valgrind \
        vim \
        weasyprint `# For render50` \
        wget \
        zip


# Install CS50 packages
RUN curl https://packagecloud.io/install/repositories/cs50/repo/script.deb.sh | bash && \
    apt update && \
    apt install --yes \
        libcs50


# Install Java 17.x
# http://jdk.java.net/17/
RUN cd /tmp && \
    wget https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz && \
    tar xzf openjdk-17.0.2_linux-x64_bin.tar.gz && \
    rm --force openjdk-17.0.2_linux-x64_bin.tar.gz && \
    mv jdk-17.0.2 /opt/ && \
    mkdir --parent /opt/bin && \
    ln --symbolic /opt/jdk-17.0.2/bin/* /opt/bin/ && \
    chmod a+rx /opt/bin/*


# Install Node.js 17.x
# https://github.com/tj/n#installation
RUN curl --location https://raw.githubusercontent.com/tj/n/master/bin/n --output /usr/local/bin/n && \
    chmod a+x /usr/local/bin/n && \
    n 17.7.1


# Install Node.js packages
RUN npm install -g http-server


# Suggested build environment for Python, per pyenv, even though we're building ourselves
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
RUN apt update && \
    apt install --no-install-recommends --yes \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev


# Install Python 3.10.x
# https://www.python.org/downloads/
RUN cd /tmp && \
    curl https://www.python.org/ftp/python/3.10.4/Python-3.10.4.tgz --output Python-3.10.4.tgz && \
    tar xzf Python-3.10.4.tgz && \
    rm --force Python-3.10.4.tgz && \
    cd Python-3.10.4 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm --force --recursive Python-3.10.4 && \
    ln --relative --symbolic /usr/local/bin/python3 /usr/local/bin/python && \
    pip3 install --upgrade pip


# Install Python packages
RUN apt update && \
    apt install --yes libmagic-dev `# For style50` && \
    pip3 install \
        awscli \
        "check50<4" \
        compare50 \
        cs50 \
        Flask \
        Flask-Session \
        help50 \
        render50 \
        s3cmd \
        style50 \
        "submit50<4"


# Install Ruby 3.1.x
# https://www.ruby-lang.org/en/downloads/
RUN cd /tmp && \
    curl https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.1.tar.gz --output ruby-3.1.1.tar.gz && \
    tar xzf ruby-3.1.1.tar.gz && \
    rm --force ruby-3.1.1.tar.gz && \
    cd ruby-3.1.1 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm --force --recursive ruby-3.1.1


# Install Ruby packages
RUN gem install \
    bundler \
    jekyll \
    jekyll-theme-cs50 \
    minitest `# So that Bundler needn't install` \
    pygments.rb


# Install SQLite 3.x
# https://www.sqlite.org/download.html
RUN cd /tmp && \
    wget https://www.sqlite.org/2022/sqlite-tools-linux-x86-3380000.zip && \
    unzip sqlite-tools-linux-x86-3380000.zip && \
    rm --force sqlite-tools-linux-x86-3380000.zip && \
    mv sqlite-tools-linux-x86-3380000/* /usr/local/bin/ && \
    rm --force --recursive sqlite-tools-linux-x86-3380000


# Copy files to image
COPY ./etc /etc
COPY ./opt /opt
RUN chmod a+rx /opt/cs50/bin/*


# Add user
RUN useradd --home-dir /home/ubuntu --shell /bin/bash ubuntu && \
    umask 0077 && \
    mkdir -p /home/ubuntu && \
    chown -R ubuntu:ubuntu /home/ubuntu


# Add user to sudoers
RUN echo "\n# CS50 CLI" >> /etc/sudoers && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "Defaults umask_override" >> /etc/sudoers && \
    echo "Defaults umask=0022" >> /etc/sudoers && \
    sed -e "s|^Defaults\tsecure_path=.*|Defaults\t!secure_path|" -i /etc/sudoers



# Version the image (and any descendants)
RUN echo "$VCS_REF" > /etc/issue
ONBUILD USER root
ONBUILD ARG VCS_REF
ONBUILD RUN echo "$VCS_REF" >> /etc/issue
ONBUILD USER ubuntu


# Set user
USER ubuntu
WORKDIR /home/ubuntu
ENV WORKDIR=/home/ubuntu
