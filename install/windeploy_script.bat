echo off
@setlocal enableextensions
@cd /d "%~dp0"
set rel_path=..\build\host\Receptacle.exe
set full_path=%cd%\%rel_path%
echo on
call C:\Qt\Qt5.2.1\5.2.1\msvc2012_64_opengl\bin\qtenv2.bat
call C:\Qt\Qt5.2.1\5.2.1\msvc2012_64_opengl\bin\windeployqt.exe %full_path%
Pause