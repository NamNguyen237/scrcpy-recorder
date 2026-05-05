@echo off
pushd "%~dp0"
title iQOO_Safe_Multitasking
cls

echo [*] Dang kich hoat che do cua so tu do...
adb shell settings put global enable_freeform_support 1

echo [*] Dang mo Scrcpy (Man hinh chinh - Upscale)...
:: Cach nay khong tao ID moi nen se ko bao gio treo may
:: No se giup ban mo moi app duoi dang cua so (giong Windows)
start scrcpy.exe --window-title "iQOO_Workstation" --stay-awake --keyboard=uhid --mouse=uhid

echo ------------------------------------------------------
echo [V] HUONG DAN DUNG:
echo 1. Mo app bat ky (vi du: NIKKE).
echo 2. Bam vao nut Da nhiem (Recents) tren dien thoai.
echo 3. Bam vao icon app -> Chon "Cua so nho" (Small window/Freeform).
echo 4. Gio ban co the mo nhieu app cung luc tren mot man hinh!
echo ------------------------------------------------------
pause