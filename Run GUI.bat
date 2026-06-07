@echo off
title Launching ZAPRET GUI...
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator); if ($isAdmin) { Start-Process powershell.exe -ArgumentList '-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File \"%~dp0utils\gui.ps1\"' -WorkingDirectory '%~dp0' } else { Start-Process powershell.exe -ArgumentList '-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File \"%~dp0utils\gui.ps1\"' -WorkingDirectory '%~dp0' -Verb RunAs }"
exit
