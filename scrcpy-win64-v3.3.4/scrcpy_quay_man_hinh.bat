@echo off
setlocal enabledelayedexpansion

:: Lấy đường dẫn thư mục chứa script (tương đương với BASE_DIR)
set "BASE_DIR=%~dp0"

:: Gán đường dẫn cho ADB và Scrcpy nội bộ (thêm đuôi .exe cho Windows)
set "ADB=%BASE_DIR%adb.exe"
set "SCRCPY=%BASE_DIR%scrcpy.exe"

title Scrcpy_v3.3.4_1.5K_Final_Fix
cls

:check_device
echo Dang kiem tra ket noi thiet bi qua adb...

:: Kiểm tra thiết bị: Tìm dòng "device" nhưng loại bỏ dòng tiêu đề "List of..."
set "device_found=0"
for /f "tokens=1,2" %%a in ('"%ADB%" devices 2^>nul') do (
    if "%%b"=="device" (
        set /a device_found+=1
    )
)

if %device_found% equ 0 (
    echo ------------------------------------------------------
    echo LOI: Khong tim thay dien thoai nao!
    echo Cam lai cap roi bam Enter de thu lai...
    pause >nul
    cls
    goto :check_device
)

cls
echo ======================================================
echo    QUAY RAW 1.5K 20:9 -^> LUU TAI: RAW_Recorded
echo ======================================================
echo 1. Quay H.264 (An toan - Bitrate 45M)
echo 2. Quay H.265 (Chat luong cao - Bitrate 45M)
echo ------------------------------------------------------
set /p choice="Nhap lua chon (1/2) roi Bam ENTER: "

:: Thiết lập đường dẫn lưu file (Windows dùng đường dẫn như C:\... hoặc D:\...)
:: Mình để mặc định là ổ D:\RAW_Recorded, bạn có thể sửa lại cho đúng ý
set "SAVE_DIR=D:\RAW_Recorded"
if not exist "%SAVE_DIR%" mkdir "%SAVE_DIR%"

:: Tạo timestamp cho tên file (YYYYMMDD_HHMMSS)
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "dt=%%I"
set "filename=%SAVE_DIR%\RAW_%dt:~0,4%%dt:~4,2%%dt:~6,2%_%dt:~8,2%%dt:~10,2%%dt:~12,2%.mkv"

if "%choice%"=="1" (
    echo [DANG QUAY H.264...] Bam Ctrl + C de dung.
    "%SCRCPY%" --no-control --no-playback --no-audio-playback --audio-dup --video-bit-rate 45M --max-fps 60 --video-codec=h264 --record "%filename%"
) else if "%choice%"=="2" (
    echo [DANG QUAY H.265...] Bam Ctrl + C de dung.
    "%SCRCPY%" --no-control --no-playback --no-audio-playback --audio-dup --video-bit-rate 45M --max-fps 60 --video-codec=h265 --record "%filename%"
) else (
    echo Lua chon khong hop le!
    pause
    exit /b 1
)

echo.
echo Da dung. File luu tai: %filename%
echo Bam phim bat ky de thoat...
pause >nul
