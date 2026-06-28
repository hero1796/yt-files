#!/bin/bash

echo 'cd /root' >> /etc/bash.bashrc
echo 'source /root/ComfyUI/venv/bin/activate' >> /etc/bash.bashrc

cd /root

git clone https://github.com/Comfy-Org/ComfyUI

# Function to download a model
download_model() {
    local url="$1"
    local full_path="$2"

    local destination_dir=$(dirname "$full_path")
    local destination_file=$(basename "$full_path")

    mkdir -p "$destination_dir"

    # Simple corruption check: file < 10MB or .aria2 files
    if [ -f "$full_path" ]; then
        local size_bytes=$(stat -f%z "$full_path" 2>/dev/null || stat -c%s "$full_path" 2>/dev/null || echo 0)
        local size_mb=$((size_bytes / 1024 / 1024))

        if [ "$size_bytes" -lt 10485760 ]; then  # Less than 10MB
            echo "🗑️  Deleting corrupted file (${size_mb}MB < 10MB): $full_path"
            rm -f "$full_path"
        else
            echo "✅ $destination_file already exists (${size_mb}MB), skipping download."
            return 0
        fi
    fi

    # Check for and remove .aria2 control files
    if [ -f "${full_path}.aria2" ]; then
        echo "🗑️  Deleting .aria2 control file: ${full_path}.aria2"
        rm -f "${full_path}.aria2"
        rm -f "$full_path"  # Also remove any partial file
    fi

    echo "📥 Downloading $destination_file to $destination_dir..."

    # Download without falloc (since it's not supported in your environment)
    aria2c -x 16 -s 16 -k 1M --continue=true --header="Authorization: Bearer $HF_TOKEN" -d "$destination_dir" -o "$destination_file" "$url" &

    echo "Download started in background for $destination_file"
}

# Define base paths
DIFFUSION_MODELS_DIR="/root/ComfyUI/models/diffusion_models"
TEXT_ENCODERS_DIR="/root/ComfyUI/models/text_encoders"
CLIP_VISION_DIR="/root/ComfyUI/models/clip_vision"
VAE_DIR="/root/ComfyUI/models/vae"
LORAS_DIR="/root/ComfyUI/models/loras"
DETECTION_DIR="/root/ComfyUI/models/detection"
SAM3_DIR="/root/ComfyUI/models/sam3"
LATENT_UPSCALE_MODELS_DIR="/root/ComfyUI/models/latent_upscale_models"

download_model "https://huggingface.co/Kijai/LTX2.3_comfy/resolve/main/diffusion_models/ltx-2.3-22b-distilled-1.1_transformer_only_fp8_scaled.safetensors" "$DIFFUSION_MODELS_DIR/ltx-2.3-22b-distilled-1.1_transformer_only_fp8_scaled.safetensors"
download_model "https://huggingface.co/Lightricks/LTX-2.3/resolve/main/ltx-2.3-spatial-upscaler-x2-1.1.safetensors" "$LATENT_UPSCALE_MODELS_DIR/ltx-2.3-spatial-upscaler-x2-1.1.safetensors"
download_model "https://huggingface.co/Kijai/LTX2.3_comfy/resolve/main/vae/LTX23_audio_vae_bf16.safetensors" "$VAE_DIR/LTX23_audio_vae_bf16.safetensors"
download_model "https://huggingface.co/Kijai/LTX2.3_comfy/resolve/main/vae/LTX23_video_vae_bf16.safetensors" "$VAE_DIR/LTX23_video_vae_bf16.safetensors"
download_model "https://huggingface.co/Kijai/LTX2.3_comfy/resolve/main/vae/taeltx2_3.safetensors" "$VAE_DIR/taeltx2_3.safetensors"
download_model "https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors" "$TEXT_ENCODERS_DIR/gemma_3_12B_it_fp4_mixed.safetensors"
download_model "https://huggingface.co/Kijai/LTX2.3_comfy/resolve/main/text_encoders/ltx-2.3_text_projection_bf16.safetensors" "$TEXT_ENCODERS_DIR/ltx-2.3_text_projection_bf16.safetensors"


cd ComfyUI/custom_nodes
git clone https://github.com/Comfy-Org/ComfyUI-Manager
git clone https://github.com/WhatDreamscost/WhatDreamsCost-ComfyUI
git clone https://github.com/Lightricks/ComfyUI-LTXVideo
git clone https://github.com/kijai/ComfyUI-KJNodes
git clone https://github.com/rgthree/rgthree-comfy
git clone https://github.com/yolain/ComfyUI-Easy-Use
git clone https://github.com/GACLove/ComfyUI-VFI

cd /root/ComfyUI

git fetch --tags
git checkout $(git tag --sort=-v:refname | head -n 1)

uv venv venv --python 3.11
source venv/bin/activate

uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130
uv pip install -r requirements.txt
uv pip install -r custom_nodes/ComfyUI-Manager/requirements.txt
uv pip install coloredlogs flatbuffers numpy packaging protobuf sympy matplotlib ninja setuptools
uv pip install --pre --index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/ort-cuda-13-nightly/pypi/simple/ onnxruntime-gpu
uv pip install -r custom_nodes/ComfyUI-KJNodes/requirements.txt
uv pip install -r custom_nodes/ComfyUI-LTXVideo/requirements.txt
uv pip install -r custom_nodes/ComfyUI-Easy-Use/requirements.txt
uv pip install -r custom_nodes/ComfyUI-VFI/requirements.txt

uv pip install https://github.com/hero1796/yt-files/raw/refs/heads/main/WHEELS/sm_120_blackwell/sageattention-2.2.0-cp311-cp311-linux_x86_64.whl

TARGET_DIR="/root/ComfyUI/user/default"
TARGET_FILE="$TARGET_DIR/comfy.settings.json"

mkdir -p "$TARGET_DIR"

cat > "$TARGET_FILE" << 'EOF'
{
    "Comfy.TutorialCompleted": true,
    "VHS.LatentPreview": true,
    "Comfy.ColorPalette": "github",
    "Comfy.UI.TabBarLayout": "Integrated",
    "Comfy.Sidebar.Style": "floating",
    "Comfy.Sidebar.Size": "small",
    "LiteGraph.Canvas.MinFontSizeForLOD": 0,
    "Comfy.Keybinding.NewBindings": [
        {
            "commandId": "Comfy.Canvas.FitView",
            "combo": {
                "key": "f",
                "ctrl": false,
                "alt": false,
                "shift": false
            }
        }
    ],
    "Comfy.Keybinding.UnsetBindings": [
        {
            "commandId": "Comfy.Canvas.FitView",
            "combo": {
                "key": ".",
                "ctrl": false,
                "alt": false,
                "shift": false
            },
            "targetElementId": "graph-canvas-container"
        }
    ]
}
EOF

mkdir -p /root/ComfyUI/user/default/workflows
cd /root/ComfyUI/user/default/workflows
git clone https://github.com/hero1796/comfy-wf

# Keep checking until no aria2c processes are running
while pgrep -x "aria2c" > /dev/null; do
    echo "🔽 Model Downloads still in progress..."
    sleep 5  # Check every 5 seconds
done

cd /root/ComfyUI

python main.py \
	--listen \
	--preview-method auto \
	--max-upload-size 9999999
