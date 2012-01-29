@ECHO OFF
setlocal
if not exist "%~dp0Scripts" goto GlobalPython
call "%~dp0Scripts\activate.bat"
"%~dp0Scripts\python.exe" %*
if errorlevel 1 (
	PAUSE
)
goto Cleanup
:GlobalPython
python.exe %*
goto Cleanup
:Cleanup
endlocal
goto :EOF