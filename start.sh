#!/bin/bash
set -e

export DISPLAY=:1
TOR_HOST="${TOR_PROXY:-tor:9050}"

echo "======================================"
echo "       KALI TOR BROWSER STARTUP"
echo "======================================"

echo "[+] User: $(whoami)"
echo "[+] Host: $(hostname)"
echo

echo "[+] Waiting for Tor..."

until nc -z "${TOR_HOST%:*}" "${TOR_HOST##*:}" 2>/dev/null; do
    sleep 2
done

echo "[+] Tor SOCKS proxy available: $TOR_HOST"
echo

echo "[+] Checking Tor exit IP..."

TOR_RESULT=$(
    curl \
      --socks5-hostname "$TOR_HOST" \
      --connect-timeout 10 \
      --max-time 20 \
      -s \
      https://check.torproject.org/api/ip
)

echo "$TOR_RESULT"
echo

echo "[+] Starting X server..."

Xvfb :1 -screen 0 1920x1080x24 &
sleep 2

echo "[+] Starting XFCE..."

dbus-launch --exit-with-session startxfce4 &
sleep 5

echo "[+] Configuring Firefox..."

mkdir -p /home/kali/.mozilla/firefox

cat > /home/kali/firefox-tor.js <<EOF
user_pref("network.proxy.type", 1);
user_pref("network.proxy.socks", "${TOR_HOST%:*}");
user_pref("network.proxy.socks_port", ${TOR_HOST##*:});
user_pref("network.proxy.socks_remote_dns", true);
user_pref("network.trr.mode", 5);
user_pref("network.proxy.no_proxies_on", "");
EOF

echo "[+] Starting Firefox through Tor..."

firefox-esr \
    --no-remote \
    --new-instance \
    --profile /home/kali/.mozilla/firefox/tor-profile \
    &
    
sleep 5

echo "[+] Starting VNC server..."

x11vnc \
    -display :1 \
    -forever \
    -shared \
    -rfbport 5900 \
    -nopw \
    -listen 0.0.0.0 &

echo "[+] Starting noVNC on 0.0.0.0:6080..."

exec websockify \
    --web=/usr/share/novnc \
    0.0.0.0:6080 \
    127.0.0.1:5900
