services:
  tor:
    image: dperson/torproxy:latest
    container_name: kali-tor
    restart: unless-stopped

  kali-browser:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: kali-browser
    restart: unless-stopped
    shm_size: "2gb"

    depends_on:
      - tor

    environment:
      TOR_PROXY: "tor:9050"

    ports:
      - "0.0.0.0:6080:6080"

    security_opt:
      - seccomp=unconfined
