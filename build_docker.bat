@echo off
echo Building Docker image "openisns-fuzz"...
docker build -t openisns-fuzz .
if %errorlevel% neq 0 (
    echo Docker image build failed!
    pause
    exit /b %errorlevel%
)
echo Docker image built successfully.
pause
