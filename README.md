# Media Server Docker Stack

Complete Docker Compose setup for a media server with VPN, download client, and media management tools.

## Services Included

### VPN & Download (compose-vpn.yml)
- **Gluetun**: VPN client connected to NordVPN Serbia server
- **qBittorrent**: Torrent client (routes through Gluetun VPN) - accessible at http://synology-ip:8090

### Arr Stack (compose-arr.yml)
- **Prowlarr**: Indexer manager - http://synology-ip:9696
- **Sonarr**: TV show management - http://synology-ip:8989
- **Radarr**: Movie management - http://synology-ip:7878
- **Bazarr**: Subtitle management - http://synology-ip:6767

### Additional Services (compose-additional.yml)
- **Overseerr**: Media request management - http://synology-ip:5055
- **Cloudflared**: Cloudflare Tunnel for Overseerr external access
- **Stash**: Media organizer - http://synology-ip:9999
- **Cleanuparr**: Cleanup tool for arr apps
- **Huntarr**: Torrent tracker manager - http://synology-ip:8088

## Network Configuration

All services run on a custom bridge network `media_network` with fixed IPs:

- Gluetun/qBittorrent: 172.20.0.2
- Prowlarr: 172.20.0.10
- Sonarr: 172.20.0.11
- Radarr: 172.20.0.12
- Bazarr: 172.20.0.13
- Overseerr: 172.20.0.20
- Cloudflared: 172.20.0.21
- Stash: 172.20.0.22
- Cleanuparr: 172.20.0.23
- Huntarr: 172.20.0.24

Services can communicate using hostnames (e.g., `sonarr`, `radarr`, `qbittorrent`).

## Directory Structure

```
/volume1/
├── data/
│   ├── torrents/
│   │   ├── movies/
│   │   ├── tv/
│   │   └── music/
│   └── media/
│       ├── movies/
│       ├── tv/
│       └── music/
└── docker/
    └── appdata/
        ├── gluetun/
        ├── qbittorrent/
        ├── prowlarr/
        ├── sonarr/
        ├── radarr/
        ├── bazarr/
        ├── overseerr/
        ├── stash/
        ├── cleanuparr/
        └── huntarr/
```

## Installation Steps

### 1. Create Directory Structure

SSH into your Synology and run:

```bash
# Create torrent directories
mkdir -p /volume1/data/torrents/{movies,tv,music}

# Create media directories
mkdir -p /volume1/data/media/{movies,tv,music}

# Create appdata directories
mkdir -p /volume1/docker/appdata/{gluetun,qbittorrent,prowlarr,sonarr,radarr,bazarr,overseerr,stash,cleanuparr,huntarr}
```

### 2. Get PUID and PGID

Find your docker user's ID:

```bash
id docker
```

Note the `uid` (PUID) and `gid` (PGID) values.

### 3. Configure Environment Variables

Edit the `.env` file:

```bash
cd /volume1/docker/appdata
nano .env
```

Update these critical values:
- `PUID` and `PGID` (from step 2)
- `OPENVPN_USER` and `OPENVPN_PASSWORD` (your NordVPN credentials)
- `TUNNEL_TOKEN` (your Cloudflare Tunnel token)
- `TZ` (your timezone, e.g., `Europe/Belgrade`)

### 4. Create Docker Network

```bash
docker network create media_network \
  --subnet 172.20.0.0/16 \
  --gateway 172.20.0.1
```

### 5. Set Permissions

```bash
sudo chown -R docker:users /volume1/data /volume1/docker
sudo chmod -R a=,a+rX,u+w,g+w /volume1/data /volume1/docker
```

### 6. Deploy Services

Navigate to the directory containing the compose files:

```bash
cd /volume1/docker/appdata
```

#### Option A: Start All Services

```bash
docker-compose up -d
```

#### Option B: Start Services by Group

```bash
# Start VPN and qBittorrent first
docker-compose -f compose-vpn.yml up -d

# Wait for VPN to connect, then start Arr services
docker-compose -f compose-arr.yml up -d

# Finally start additional services
docker-compose -f compose-additional.yml up -d
```

### 7. Verify VPN Connection

Check if qBittorrent is using the VPN:

```bash
# Check Gluetun logs
docker logs gluetun

# Check your IP from qBittorrent container
docker exec -it gluetun wget -qO- ifconfig.me
```

## Configuration Guide

### qBittorrent Setup

1. Access WebUI at http://synology-ip:8090
2. Default credentials: `admin` / `adminadmin` (change immediately!)
3. In Settings > Downloads:
   - Default Save Path: `/data/torrents`
   - Create subfolders: Enable Category subfolder
4. In Settings > Categories:
   - Add categories: `movies`, `tv`, `music`
   - Set paths to `/data/torrents/movies`, `/data/torrents/tv`, etc.

### Prowlarr Setup

1. Access at http://synology-ip:9696
2. Add indexers
3. Add applications (Sonarr, Radarr) using hostnames:
   - Sonarr: `http://sonarr:8989`
   - Radarr: `http://radarr:7878`

### Sonarr/Radarr Setup

1. Access Sonarr at http://synology-ip:8989
2. Access Radarr at http://synology-ip:7878
3. Add Download Client (qBittorrent):
   - Host: `gluetun` (since qBittorrent uses Gluetun's network)
   - Port: `8090`
4. Add Root Folders:
   - Sonarr: `/data/media/tv`
   - Radarr: `/data/media/movies`
5. Remote Path Mappings (if needed):
   - Host: `gluetun`
   - Remote Path: `/data/torrents/`
   - Local Path: `/data/torrents/`

### Bazarr Setup

1. Access at http://synology-ip:6767
2. Connect to Sonarr and Radarr using hostnames
3. Configure subtitle providers

### Overseerr Setup

1. Access at http://synology-ip:5055
2. Connect to Sonarr and Radarr using hostnames
3. Configure Cloudflare Tunnel for external access

## Troubleshooting

### qBittorrent Can't Connect

If Arr apps can't connect to qBittorrent:
- Use hostname `gluetun` instead of `qbittorrent` (they share the network stack)
- Port: `8090`

### VPN Not Connecting

Check Gluetun logs:
```bash
docker logs gluetun -f
```

Verify NordVPN credentials in `.env` file.

### Permission Issues

Re-run permission commands:
```bash
sudo chown -R docker:users /volume1/data /volume1/docker
sudo chmod -R a=,a+rX,u+w,g+w /volume1/data /volume1/docker
```

### Service Won't Start

Check logs:
```bash
docker logs <container-name>
```

Ensure directories exist and have correct permissions.

## Management Commands

```bash
# View all running containers
docker-compose ps

# View logs
docker-compose logs -f <service-name>

# Restart a service
docker-compose restart <service-name>

# Stop all services
docker-compose down

# Update services
docker-compose pull
docker-compose up -d

# Remove everything (including volumes)
docker-compose down -v
```

## Notes

- **VPN Kill Switch**: qBittorrent traffic is forced through Gluetun. If VPN disconnects, qBittorrent loses internet access.
- **Hardlinks**: The data structure follows TRaSH Guides recommendations for hardlinks and instant moves.
- **Backups**: Regularly backup `/volume1/docker/appdata` directory.
- **Updates**: Consider using Watchtower or Diun for automatic updates.

## Security Recommendations

1. Change default passwords immediately
2. Use strong passwords for all services
3. Enable authentication on all web interfaces
4. Keep Cloudflare Tunnel token secure
5. Regular security updates: `docker-compose pull && docker-compose up -d`

## Resources

- [TRaSH Guides](https://trash-guides.info/)
- [Servarr Wiki](https://wiki.servarr.com/)
- [Gluetun Wiki](https://github.com/qdm12/gluetun-wiki)
- [LinuxServer.io Docs](https://docs.linuxserver.io/)
