# ComfyUI ROCm Docker (Radeon 9000 Series / RDNA 4)

This setup provides a high-performance, storage-optimized Docker container for running ComfyUI on AMD Radeon 9000 series GPUs (RDNA 4 architecture). It uses **ROCm 7.1** and **PyTorch 2.9.1** native libraries for compatibility with the latest hardware features.

## Features
- **RDNA 4 Native:** Optimized for GFX1201 (Radeon 9000 series) using official ROCm 7.1 drivers.
- **Batteries Included:** Pre-installed with ComfyUI-Manager, Git, FFmpeg, and critical dependencies (`torchsde`, `av`, `soundfile`).
- **Persistence:** Docker volumes for models, outputs, and user data to keep your workflow intact.

## Prerequisites
1. **Operating System:** Linux (Kernel 6.x+ recommended for RDNA 4 support).
2. **Host Drivers:** Make sure the latest AMDGPU drivers and ROCm are installed on your host machine.
3. **User Groups:** Your user must be part of the `video` and `render` groups on the host:
```bash
sudo usermod -aG video $USER
sudo usermod -aG render $USER
```
4. **Docker:** Make sure Docker and the Docker Compose plugin are installed.

## Installation and Launch

1. **Clone & Prepare:**
   Clone this repository and create your storage directories.
```bash
mkdir -p storage/ComfyUI/models
mkdir -p storage/ComfyUI/output
```

2. **Configure Permissions (.env)**
   Copy the example environment file and find your system IDs to ensure Docker has the correct permissions to write to your `storage` folder.

```bash
cp .env.example .env
```

   Run the following to find the `video` and `render` GIDs:
```bash
grep -E 'video|render' /etc/group
```
   *Example Output:* `video:x:985:user`, `render:x:989:user`.

   Run the following to find your personal User ID (`PUID`) and Group ID (`PGID`):
```bash
id -u  # Returns PUID (likely 1000)
id -g  # Returns PGID (likely 1000)
```

   Open `.env` and update it with your findings:
```ini
# GPU Access (Arch/Linux specific)
VIDEO_GID=985
RENDER_GID=989

# File Ownership (Matches your Arch User)
PUID=1000
PGID=1000

# Unified Storage Path
BASE_STORAGE_PATH=./storage
```

3. **Build and Start:**
   Run the container (this will build the optimized image):
```bash
docker compose up --build -d
```

4. **Access UI:**
   Navigate to `http://localhost:8188` in your web browser.

## Configuration Details

This project uses specific environment variables to enable RDNA 4 support:
- **`HSA_OVERRIDE_GFX_VERSION=12.0.1`**: Forces the ROCm driver to target the RDNA 4 instruction set (Navi 48).
- **`PYTORCH_ROCM_ARCH=gfx1201`**: Makes sure PyTorch compiles kernels for the correct GPU architecture.
- **`--lowvram`**: The start command includes this flag to optimize VRAM usage. If you have a 9070 XT (16GB) and want to maximize speed over VRAM efficiency, you can remove this flag in `docker-compose.yml`.

## Folder Structure
- **`./comfyui_data`**: Persists your custom nodes, manager config, and user settings.
- **`./storage/ComfyUI/models`**: Place your Checkpoints, LoRAs, VAEs, and ControlNets here.
- **`./storage/ComfyUI/output`**: Generated images and videos are saved here.

## Troubleshooting

### "Permission Denied" on /dev/dri/renderD128
This means the Group IDs in your `.env` file do not match your host system. Run `grep -E 'video|render' /etc/group` again and make sure the numbers in `.env` match exactly, then restart the container:
```bash
docker compose down
docker compose up -d
```

### GPU Not Detected
If ComfyUI starts but runs on CPU, check if the container can see the card:
```bash
docker exec -it <container_name> rocm-smi
```
If this fails, make sure your host kernel supports your GPU and that `HSA_OVERRIDE_GFX_VERSION` is set in the compose file.

### Missing Custom Nodes After Rebuild
If a custom node (e.g., `audio-separation-nodes`) does not appear after a container recreation despite being in the `custom_nodes` directory:

1. **Dependency Conflict:** The node may have failed its internal install script. Check logs: `docker compose logs | grep "import"`.
2. **Reinstallation Fix:**
   - Open **ComfyUI Manager**.
   - **Uninstall** the problematic node.
   - **Restart** the container: `docker compose restart`.
   - **Reinstall** the node via the Manager.
   - **Restart** once more.
   This forces the node to re-run its setup script within the current environment and makes sure all local binaries are written to your persistent volume.

