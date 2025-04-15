@echo off
setlocal ENABLEEXTENSIONS

REM === Configuration ===
set CONTAINER=openisns-fuzz
set INPUT_DIR=-
set OUTPUT_DIR=/output
set MAPPED_OUTPUT=%cd%\output

REM === Launch AFL++ master ===
echo [*] Starting AFL++ master fuzzer...
start "AFL Master" cmd /k ^
docker run -it --rm -v "%MAPPED_OUTPUT%:%OUTPUT_DIR%" -e AFL_AUTORESUME=1 %CONTAINER% ^
afl-fuzz -M master -i %INPUT_DIR% -o %OUTPUT_DIR% ./fuzz_simple_decode

REM Wait for master to initialize
timeout /t 5 >nul

REM === Launch AFL++ slave1 ===
echo [*] Starting AFL++ slave1 fuzzer...
start "AFL Slave1" cmd /k ^
docker run -it --rm -v "%MAPPED_OUTPUT%:%OUTPUT_DIR%" -e AFL_AUTORESUME=1 %CONTAINER% ^
afl-fuzz -S slave1 -i %INPUT_DIR% -o %OUTPUT_DIR% ./fuzz_simple_decode

REM Wait for slave1 to initialize
timeout /t 5 >nul

REM === Launch AFL++ slave2 ===
echo [*] Starting AFL++ slave2 fuzzer...
start "AFL Slave2" cmd /k ^
docker run -it --rm -v "%MAPPED_OUTPUT%:%OUTPUT_DIR%" -e AFL_AUTORESUME=1 %CONTAINER% ^
afl-fuzz -S slave2 -i %INPUT_DIR% -o %OUTPUT_DIR% ./fuzz_simple_decode

echo [*] All fuzzers launched in resume mode.
pause
