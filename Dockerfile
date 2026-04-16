FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG NOVNC_VERSION=v1.5.0
ARG WEBSOCKIFY_VERSION=v0.13.0
ARG MONGODB_COMPASS_VERSION=1.49.0
ARG GITHUB_DESKTOP_VERSION=3.4.13-linux1
ARG DRAWIO_VERSION=29.6.6

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Base system + desktop + tooling required by noVNC/x11vnc.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    apache2 \
    ca-certificates \
    codeblocks \
    curl \
    dbus-x11 \
    git \
    git-gui \
    gitk \
    gitg \
    gnupg \
    lsb-release \
    mariadb-client \
    mariadb-server \
    p7zip-full \
    plantuml \
    php-cli \
    php-curl \
    php-mbstring \
    php-xml \
    procps \
    python3 \
    python3-pip \
    python-is-python3 \
    r-base \
    scrot \
    software-properties-common \
    sudo \
    unzip \
    vlc \
    wget \
    libreoffice \
    xfce4 \
    xfce4-terminal \
    x11vnc \
    xvfb \
  && mkdir -p /etc/apt/keyrings

# External repositories for Node.js, MongoDB, and Visual Studio Code.
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
  && curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg --dearmor -o /etc/apt/keyrings/mongodb-server-7.0.gpg \
  && echo "deb [ arch=amd64 signed-by=/etc/apt/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-7.0.list \
  && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg \
  && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list

# Install runtimes/dev tools and configure phpMyAdmin non-interactively.
RUN echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections \
  && echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    code \
    mongodb-mongosh \
    mongodb-org \
    nodejs \
    phpmyadmin \
  && JAVA21_PKG="" \
  && JAVA24_PKG="" \
  && if apt-cache show openjdk-21-jdk >/dev/null 2>&1; then JAVA21_PKG="openjdk-21-jdk"; fi \
  && if apt-cache show openjdk-24-jdk >/dev/null 2>&1; then JAVA24_PKG="openjdk-24-jdk"; fi \
  && if [ -n "${JAVA21_PKG}" ]; then apt-get install -y --no-install-recommends "${JAVA21_PKG}"; fi \
  && if [ -n "${JAVA24_PKG}" ]; then apt-get install -y --no-install-recommends "${JAVA24_PKG}"; fi \
  && if [ -z "${JAVA21_PKG}" ] && [ -z "${JAVA24_PKG}" ]; then \
       echo "Neither openjdk-21-jdk nor openjdk-24-jdk is available on this Ubuntu base image." >&2; \
       exit 1; \
     fi \
  && if apt-cache show notepadqq >/dev/null 2>&1; then \
       apt-get install -y --no-install-recommends notepadqq; \
     else \
       apt-get install -y --no-install-recommends mousepad; \
     fi \
  && wget -q -O /tmp/mongodb-compass.deb "https://downloads.mongodb.com/compass/mongodb-compass_${MONGODB_COMPASS_VERSION}_amd64.deb" \
  && apt-get install -y --no-install-recommends /tmp/mongodb-compass.deb \
  && rm -f /tmp/mongodb-compass.deb \
  && wget -q -O /tmp/github-desktop.deb "https://github.com/shiftkey/desktop/releases/download/release-${GITHUB_DESKTOP_VERSION}/GitHubDesktop-linux-amd64-${GITHUB_DESKTOP_VERSION}.deb" \
  && apt-get install -y --no-install-recommends /tmp/github-desktop.deb \
  && rm -f /tmp/github-desktop.deb \
  && wget -q -O /tmp/drawio.deb "https://github.com/jgraph/drawio-desktop/releases/download/v${DRAWIO_VERSION}/drawio-amd64-${DRAWIO_VERSION}.deb" \
  && apt-get install -y --no-install-recommends /tmp/drawio.deb \
  && rm -f /tmp/drawio.deb \
  && printf '#!/bin/sh\nexec /usr/bin/drawio --no-sandbox "$@"\n' >/usr/local/bin/drawio \
  && chmod +x /usr/local/bin/drawio \
  && if [ -f /usr/share/applications/drawio.desktop ]; then \
       sed -i 's|^Exec=.*|Exec=/usr/local/bin/drawio %U|' /usr/share/applications/drawio.desktop; \
     fi \
  && printf '#!/bin/sh\nexec /usr/bin/mongodb-compass --no-sandbox "$@"\n' >/usr/local/bin/mongodb-compass \
  && chmod +x /usr/local/bin/mongodb-compass \
  && if [ -f /usr/share/applications/mongodb-compass.desktop ]; then \
       sed -i 's|^Exec=.*|Exec=/usr/local/bin/mongodb-compass %U|' /usr/share/applications/mongodb-compass.desktop; \
     fi \
  && curl -fsSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && composer --version \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# websockify (used by noVNC)
RUN pip3 install --no-cache-dir websockify

# noVNC
RUN git clone --depth 1 --branch ${NOVNC_VERSION} https://github.com/novnc/noVNC.git /opt/noVNC \
  && git clone --depth 1 --branch ${WEBSOCKIFY_VERSION} https://github.com/novnc/websockify /opt/noVNC/utils/websockify

# Create a dev user
RUN useradd -m dev \
  && echo "dev:dev" | chpasswd \
  && adduser dev sudo

WORKDIR /home/dev

# Copy apps and startup
COPY start.sh /start.sh
COPY node-app /home/dev/node-app
COPY python-app /home/dev/python-app

RUN chmod +x /start.sh \
  && chown -R dev:dev /home/dev \
  && su - dev -c "cd /home/dev/node-app && npm install" \
  && pip3 install --no-cache-dir -r /home/dev/python-app/requirements.txt

EXPOSE 6080 3000 5000 3306 27017 80

CMD ["/start.sh"]
