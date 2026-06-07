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

# Diffusion models
download_model "https://huggingface.co/wikeeyang/Flux2-Klein-9B-True-V2/resolve/main/Flux2-Klein-9B-True-v2-bf16.safetensors" "$DIFFUSION_MODELS_DIR/Flux2-Klein-9B-True-v2-bf16.safetensors"
download_model "https://huggingface.co/wikeeyang/Flux2-Klein-9B-True-V2/resolve/main/Flux2-Klein-9B-True-v2-fp8mixed.safetensors" "$DIFFUSION_MODELS_DIR/Flux2-Klein-9B-True-v2-fp8mixed.safetensors"
download_model "https://huggingface.co/black-forest-labs/FLUX.2-klein-9B/resolve/main/flux-2-klein-9b.safetensors" "$DIFFUSION_MODELS_DIR/flux-2-klein-9b.safetensors"
download_model "https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-fp8/resolve/main/flux-2-klein-9b-fp8.safetensors" "$DIFFUSION_MODELS_DIR/flux-2-klein-9b-fp8.safetensors"
# download_model "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_animate_14B_bf16.safetensors" "$DIFFUSION_MODELS_DIR/wan2.2_animate_14B_bf16.safetensors"
# download_model "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp16.safetensors" "$DIFFUSION_MODELS_DIR/wan2.2_i2v_high_noise_14B_fp16.safetensors"
# download_model "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp16.safetensors" "$DIFFUSION_MODELS_DIR/wan2.2_i2v_low_noise_14B_fp16.safetensors"

# Text encoders
# download_model "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" "$TEXT_ENCODERS_DIR/umt5_xxl_fp8_e4m3fn_scaled.safetensors"
download_model "https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b.safetensors" "$TEXT_ENCODERS_DIR/qwen_3_8b.safetensors"

# VAE models
# download_model "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" "$VAE_DIR/wan_2.1_vae.safetensors"
download_model "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors" "$VAE_DIR/flux2-vae.safetensors"

# Clip vision
download_model "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors" "$CLIP_VISION_DIR/clip_vision_h.safetensors"

# Detection
# download_model "https://huggingface.co/JunkyByte/easy_ViTPose/resolve/main/onnx/wholebody/vitpose-l-wholebody.onnx" "$DETECTION_DIR/vitpose-l-wholebody.onnx"
# download_model "https://huggingface.co/Wan-AI/Wan2.2-Animate-14B/resolve/main/process_checkpoint/det/yolov10m.onnx" "$DETECTION_DIR/yolov10m.onnx"
# download_model "https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_data.bin" "$DETECTION_DIR/vitpose_h_wholebody_data.bin"
# download_model "https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_model.onnx" "$DETECTION_DIR/vitpose_h_wholebody_model.onnx"

# LORAs
download_model "https://huggingface.co/dx8152/Flux2-Klein-9B-Consistency/resolve/main/Flux2-Klein-9B-consistency-V2.safetensors" "$LORAS_DIR/Flux2-Klein-9B-consistency-V2.safetensors"
download_model "https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/resolve/main/bfs_head_v1_flux-klein_9b_step3500_rank128.safetensors" "$LORAS_DIR/bfs_head_v1_flux-klein_9b_step3500_rank128.safetensors"
download_model "https://huggingface.co/nhathoangfoto/FLUX.2-klein-ghost-mannequin/resolve/main/3D-GhosMannequinRank-256.safetensors" "$LORAS_DIR/3D-GhosMannequinRank-256.safetensors"
# download_model "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22_relight/WanAnimate_relight_lora_fp16.safetensors" "$LORAS_DIR/WanAnimate_relight_lora_fp16.safetensors"
# download_model "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank128_bf16.safetensors" "$LORAS_DIR/lightx2v_I2V_14B_480p_cfg_step_distill_rank128_bf16.safetensors"
# download_model "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Stable-Video-Infinity/v2.0/SVI_v2_PRO_Wan2.2-I2V-A14B_HIGH_lora_rank_128_fp16.safetensors" "$LORAS_DIR/SVI_v2_PRO_Wan2.2-I2V-A14B_HIGH_lora_rank_128_fp16.safetensors"
# download_model "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Stable-Video-Infinity/v2.0/SVI_v2_PRO_Wan2.2-I2V-A14B_LOW_lora_rank_128_fp16.safetensors" "$LORAS_DIR/SVI_v2_PRO_Wan2.2-I2V-A14B_LOW_lora_rank_128_fp16.safetensors"

download_model "https://huggingface.co/bodhicitta/sam3/resolve/main/sam3.pt" "$SAM3_DIR/sam3.pt"

cd ComfyUI/custom_nodes
git clone https://github.com/Comfy-Org/ComfyUI-Manager
git clone https://github.com/kijai/ComfyUI-WanAnimatePreprocess
git clone https://github.com/sonnybox/ComfyUI-SuperNodes
git clone https://github.com/kijai/ComfyUI-WanVideoWrapper
git clone https://github.com/kijai/ComfyUI-KJNodes
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite
git clone https://github.com/kijai/ComfyUI-segment-anything-2
git clone https://github.com/PozzettiAndrea/ComfyUI-SAM3
git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack
git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack
git clone https://github.com/rgthree/rgthree-comfy
git clone https://github.com/chrisgoringe/cg-use-everywhere
git clone https://github.com/capitan01R/ComfyUI-Flux2Klein-Enhancer
git clone https://github.com/xb1n0ry/ComfyUI-KleinRefGrid
git clone https://github.com/yolain/ComfyUI-Easy-Use
git clone https://github.com/Nekodificador/ComfyUI-NKD-Klein-Tools
git clone https://github.com/ltdrdata/was-node-suite-comfyui
git clone https://github.com/crystian/comfyui-crystools
git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts
git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes
git clone https://github.com/cubiq/ComfyUI_essentials
git clone https://github.com/PGCRT/CRT-Nodes
git clone https://github.com/wallish77/wlsh_nodes
git clone https://github.com/scraed/LanPaint

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
uv pip install -r custom_nodes/ComfyUI-WanAnimatePreprocess/requirements.txt
uv pip install -r custom_nodes/ComfyUI-WanVideoWrapper/requirements.txt
uv pip install -r custom_nodes/ComfyUI-KJNodes/requirements.txt
uv pip install -r custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt
uv pip install -r custom_nodes/ComfyUI-SuperNodes/requirements.txt
uv pip install -r custom_nodes/ComfyUI-SAM3/requirements.txt
uv pip install -r custom_nodes/ComfyUI-Impact-Pack/requirements.txt
uv pip install -r custom_nodes/ComfyUI-Impact-Subpack/requirements.txt
uv pip install -r custom_nodes/ComfyUI-Easy-Use/requirements.txt
uv pip install -r custom_nodes/was-node-suite-comfyui/requirements.txt
uv pip install -r custom_nodes/comfyui-crystools/requirements.txt
uv pip install -r custom_nodes/CRT-Nodes/requirements.txt

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
