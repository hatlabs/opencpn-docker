# OpenCPN Docker

Docker image for [OpenCPN](https://opencpn.org/) - a full-featured chartplotter and marine GPS navigation software, accessible via web browser using [Selkies](https://github.com/selkies-project/selkies).

## Overview

OpenCPN is a free and open-source chartplotter and navigation software for recreational sailors and boaters. This Docker image packages OpenCPN with Selkies, a web-native remote desktop platform, allowing you to access OpenCPN through any modern web browser without needing VNC clients or remote desktop software.

## Features

- **Browser-Based Access**: Access OpenCPN from any device with a web browser
- **No VNC Client Required**: Uses WebRTC technology for low-latency streaming
- **GPU Acceleration**: Hardware-accelerated rendering for smooth chart display
- **File Upload/Download**: Easy chart management through web interface
- **Multi-Architecture**: Supports ARM64 (Raspberry Pi) and AMD64
- **Persistent Storage**: Configuration and charts stored in Docker volumes
- **Night Mode Support**: Includes xcalib for screen dimming

## Quick Start

```bash
docker run -d \
  --name opencpn \
  -p 3020:3000 \
  -v opencpn-config:/config \
  --device=/dev/dri:/dev/dri \
  --shm-size=1gb \
  ghcr.io/hatlabs/opencpn-docker:latest
```

Access OpenCPN at `http://localhost:3020`

## Configuration

### Volumes

- `/config` - OpenCPN configuration, charts, and user data

### Ports

- `3000` - HTTP web interface (map to your preferred external port)
- `3001` - HTTPS web interface (optional, self-signed certificate)
- `8082` - WebSocket connection (used internally)

### Environment Variables

**Display Settings:**
- `CUSTOM_RES_W` - Browser width resolution (default: 1920)
- `CUSTOM_RES_H` - Browser height resolution (default: 1080)
- `SELKIES_ENABLE_RESIZE=true` - Enable responsive resolution scaling

**GPU Acceleration:**
- `DRI_NODE=/dev/dri/renderD128` - Enable hardware acceleration

**Authentication (Optional):**
- `CUSTOM_USER` - HTTP Basic auth username
- `PASSWORD` - HTTP Basic auth password

**UI Customization:**
- `TITLE=OpenCPN` - Browser tab title (default)
- `SELKIES_ENABLE_CLIPBOARD_SYNC=true` - Enable clipboard sharing

## Using OpenCPN

### First Launch

1. Access the web interface at your configured port
2. OpenCPN will launch automatically in the browser
3. Complete the initial setup wizard
4. Configure chart directories and data sources

### Managing Charts

**Upload Charts via Web Interface:**
1. Click the folder icon in the Selkies toolbar
2. Use the upload feature to transfer chart files
3. Charts will be saved in `/config/charts/`
4. In OpenCPN, add the chart directory: Options → Charts → Add Directory

**Alternative - Docker Volume:**
```bash
# Copy charts directly to the volume
docker cp /path/to/charts opencpn:/config/charts/
```

### NMEA Data Sources

Configure NMEA connections in OpenCPN:
- **Network**: Connect to Signal K or other NMEA servers
- **Serial**: Mount serial devices with `--device=/dev/ttyUSB0`
- **File Playback**: Upload NMEA log files for replay

## Hardware Acceleration

For optimal performance, enable GPU acceleration:

```bash
docker run -d \
  --name opencpn \
  -p 3020:3000 \
  -v opencpn-config:/config \
  --device=/dev/dri:/dev/dri \
  --shm-size=1gb \
  -e DRI_NODE=/dev/dri/renderD128 \
  ghcr.io/hatlabs/opencpn-docker:latest
```

**Requirements:**
- Intel or AMD GPU with DRI3 support
- Proper GPU drivers installed on host

Falls back to software rendering if GPU unavailable.

## Advanced Usage

### With Authentication

```bash
docker run -d \
  --name opencpn \
  -p 3020:3000 \
  -v opencpn-config:/config \
  -e CUSTOM_USER=admin \
  -e PASSWORD=your-secure-password \
  --device=/dev/dri:/dev/dri \
  --shm-size=1gb \
  ghcr.io/hatlabs/opencpn-docker:latest
```

### Custom Resolution

```bash
docker run -d \
  --name opencpn \
  -p 3020:3000 \
  -v opencpn-config:/config \
  -e CUSTOM_RES_W=2560 \
  -e CUSTOM_RES_H=1440 \
  --device=/dev/dri:/dev/dri \
  --shm-size=1gb \
  ghcr.io/hatlabs/opencpn-docker:latest
```

## Building Locally

```bash
docker build -t opencpn:local .
```

For multi-architecture builds:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t opencpn:local .
```

## Documentation

- [OpenCPN Official Website](https://opencpn.org/)
- [OpenCPN User Manual](https://opencpn.org/wiki/dokuwiki/doku.php?id=opencpn:opencpn_user_manual)
- [Selkies Project](https://github.com/selkies-project/selkies)
- [linuxserver.io Selkies Baseimage](https://github.com/linuxserver/docker-baseimage-selkies)

## Troubleshooting

### Black Screen or No Display

- Ensure `--shm-size=1gb` is set (required for Chromium-based Selkies)
- Check browser console for WebRTC errors
- Verify port 3000 is accessible

### Poor Performance

- Enable GPU acceleration with `--device=/dev/dri`
- Check GPU driver installation on host
- Increase allocated resources (CPU/RAM)

### Charts Not Appearing

- Verify charts are in `/config/charts/` directory
- In OpenCPN: Options → Charts → Add Directory
- Force chart database rebuild if needed

## License

This Docker image is licensed under GPL-2.0, matching the upstream OpenCPN project. See [LICENSE](LICENSE) for details.

OpenCPN is licensed under GPL-2.0. Selkies and related components have their own licenses.

## Contributing

Contributions are welcome! Please open an issue or pull request on the [GitHub repository](https://github.com/hatlabs/opencpn-docker).

## Support

For issues with this Docker image, open an issue on GitHub. For OpenCPN-specific questions, refer to the [OpenCPN documentation](https://opencpn.org/wiki/dokuwiki/) or [OpenCPN forums](https://www.cruisersforum.com/forums/f134/).
