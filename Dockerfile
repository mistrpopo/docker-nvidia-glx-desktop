# Ubuntu release versions 18.04 and 20.04 are supported
ARG UBUNTU_RELEASE=20.04
ARG CUDA_VERSION=11.2.2
FROM nvcr.io/nvidia/cudagl:${CUDA_VERSION}-runtime-ubuntu${UBUNTU_RELEASE}

LABEL maintainer "https://github.com/ehfd,https://github.com/danisla"

ARG UBUNTU_RELEASE
ARG CUDA_VERSION
# Make all NVIDIA GPUs visible, but we want to manually install drivers
ARG NVIDIA_VISIBLE_DEVICES=all
# Supress interactive menu while installing keyboard-configuration
ARG DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_DRIVER_CAPABILITIES all
ENV PULSE_SERVER 127.0.0.1:4713

# Default environment variables (password is "mypasswd")
ENV TZ UTC
ENV SIZEW 1920
ENV SIZEH 1080
ENV REFRESH 60
ENV DPI 96
ENV CDEPTH 24
ENV VIDEO_PORT DFP
ENV PASSWD mypasswd
ENV NOVNC_ENABLE false
ENV WEBRTC_ENCODER nvh264enc
ENV WEBRTC_ENABLE_RESIZE false
ENV ENABLE_AUDIO true
ENV ENABLE_BASIC_AUTH true

# Temporary fix for NVIDIA container repository
RUN apt-get clean && \
    apt-key adv --fetch-keys "https://developer.download.nvidia.com/compute/cuda/repos/$(cat /etc/os-release | grep '^ID=' | awk -F'=' '{print $2}')$(cat /etc/os-release | grep '^VERSION_ID=' | awk -F'=' '{print $2}' | sed 's/[^0-9]*//g')/x86_64/3bf863cc.pub" && \
    rm -rf /var/lib/apt/lists/*

# Install locales to prevent errors
RUN apt-get clean && \
    apt-get update && apt-get install --no-install-recommends -y locales && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Xorg, Xfce Desktop, and others
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install --no-install-recommends -y \
        software-properties-common \
        apt-transport-https \
        apt-utils \
        build-essential \
        ca-certificates \
        kmod \
        libc6:i386 \
        libc6-dev \
        cups-filters \
        cups-common \
        cups-pdf \
        curl \
        file \
        wget \
        bzip2 \
        gzip \
        p7zip-full \
        xz-utils \
        zip \
        unzip \
        zstd \
        gcc \
        git \
        jq \
        make \
        python \
        python-numpy \
        python3 \
        python3-cups \
        python3-numpy \
        mlocate \
        nano \
        vim \
        htop \
        firefox \
        transmission-gtk \
        qpdfview \
        xarchiver \
        brltty \
        brltty-x11 \
        desktop-file-utils \
        fonts-dejavu-core \
        fonts-freefont-ttf \
        fonts-noto \
        fonts-noto-cjk \
        fonts-noto-cjk-extra \
        fonts-noto-color-emoji \
        fonts-noto-hinted \
        fonts-noto-mono \
        fonts-opensymbol \
        fonts-symbola \
        fonts-ubuntu \
        gucharmap \
        mpd \
        onboard \
        orage \
        parole \
        policykit-desktop-privileges \
        libpulse0 \
        pulseaudio \
        pavucontrol \
        ristretto \
        supervisor \
        thunar \
        thunar-volman \
        thunar-archive-plugin \
        thunar-media-tags-plugin \
        net-tools \
        libgtk-3-bin \
        libpci3 \
        libelf-dev \
        libglvnd-dev \
        vainfo \
        vdpauinfo \
        pkg-config \
        mesa-utils \
        mesa-utils-extra \
        libglu1 \
        libglu1:i386 \
        libsm6 \
        libxv1 \
        libxv1:i386 \
        libxtst6 \
        libxtst6:i386 \
        xdg-utils \
        x11-xkb-utils \
        x11-xserver-utils \
        x11-utils \
        x11-apps \
        dbus-x11 \
        libdbus-c++-1-0v5 \
        dmz-cursor-theme \
        numlockx \
        xauth \
        xcursor-themes \
        xinit \
        xfonts-base \
        xkb-data \
        libxrandr-dev \
        xorg \
        xubuntu-artwork \
        xfburn \
        xfpanel-switch \
        xfce4 \
        xfdesktop4 \
        xfwm4 \
        xfce4-appfinder \
        xfce4-clipman \
        xfce4-dict \
        xfce4-goodies \
        xfce4-notes \
        xfce4-notifyd \
        xfce4-panel \
        xfce4-screenshooter \
        xfce4-session \
        xfce4-settings \
        xfce4-taskmanager \
        xfce4-terminal \
        xfce4-appmenu-plugin \
        xfce4-battery-plugin \
        xfce4-clipman-plugin \
        xfce4-cpufreq-plugin \
        xfce4-cpugraph-plugin \
        xfce4-diskperf-plugin \
        xfce4-datetime-plugin \
        xfce4-fsguard-plugin \
        xfce4-genmon-plugin \
        xfce4-indicator-plugin \
        xfce4-mpc-plugin \
        xfce4-mount-plugin \
        xfce4-netload-plugin \
        xfce4-notes-plugin \
        xfce4-places-plugin \
        xfce4-pulseaudio-plugin \
        xfce4-sensors-plugin \
        xfce4-smartbookmark-plugin \
        xfce4-statusnotifier-plugin \
        xfce4-systemload-plugin \
        xfce4-timer-plugin \
        xfce4-verve-plugin \
        xfce4-weather-plugin \
        xfce4-whiskermenu-plugin \
        xfce4-xkb-plugin && \
    apt-get install -y libreoffice && \
    cp -rf /etc/xdg/xfce4/panel/default.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml && \
    if [ "${UBUNTU_RELEASE}" = "18.04" ]; then apt-get install --no-install-recommends -y vulkan-utils; else apt-get install --no-install-recommends -y vulkan-tools; fi && \
    # Support libva and VA-API through NVIDIA VDPAU
    curl -fsSL -o /tmp/vdpau-va-driver.deb "https://launchpad.net/~saiarcot895/+archive/ubuntu/chromium-dev/+files/vdpau-va-driver_0.7.4-6ubuntu2~ppa1~18.04.1_amd64.deb" && apt-get install --no-install-recommends -y /tmp/vdpau-va-driver.deb && rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

# Add custom packages below this comment

