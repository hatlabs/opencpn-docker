# OpenCPN Docker - Developer Guide

Docker image for OpenCPN marine navigation software with Selkies web-based remote desktop.

## Repository Purpose

This repository packages [OpenCPN](https://opencpn.org/) into a Docker container with web browser access using [Selkies](https://github.com/selkies-project/selkies). It's part of the HaLOS marine computing ecosystem.

## Structure

```
opencpn-docker/
├── Dockerfile              # Multi-arch Docker image definition
├── .github/workflows/      # CI/CD automation
│   └── build.yml          # Build and publish workflow
├── README.md              # User documentation
├── LICENSE                # GPL-2.0 License
└── CLAUDE.md              # This file
```

## Architecture

### Base Image
Uses `ghcr.io/linuxserver/baseimage-selkies:ubuntunoble` which provides:
- Ubuntu Noble base
- Selkies web desktop stack (WebRTC, HTML5)
- GPU acceleration support via DRI3
- Built-in web server (NGINX) and authentication
- File upload/download capabilities

### OpenCPN Installation
- Installed from official PPA: `ppa:opencpn/opencpn`
- Includes `xcalib` for night mode screen dimming
- All dependencies handled by PPA package

### Ports
- **3000**: HTTP web interface (internal)
- **3001**: HTTPS web interface (internal, self-signed cert)
- **8082**: WebSocket connection (internal)

## Building

### Local Build

```bash
# Simple build for current architecture
docker build -t opencpn:test .

# Multi-architecture build
docker buildx build --platform linux/amd64,linux/arm64 -t opencpn:test .
```

### GitHub Actions

The workflow automatically builds and publishes images on:
- Push to `main` branch → `ghcr.io/hatlabs/opencpn-docker:main`, `:latest`
- Tags matching `v*` → `ghcr.io/hatlabs/opencpn-docker:v1.0.0`, etc.

**CRITICAL**: After first build, make package public:
1. Go to https://github.com/orgs/hatlabs/packages/container/opencpn-docker/settings
2. Change visibility to "Public"

## Testing

### Quick Test

```bash
# Run container
docker run -d --name opencpn-test -p 3020:3000 --shm-size=1gb opencpn:test

# Check logs
docker logs opencpn-test

# Test web interface
open http://localhost:3020

# Clean up
docker rm -f opencpn-test
```

### Full Test with GPU

```bash
docker run -d \
  --name opencpn-test \
  -p 3020:3000 \
  -v $(pwd)/test-config:/config \
  --device=/dev/dri:/dev/dri \
  --shm-size=1gb \
  -e DRI_NODE=/dev/dri/renderD128 \
  opencpn:test
```

### Test Chart Upload

1. Access http://localhost:3020
2. Click folder icon in Selkies toolbar
3. Upload a test chart file
4. In OpenCPN: Options → Charts → Add Directory → /config/charts
5. Verify chart appears

## Updating OpenCPN Version

The PPA automatically provides the latest stable version. To update:

1. Rebuild the image (no Dockerfile changes needed)
2. Test the new version
3. Tag and push

If OpenCPN changes PPAs or requires different installation:
1. Update `add-apt-repository` line in Dockerfile
2. Test build
3. Update version in README.md
4. Commit and push

## Integration with HaLOS

This repository is part of the `halos-distro` workspace and integrates with:
- **runtipi-marine-app-store**: App store entry for easy installation
- **halos-pi-gen**: Can be pre-loaded in HaLOS images

## Selkies Environment Variables

Key variables that can be customized:

**Display:**
- `CUSTOM_RES_W/H`: Screen resolution
- `SELKIES_ENABLE_RESIZE`: Responsive scaling
- `SELKIES_FRAMERATE`: Frame rate limits

**GPU:**
- `DRI_NODE`: Enable VAAPI/DRI3 acceleration
- `DRINODE`: Specify GPU device

**Security:**
- `CUSTOM_USER`: Basic auth username
- `PASSWORD`: Basic auth password

**UI:**
- `TITLE`: Browser tab title
- `SELKIES_UI_SIDEBAR_SHOW_*`: Toggle UI elements
- `SELKIES_FILE_TRANSFERS`: Enable/disable file ops

See [baseimage-selkies docs](https://github.com/linuxserver/docker-baseimage-selkies) for complete list.

## Common Issues

### Build Failures

- Ensure Ubuntu Noble repos are accessible
- Check PPA availability: `ppa:opencpn/opencpn`
- Verify multi-arch build has QEMU setup correctly

### Runtime Issues

- **Black screen**: Ensure `--shm-size=1gb` is set (required)
- **No GPU acceleration**: Check `/dev/dri` permissions and DRI_NODE setting
- **Charts not loading**: Verify charts are in `/config/charts/`
- **Poor performance**: Enable GPU acceleration, increase resources

### Web Interface Issues

- **Connection refused**: Verify port 3000 is exposed and accessible
- **WebRTC errors**: Check browser compatibility (Chrome/Firefox recommended)
- **File upload fails**: Check `/config` volume permissions

## Contributing

1. Test changes locally first
2. Update documentation (README.md, CLAUDE.md)
3. Follow conventional commit format
4. Ensure GitHub Actions workflow passes
5. Make package public after merge

## Upstream

- **OpenCPN Project**: https://opencpn.org/
- **OpenCPN GitHub**: https://github.com/OpenCPN/OpenCPN
- **OpenCPN License**: GPL-2.0
- **Selkies Project**: https://github.com/selkies-project/selkies
- **linuxserver.io baseimage**: https://github.com/linuxserver/docker-baseimage-selkies
