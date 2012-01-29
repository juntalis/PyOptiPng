@echo off
setlocal
set targetdir=%~dp0..\src\python\
set inputpy=%targetdir%optipng.pyx
set outputc=%targetdir%optipngmodule
if exist "%outputc%.h" del /f /q "%outputc%.h"
if exist "%outputc%.c" del /f /q "%outputc%.c"
pushd "%~dp0"
start "Cythonizing.." /WAIT "%ComSpec%" "/C python.bat Scripts\cython.py -o %outputc%.c %inputpy%"
popd
endlocal