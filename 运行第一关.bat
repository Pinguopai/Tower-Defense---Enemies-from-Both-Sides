@echo off
cd /d "%~dp0"
start "两面来敌" /wait "tools\godot\Godot_v4.7.1-stable_win64.exe" --path "client" --accessibility disabled
if errorlevel 1 pause
