# OBS DistroAV — OBS in Docker with GPU Acceleration

Run OBS Studio in containers with GPU acceleration (Intel, AMD, NVIDIA). Prebuilt images available via Compose profiles and a simple web UI over noVNC.

Repository: https://github.com/dilllxd/obs-distroav

## Quick Start (Prebuilt Images)

Requirements: Docker + Docker Compose v2

- Intel: `docker compose --profile intel -f compose.yml up -d`
- AMD: `docker compose --profile amd -f compose.yml up -d`
- NVIDIA: `docker compose --profile nvidia -f compose.yml up -d`

Open noVNC: `http://<host>:6081/vnc.html`

Environment (optional): set in a `.env` next to `compose.yml`

- `VNC_PASSWORD` — password for x11vnc/noVNC (blank = none)
- `RESOLUTION` — display size, default `1920x1080`
- `DEBUG` — set `1` for verbose startup logs

Images on GHCR:

- `ghcr.io/dilllxd/obs-distroav:intel`
- `ghcr.io/dilllxd/obs-distroav:amd`
- `ghcr.io/dilllxd/obs-distroav:nvidia`

## Persistence

Data is stored in `/root/.config/obs-studio` inside the container. The provided Compose files bind‑mount a host folder to this path by default. Adjust the mount to suit your environment (Unraid templates can override it).

## Local Build (Contributors)

From a vendor folder (`intel/`, `amd/`, `nvidia/`):

- Build + run: `docker compose up -d`
- Logs: `docker compose logs -f obs`
- Shell: `docker compose exec obs bash`

## Notes

- Xorg is used when possible; if unavailable, the container falls back to Xvfb (no GPU) and shows a brief on‑screen warning.
- NVIDIA requires the NVIDIA Container Toolkit on the host.
- For diagnostics, check `/tmp/xorg.log` in the container and set `DEBUG=1`.

### Unraid
- In the template, select `br0` (custom network). No host networking or privileged mode needed. Access: `http://<container-ip>:6081/vnc.html` (VNC on `5900`). If browser sources are unstable, set Extra Parameters to `--shm-size=512m`.

## License

MIT for this repository’s code. OBS Studio and DistroAV are third‑party software with their own licenses.
