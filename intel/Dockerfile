FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# other packages/mostly required ones?

RUN apt-get update && apt-get install -y \
    software-properties-common sudo wget gnupg curl nano \
    xserver-xorg-video-all x11vnc fluxbox xinit mesa-utils \
    libva2 vainfo intel-media-va-driver-non-free pulseaudio dbus unzip \
    libgl1-mesa-dri libgl1 x11-xserver-utils

# intel required stuff

RUN add-apt-repository -y ppa:kobuk-team/intel-graphics && apt-get update

RUN apt-get install -y \
    libze-intel-gpu1 libze1 intel-metrics-discovery intel-opencl-icd clinfo intel-gsc \
    intel-media-va-driver-non-free libmfx-gen1 libvpl2 libvpl-tools libva-glx2 va-driver-all vainfo

# obs install

RUN add-apt-repository -y ppa:obsproject/obs-studio && apt-get update && apt-get install -y obs-studio

# fix issue with letting any user make x11 instance

RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

# distroav (ndi)

RUN wget https://github.com/DistroAV/DistroAV/releases/download/6.1.1/distroav-6.1.1-x86_64-linux-gnu.deb -O distroav.deb \
    && dpkg -i distroav.deb || apt-get install -f -y \
    && rm distroav.deb

# libndi install stuff

RUN wget https://raw.githubusercontent.com/DistroAV/DistroAV/refs/heads/master/CI/libndi-get.sh \
    && chmod +x libndi-get.sh \
    && ./libndi-get.sh install \
    && rm libndi-get.sh

RUN apt-get install -y avahi-daemon ffmpeg

# web vnc

RUN apt-get install -y git python3 python3-pip && \
    pip3 install --break-system-packages websockify && \
    git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

RUN mkdir -p /run/dbus

EXPOSE 5911 6080

WORKDIR /root

COPY start.sh /root/start.sh
RUN chmod +x /root/start.sh

ENTRYPOINT ["/root/start.sh"]
