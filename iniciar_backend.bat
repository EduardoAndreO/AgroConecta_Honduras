@echo off
title AgroConecta Honduras - Backend Gateway
cd /d "%~dp0"
echo ========================================================
echo   Iniciando AgroConecta Honduras API Gateway (FastAPI)
echo ========================================================
echo Directorio: %CD%
echo Host: http://0.0.0.0:8000
echo Documentacion: http://127.0.0.1:8000/docs
echo.
set PYTHONPATH=%CD%
python -m uvicorn services.gateway.main:app --host 0.0.0.0 --port 8000 --reload
pause
