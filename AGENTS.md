# Repository Guidelines

## Project Structure & Module Organization
- Vendor variants:
  - `intel/` — Intel GPU setup
  - `amd/` — AMD GPU setup
  - `nvidia/` — NVIDIA GPU setup
- Each contains: `Dockerfile`, `docker-compose.yml`, and `start.sh`.
- Top-level `compose.yml` pulls published images via profiles.
- OBS data lives in `obs-config/` (mounted to `/root/.config/obs-studio`).
  - Scenes: `obs-config/basic/scenes/`
  - Profiles: `obs-config/basic/profiles/`
  - Logs and settings: `obs-config/logs/`, `obs-config/*.ini`

## Build, Test, and Development Commands
- Use prebuilt images (recommended for users/Unraid):
  - Intel: `docker compose --profile intel -f compose.yml up -d`
  - AMD: `docker compose --profile amd -f compose.yml up -d`
  - NVIDIA: `docker compose --profile nvidia -f compose.yml up -d`
- Building locally (contributors): from a vendor dir, run `docker compose build && docker compose up -d`.
- Logs: `docker compose logs -f obs` (from the active dir), shell: `docker compose exec obs bash`.

Validation checklist (manual):
- Visit noVNC at `http://<host>:6081/vnc.html` and confirm OBS launches.
- Verify expected scene collection and profile load from `obs-config/basic/`.

## Coding Style & Naming Conventions
- YAML: 2‑space indents; lowercase, hyphenated keys where applicable.
- Bash (`*/start.sh`): Same structure across vendors; DEBUG logs, Xorg→Xvfb fallback with on-screen warning, optional VNC password. Run `shellcheck` on the modified file.
- Dockerfile: Keep layers focused; prefer official packages; validate with `hadolint`.
- Filenames: lowercase-with-dashes; keep OBS assets/config under `obs-config/`.

## Testing Guidelines
- No unit tests; use manual runs via Compose.
- When changing `intel/start.sh` or display settings, re-run `docker compose up` from `intel/` and confirm:
  - Xorg starts (check `/tmp/xorg.log` via `docker compose exec obs tail -n 100 /tmp/xorg.log`).
  - noVNC works at port 6081 and OBS UI is interactive.

## Commit & Pull Request Guidelines
- Commits: imperative mood, concise subject, focused scope (e.g., `obs: add NDI support`, `compose: host network + GPU`).
- PRs: describe rationale and behavior changes, include screenshots of OBS scenes/settings, list steps to validate, and note config file paths touched. Link related issues if any.

## Security & Configuration Tips
- Do not commit secrets; keep stream keys out of the repo.
- Host networking is enabled; audit exposed services before deploying.
- Backup `obs-config/` regularly; changes inside OBS modify these files.
- `.gitignore` excludes Unraid-generated files: `name`, `obs-config/`, and any `docker-compose.override.yml`.
