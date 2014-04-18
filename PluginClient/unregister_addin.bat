echo off
@setlocal enableextensions
@cd /d "%~dp0"
set rel_path=..\build\Addin\client\PluginClient.dll
set full_path=%cd%\%rel_path%
echo on
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\regasm /u %full_path%
:: Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil /LogToConsole=true C:\CADetc\Addin\client\PluginClient.exe
Pause