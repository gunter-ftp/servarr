# Quick Reference: Service URLs and Configuration

## Service Access URLs

After starting the stack, access your services at:

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| qBittorrent | http://your-synology-ip:8090 | admin / adminadmin |
| Prowlarr | http://your-synology-ip:9696 | (set on first login) |
| Sonarr | http://your-synology-ip:8989 | (set on first login) |
| Radarr | http://your-synology-ip:7878 | (set on first login) |
| Bazarr | http://your-synology-ip:6767 | (set on first login) |
| Overseerr | http://your-synology-ip:5055 | (set on first login) |
| Stash | http://your-synology-ip:9999 | (set on first login) |
| Huntarr | http://your-synology-ip:8088 | (set on first login) |

## Service Hostnames for Internal Communication

When configuring services to talk to each other, use these hostnames:

| Service | Hostname | Port |
|---------|----------|------|
| qBittorrent | `gluetun` | 8090 |
| Prowlarr | `prowlarr` | 9696 |
| Sonarr | `sonarr` | 8989 |
| Radarr | `radarr` | 7878 |
| Bazarr | `bazarr` | 6767 |
| Overseerr | `overseerr` | 5055 |
| Stash | `stash` | 9999 |
| Huntarr | `huntarr` | 8088 |

**Important**: qBittorrent uses `gluetun` as hostname because it shares Gluetun's network stack.

## Path Configuration

Use these paths when configuring services:

### qBittorrent
- Downloads: `/data/torrents`
- Category paths:
  - Movies: `/data/torrents/movies`
  - TV: `/data/torrents/tv`
  - Music: `/data/torrents/music`

### Sonarr
- Root Folder: `/data/media/tv`
- Download Client (qBittorrent):
  - Host: `gluetun`
  - Port: `8090`
  - Category: `tv`

### Radarr
- Root Folder: `/data/media/movies`
- Download Client (qBittorrent):
  - Host: `gluetun`
  - Port: `8090`
  - Category: `movies`

### Bazarr
- Movies: `/data/media/movies`
- TV Shows: `/data/media/tv`

## Quick Start Commands

```bash
# Start everything
docker-compose up -d

# Start only VPN and download client
docker-compose -f compose-vpn.yml up -d

# Start only Arr services
docker-compose -f compose-arr.yml up -d

# Start only additional services
docker-compose -f compose-additional.yml up -d

# View logs
docker-compose logs -f

# Stop everything
docker-compose down

# Update all images
docker-compose pull && docker-compose up -d

# Restart a specific service
docker-compose restart sonarr
```

## Verification Commands

```bash
# Check VPN IP (should show Serbia server IP)
docker exec gluetun wget -qO- ifconfig.me

# Check qBittorrent connection
docker logs qbittorrent | grep -i "connected"

# Check all running containers
docker-compose ps

# View specific container logs
docker logs -f <container-name>
```

## Configuration Order

1. **Start VPN and qBittorrent** first
   ```bash
   docker-compose -f compose-vpn.yml up -d
   ```

2. **Configure qBittorrent**
   - Change password
   - Set categories
   - Configure paths

3. **Start Prowlarr**
   ```bash
   docker-compose -f compose-arr.yml up -d prowlarr
   ```

4. **Configure Prowlarr**
   - Add indexers
   - Add Sonarr/Radarr apps (use hostnames)

5. **Start remaining Arr services**
   ```bash
   docker-compose -f compose-arr.yml up -d
   ```

6. **Configure Sonarr/Radarr**
   - Add qBittorrent (host: `gluetun`)
   - Add root folders
   - Test Prowlarr sync

7. **Start additional services**
   ```bash
   docker-compose -f compose-additional.yml up -d
   ```

8. **Configure Overseerr**
   - Connect to Sonarr/Radarr
   - Setup Cloudflare Tunnel

## Troubleshooting

### Can't connect to qBittorrent from Arr apps
Use `gluetun` as hostname, not `qbittorrent`

### VPN not connecting
Check credentials in .env file and view logs:
```bash
docker logs gluetun
```

### Permission denied errors
Re-run permissions script:
```bash
sudo bash setup.sh
```

### Service won't start
Check logs for the specific service:
```bash
docker logs <service-name>
```

## Important Notes

- **Always use `gluetun` hostname** when configuring qBittorrent connections from other services
- **Test VPN connection** before adding downloads
- **Backup** your `/volume1/docker/appdata` directory regularly
- **Update regularly** using `docker-compose pull && docker-compose up -d`
