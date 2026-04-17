#!/bin/bash

# Lấy đường dẫn tuyệt đối của thư mục chứa script
BASE_DIR=$(dirname "$(readlink -f "$0")")

# Gán đường dẫn cho ADB và Scrcpy nội bộ
ADB="$BASE_DIR/adb"
SCRCPY="$BASE_DIR/scrcpy"

echo -ne "\033]0;Scrcpy_v3.3.4_1.5K_Final_Fix\007"
clear

# --- Hàm kiểm tra thiết bị ---
check_device() {
    echo "Dang kiem tra ket noi thiet bi qua $ADB..."
    # Sử dụng biến $ADB để chạy file adb trong thư mục
    device_count=$($ADB devices | grep -w "device" | wc -l)

    if [ "$device_count" -eq 0 ]; then
        echo "------------------------------------------------------"
        echo "LOI: Khong tim thay dien thoai nao!"
        read -p "Cam lai cap roi bam Enter de thu lai..."
        check_device
    fi
}

check_device
clear

echo "======================================================"
echo "   QUAY RAW 1.5K 20:9 -> LUU TAI: Videos/Scrcpy_Records"
echo "======================================================"
echo "1. Quay H.264 (An toan - Bitrate 45M)"
echo "2. Quay H.265 (Chat luong cao - Bitrate 45M)"
echo "------------------------------------------------------"
read -p "Nhap lua chon (1/2) roi Bam ENTER: " choice

SAVE_DIR="/mnt/nvme/RAW_Recorded" #"$HOME/Videos/Scrcpy_Records"
mkdir -p "$SAVE_DIR"
filename="$SAVE_DIR/RAW_$(date +'%Y%m%d_%H%M%S').mkv"

if [ "$choice" == "1" ]; then
    echo "[DANG QUAY H.264...] Bam Ctrl + C de dung."
    $SCRCPY --no-control --no-playback --no-audio-playback --audio-dup --video-bit-rate 45M --max-fps 60 --video-codec=h264 --record "$filename"
elif [ "$choice" == "2" ]; then
    echo "[DANG QUAY H.265...] Bam Ctrl + C de dung."
    $SCRCPY --no-control --no-playback --no-audio-playback --audio-dup --video-bit-rate 45M --max-fps 60 --video-codec=h265 --record "$filename"
else
    echo "Lua chon khong hop le!"
    exit 1
fi

echo -e "\nDa dung. File luu tai: $filename"
read -p "Bam phim bat ky de thoat..." -n1 -s
