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
echo    QUAY RAW 1.5K 20:9 [LUU TAI: RAW_Recorded]
echo ======================================================
echo 1. Quay H.264 (An toan - Bitrate 45M)
echo 2. Quay H.265 (Chat luong cao - Bitrate 45M)
echo ------------------------------------------------------
set /p choice="Nhap lua chon Codec (1/2) roi Bam ENTER: "

echo ------------------------------------------------------
echo CHEDO DIEU KHIEN - HIEN THI TIEU CHUAN:
echo 1. Bat (CO CHE TOI UU: Mo cua so phu 4M de dieu khien muot + Ghi ngam 45M)
echo 2. Tat (An cua so hoan toan, quay video chay ngam tiet kiem RAM)
echo ------------------------------------------------------
set /p ctrl_choice="Bat tinh nang dieu khien tu may tinh? (1/2) roi Bam ENTER: "

:: Xử lý định dạng Codec
set "CODEC_FLAG="
if "%choice%"=="1" (
    set "CODEC_FLAG=h264"
) else if "%choice%"=="2" (
    set "CODEC_FLAG=h265"
) else (
    echo Lua chon khong hop le!
    pause
    exit /b 1
)

:: Thiết lập đường dẫn lưu file
set "SAVE_DIR=C:\RAW_Recorded"
if not exist "%SAVE_DIR%" mkdir "%SAVE_DIR%"

:: Tạo timestamp cho tên file (YYYYMMDD_HHMMSS)
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "dt=%%I"
set "filename=%SAVE_DIR%\RAW_%dt:~0,4%%dt:~4,2%%dt:~6,2%_%dt:~8,2%%dt:~10,2%%dt:~12,2%.mkv"

cls
echo ------------------------------------------------------
echo [DANG CHAY CO CHE PHAN LUONG TOI UU...]
echo HUONG DAN: Bam Ctrl + C tai cua so CMD nay de DUNG ghi hinh sach se.
echo ------------------------------------------------------

if "%ctrl_choice%"=="1" (
    echo [*] Dang khoi chay luong dieu khien NATIVE HID [1024p - Bitrate 4M]...
    :: Them tinh nang --keyboard=uhid va --mouse=uhid de gia lap chuot ban phim phan cung doc lap cho game
    start "" "%SCRCPY%" --port 27184 --max-size 1024 --video-bit-rate 4M --no-audio --keyboard=uhid --mouse=uhid --window-title="Scrcpy Controller - Low-Res 1-1"
    
    echo [*] Dang tien hanh ghi file RAW 1.5K Bitrate 45M ngam...
    "%SCRCPY%" --port 27183 --no-playback --audio-dup --video-bit-rate 45M --max-fps 60 --video-codec=!CODEC_FLAG! --record "%filename%"
) else (
    echo [*] Dang ghi file RAW 1.5K chay ngam hoan toan [Khong bat cua so dieu khien]...
    "%SCRCPY%" --port 27183 --no-control --no-playback --audio-dup --video-bit-rate 45M --max-fps 60 --video-codec=!CODEC_FLAG! --record "%filename%"
)

echo.
echo Da dung ghi hinh. File luu tai: %filename%
:: Tu dong don dep va tat luon cua so dieu khien phu sau khi ban bam Ctrl + C dung quay hinh
taskkill /f /im scrcpy.exe >nul 2>&1
echo Bam phim bat ky de thoat...
pause >nul