@echo off
rem Ruta al intérprete de Python 3.9
set PYTHON_EXE=C:\Users\Lenovo\anaconda3\python.exe

rem Ruta al script de Flask
set FLASK_APP=C:\Users\Lenovo\OneDrive\Escritorio\I.M\A.Num\Proyecto\Proyecto_Analisis\app\app.py

rem Cambiar al directorio de tu proyecto
cd C:\Users\Lenovo\OneDrive\Escritorio\I.M\A.Num\Proyecto\Proyecto_Analisis\app

rem Ejecutar Flask con el intérprete de Python 3.9
%PYTHON_EXE% -m flask --app app.app --debug run
