@echo off
set /a hidden=1
IF NOT %1.==. (
set /a hidden=%1
)
set name="util_launcher"
set bin=util_launcher
set script=H:\sandbox\cad_util\script\run.rb
set optns=stdout

IF %hidden% EQU 1 (
start %name% /B %bin% %script% %optns%
) ELSE (
start %name% %bin% %script% %optns%
)
