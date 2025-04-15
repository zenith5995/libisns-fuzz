@echo off
REM This script trims the AFL++ corpus using afl-cmin, then replaces the original /input corpus.

REM === Configuration ===
set CONTAINER=openisns-fuzz
set INPUT_DIR=%cd%\output\master\queue
set TEMP_TRIMMED=%cd%\trimmed_corpus
set FINAL_INPUT=%cd%\seeds

REM Step 1: Clean temporary trimmed corpus directory
if exist "%TEMP_TRIMMED%" (
    echo [*] Removing existing trimmed_corpus directory...
    rmdir /s /q "%TEMP_TRIMMED%"
)
mkdir "%TEMP_TRIMMED%"

REM Step 2: Run afl-cmin in Docker
echo [*] Running afl-cmin to minimize corpus...
docker run --rm -v "%INPUT_DIR%:/input" -v "%TEMP_TRIMMED%:/output" %CONTAINER% ^
afl-cmin -i /input -o /output -- ./fuzz_simple_decode @@

REM Step 3: Replace original seed directory
if exist "%FINAL_INPUT%" (
    echo [*] Replacing contents of seeds directory...
    rmdir /s /q "%FINAL_INPUT%"
)
mkdir "%FINAL_INPUT%"
xcopy /Y /Q "%TEMP_TRIMMED%\*" "%FINAL_INPUT%\"

echo [✓] Corpus trimming complete. New seed corpus is ready in: %FINAL_INPUT%
pause


apt list --installed