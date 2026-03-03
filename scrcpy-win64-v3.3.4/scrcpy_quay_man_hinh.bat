@echo off
title Scrcpy_v3.3.4_1.5K_Final_Fix
cls

echo ======================================================
echo    QUAY RAW 1.5K 20:9 (Dinh dang MKV - Chong mat file)
echo    Version 3.3.4 - Khoa Ngang (90) - Ko xem truoc
echo ======================================================
echo 1. Quay H.264 (An toan cho i5-6th - Bitrate 45M)
echo 2. Quay H.265 (Chat luong cao cho 9400p - Bitrate 45M)
echo ------------------------------------------------------
set /p choice="Nhap lua chon (1/2) roi Bam ENTER: "

:: Tu dong tao ten file
set filename=RAW_%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.mkv
set filename=%filename: =0%

:: Giai thich thong so moi:
:: --no-playback: Thay the cho --no-display (Khong hien man hinh laptop)
:: --capture-orientation=90: Khoa quay chieu ngang
:: --video-bit-rate 35M: Du bang thong cho 1.5K tren USB 2.0
:: --audio-playback-strategy=play: Ep am thanh phat ra loa dien thoai khi dang quay


if "%choice%"=="1" (
    echo [DANG QUAY H.264...] Hay nghe tieng tu dien thoai. Bam Ctrl + C de dung.
    scrcpy --no-control --no-playback --no-audio-playback --audio-dup --video-bit-rate 45M --max-fps 60 --video-codec=h264 --record %filename%
)

if "%choice%"=="2" (
    echo [DANG QUAY H.265...] Hay nghe tieng tu dien thoai. Bam Ctrl + C de dung.
    scrcpy --no-control --no-playback --no-audio-playback --audio-dup --video-bit-rate 45M --max-fps 60 --video-codec=h265 --record %filename%
)

echo.
echo Da dung. File luu tai: %filename%
pause
