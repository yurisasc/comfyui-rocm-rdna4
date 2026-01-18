FROM rocm/pytorch:rocm7.1_ubuntu24.04_py3.13_pytorch_release_2.9.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    git libgl1 libglib2.0-0 libsndfile1 ffmpeg \
    libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev \
    libswscale-dev wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace/ComfyUI

RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

RUN pip3 install --no-cache-dir -U pip && \
    pip3 install --no-cache-dir multidict typing_extensions aiohttp huggingface_hub trampoline kornia_rs && \
    grep -vE '^(torch|torchvision|torchaudio)' requirements.txt > req_no_torch.txt && \
    pip3 install --no-cache-dir -r req_no_torch.txt && \
    pip3 install --no-cache-dir torchsde einops transformers av soundfile gitpython toml

# This allows ComfyUI-Manager to install things later and create temp files.
RUN chown -R 1000:1000 /workspace /opt/venv

RUN cd custom_nodes && git clone https://github.com/ltdrdata/ComfyUI-Manager.git

RUN rm req_no_torch.txt
WORKDIR /workspace/ComfyUI
