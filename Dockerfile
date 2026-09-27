FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

RUN apt-get update && apt-get install -y \
    kali-desktop-xfce \
    xfce4-terminal \
    firefox-esr \
    novnc \
    websockify \
    x11vnc \
    xvfb \
    dbus-x11 \
    curl \
    ca-certificates \
    coreutils \
    netcat-openbsd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash kali

COPY start.sh /start.sh
RUN chmod +x /start.sh

USER kali
WORKDIR /home/kali

EXPOSE 6080

CMD ["/start.sh"]
