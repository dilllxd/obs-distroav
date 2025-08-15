FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# --- Base Dependencies ---
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl wget gnupg2 ca-certificates lsb-release sudo \
    x11vnc xserver-xorg-core xserver-xorg-video-all x11-utils x11-xserver-utils x11-apps xvfb \
    openbox xterm novnc websockify \
    python3 python3-websockify net-tools \
    libglib2.0-0 libsm6 libxrender1 libxext6 libjpeg-turbo8 \
    mesa-utils xinit xserver-xorg-input-all \
    dbus-x11 avahi-daemon ffmpeg pulseaudio && rm -rf /var/lib/apt/lists/*

# NVIDIA: rely on host driver via NVIDIA Container Toolkit; no driver install here.

# --- OBS Studio ---
RUN add-apt-repository -y ppa:obsproject/obs-studio && apt-get update && \
    apt-get install -y obs-studio && rm -rf /var/lib/apt/lists/*

# --- DistroAV ---
RUN wget https://github.com/DistroAV/DistroAV/releases/download/6.1.1/distroav-6.1.1-x86_64-linux-gnu.deb -O distroav.deb && \
    dpkg -i distroav.deb || apt-get install -f -y && \
    rm distroav.deb && rm -rf /var/lib/apt/lists/*

# --- libndi (NewTek NDI support) ---
RUN wget https://raw.githubusercontent.com/DistroAV/DistroAV/refs/heads/master/CI/libndi-get.sh && \
    chmod +x libndi-get.sh && \
    ./libndi-get.sh install && \
    rm libndi-get.sh

# --- Vertical Canvas Plugin ---
RUN wget https://github.com/Aitum/obs-vertical-canvas/releases/download/1.6.0-beta1/vertical-canvas-linux-gnu.deb -O vertical-canvas.deb && \
    dpkg -i vertical-canvas.deb || apt-get install -f -y && \
    rm vertical-canvas.deb && rm -rf /var/lib/apt/lists/*

# --- Teleport Plugin ---
RUN echo "Installing Teleport into /root/.config/obs-studio/plugins/obs-teleport/bin/64bit/obs-teleport.so" && \
    rm -rf /root/.config/obs-studio/plugins/obs-teleport && \
    mkdir -p /root/.config/obs-studio/plugins/obs-teleport/bin/64bit && \
    wget https://i.dylan.lol/u/obs-teleport.so -O /root/.config/obs-studio/plugins/obs-teleport/bin/64bit/obs-teleport.so

# --- Create OBS user and allow video access ---
RUN useradd -m -s /bin/bash obs && usermod -aG video obs && \
    mkdir -p /run/user/1001 && chown obs:obs /run/user/1001

WORKDIR /home/obs
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]

