@echo off

if "%~1" == "" (
  echo Å¶ close this window, please drag and drop the files you want to archive.
  pause
  exit /b
)

echo:
"%~dp0Zamboni.exe" -pack -outName "%~dp0%~n1.ice" %*
echo:
