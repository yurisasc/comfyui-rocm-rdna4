# ComfyUI ROCm Docker (Radeon 9000 Series / RDNA 4)

This setup provides a high-performance Docker container for running ComfyUI on AMD Radeon 9000 series GPUs (RDNA 4 architecture). It utilizes ROCm 7.1 and PyTorch 2.9.1 to ensure compatibility with the latest hardware features.

## Features
- **Hardware Support:** Optimized for GFX1201 (Radeon 9000 series).
- **Environment:** Ubuntu 24.04, Python 3.13, and ROCm 7.1.
- **Pre-installed:** Includes ComfyUI-Manager and essential media libraries (FFmpeg, Libav).
- **Persistence:** Docker volumes for models and user data to keep your workflow intact.

## Prerequisites
1. **Host Drivers:** Make sure the latest AMDGPU drivers are installed on your host machine.
2. **Permissions:** Your user must be part of the video and render groups:
   ```bash
   sudo usermod -aG video $USER
   sudo usermod -aG render $USER
   ```
3. **Docker Compose:** Ensure Docker and the Docker Compose plugin are installed.

## Installation and Launch
1. **Model Directory:** Make sure you have a directory at `./storage/ComfyUI/models` to store your checkpoints.
2. **Build and Start:** Run the command: `docker compose up --build -d`
3. **Access UI:** Navigate to `http://localhost:8188` in your web browser.

## Configuration Details
This project uses specific environment variables to enable RDNA 4 support, as some ROCm versions require explicit overrides for newer hardware:
- `HSA_OVERRIDE_GFX_VERSION=12.0.1`: Targets the RDNA 4 instruction set.
- `PYTORCH_ROCM_ARCH=gfx1201`: Makes sure PyTorch uses the correct GPU architecture.
- **IPC Host:** Used for better performance and memory management between the host and container.
- **Low VRAM:** The container starts with the `--lowvram` and `--force-fp16` so it uses minimal VRAM. This config may affect generation qualty, so adjust as needed as per [the documentation](https://docs.comfy.org/interface/settings/server-config).

## Folder Structure
- `./comfyui_data`: Persists your custom nodes, web settings, and user data.
- `./storage/ComfyUI/models`: Your central repository for Checkpoints, LoRAs, VAEs, etc.

## Troubleshooting
- **GPU Detection:** If the GPU is not detected, run 'docker exec -it <container_name> rocm-smi' to check if the card is visible inside the environment.
- **Permissions:** If you get "Permission Denied" errors on /dev/dri, ensure the 'video' group ID in the container matches your host's group ID or run with elevated privileges.
