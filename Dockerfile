FROM rocm/pytorch:rocm7.1_ubuntu24.04_py3.13_pytorch_release_2.9.1

WORKDIR /workspace/ComfyUI

ENV PATH="/workspace/ComfyUI/venv/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    python3-venv \
    libgl1 \
    libglib2.0-0 \
    libsndfile1 \
    ffmpeg \
    libavcodec-dev \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libswscale-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

RUN python3 -m venv --system-site-packages venv

RUN venv/bin/pip3 install --no-cache-dir -U pip && \
    venv/bin/pip3 install --no-cache-dir multidict typing_extensions aiohttp huggingface_hub trampoline kornia_rs && \
    venv/bin/pip3 install --no-cache-dir -r requirements.txt

RUN venv/bin/pip3 install --no-cache-dir \
    torch==2.9.1+rocm6.4 \
    torchvision==0.24.1+rocm6.4 \
    torchaudio==2.9.1+rocm6.4 \
    --index-url https://download.pytorch.org/whl/rocm6.4

RUN venv/bin/pip3 install --no-cache-dir av soundfile

RUN venv/bin/pip3 install --no-cache-dir gitpython

WORKDIR /workspace/ComfyUI/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git

WORKDIR /workspace
RUN mkdir -p /workspace/storage

WORKDIR /workspace/ComfyUI
