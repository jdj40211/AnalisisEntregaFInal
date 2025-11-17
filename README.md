# Proyecto Análisis Numérico

Aplicación web para métodos numéricos desarrollada con Flask y MATLAB.

## 🚀 Instrucciones de Ejecución

### 1. Requisitos Previos
- Python 3.12 o superior
- MATLAB R2025b (o versión compatible)

### 2. Instalación

**Clonar el repositorio:**
```bash
git clone https://github.com/JohanAlv24/Proyecto_Analisis.git
cd Proyecto_Analisis
```

**Instalar dependencias Python:**
```bash
pip install -r requirements.txt
```

**Instalar MATLAB Engine for Python:**

*En macOS/Linux:*
```bash
cd /Applications/MATLAB_R2025b.app/extern/engines/python
python setup.py install
```

*En Windows:*
```bash
cd "C:\Program Files\MATLAB\R2025b\extern\engines\python"
python setup.py install
```

### 3. Ejecutar la Aplicación

```bash
python run.py
```

Abrir en el navegador: **http://localhost:5001**

---

**Nota:** El puerto 5001 se usa porque macOS Control Center ocupa el 5000 por defecto.

## Estructura del Proyecto

```
Proyecto_Analisis/
├── app/
│   ├── app.py              # Aplicación principal Flask
│   ├── seccion_1.py        # Métodos de ecuaciones de una variable
│   ├── seccion_2.py        # Métodos de sistemas de ecuaciones
│   ├── seccion_3.py        # Métodos de interpolación
│   ├── templates/          # Templates HTML
│   │   ├── Seccion_1/
│   │   ├── Seccion_2/
│   │   └── Seccion_3/
│   ├── static/             # Archivos CSS, JS e imágenes
│   └── tables/             # Tablas CSV y Excel generadas
├── matlab_codes/           # Códigos MATLAB para cálculos
├── run.py                  # Script de ejecución
└── requirements.txt        # Dependencias Python
```

## Características

### Capítulo 1: Ecuaciones de una variable
- Bisección
- Regla Falsa
- Punto Fijo
- Newton
- Secante
- Raíces Múltiples
- Informe comparativo automático

### Capítulo 2: Sistemas de ecuaciones
- Jacobi
- Gauss-Seidel
- SOR (Successive Over-Relaxation)
- Cálculo de radio espectral
- Verificación de convergencia
- Informe comparativo automático

### Capítulo 3: Interpolación
- Vandermonde
- Newton Interpolante
- Lagrange
- Spline Lineal
- Spline Cúbico
- Informe comparativo automático

### Funcionalidades Adicionales
- ✅ Centro de ayuda interactivo
- ✅ Calculadora de derivadas
- ✅ Exportación de resultados (CSV, Excel)
- ✅ Graficación de resultados
- ✅ Validación de datos
- ✅ Prevención de errores
- ✅ Interfaz responsive

## Tecnologías

- **Backend:** Flask (Python 3.12)
- **Cálculos:** MATLAB R2025b
- **Frontend:** HTML5, CSS3, JavaScript
- **Librerías:** NumPy, Pandas, Matplotlib, OpenPyXL

## Autores

Ver el archivo `instrucciones.md` para más detalles sobre los requisitos del proyecto.

## Licencia

Este proyecto fue desarrollado como parte del curso de Análisis Numérico.
