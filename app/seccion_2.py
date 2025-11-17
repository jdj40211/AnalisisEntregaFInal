from flask import Blueprint, render_template, request, send_file, url_for
import os, json, csv
import matlab.engine
import pandas as pd
import numpy as np
from numpy.linalg import eigvals


blueprint = Blueprint('seccion_2', __name__)

eng = matlab.engine.start_matlab()

separador = os.path.sep 
dir_actual = os.path.dirname(os.path.abspath(__file__))
dir_matlab = separador.join(dir_actual.split(separador)[:-1])+'\matlab_codes'
dir_tables = os.path.join(dir_actual, 'tables')
dir_static = os.path.join(os.path.dirname(__file__), 'static')

eng.addpath(dir_matlab)

# Función para calcular el radio espectral en Python
def calcular_radio_espectral(A_str):
    """
    Verifica si la matriz A es diagonalmente dominante.
    Si no lo es, calcula el radio espectral.
    Retorna un diccionario con dos claves:
    {
        "diagonal_dominante": bool,
        "radio_espectral": float
    }
    """
    try:
        A_clean = A_str.replace('[', '').replace(']', '')
        filas = A_clean.split(';')
        A = np.array([list(map(float, fila.split())) for fila in filas])
        
        # Verificar si es diagonalmente dominante por filas
        diagonal = np.abs(A.diagonal())
        suma_filas = np.sum(np.abs(A), axis=1) - diagonal
        dominante = np.all(diagonal > suma_filas)
        
        # Calcular radio espectral (aunque sea dominante, útil para reporte)
        autovalores = np.linalg.eigvals(np.eye(len(A)) - np.linalg.inv(np.diag(np.diag(A))) @ A)
        radio = np.max(np.abs(autovalores))
        
        return {
            "diagonal_dominante": dominante,
            "radio_espectral": radio
        }
        
    except Exception as e:
        raise ValueError(f"Error al procesar la matriz A: {str(e)}")


#Método de Gauss-Seidel
#Método de Gauss-Seidel
@blueprint.route('/gaussSeidel', methods=['GET', 'POST'])
def gaussSeidel():
    if request.method == 'POST':
        try:
            # Validar y procesar datos del formulario
            A = request.form['A']
            b = request.form['b']
            x = request.form['x']
            et = request.form['et']
            tol = float(request.form['tol'].replace(',', '.'))
            niter = int(request.form['niter'])

            # Validar las entradas del formulario
            if not A or not b or not x:
                raise ValueError("Debe ingresar las matrices A, b y el vector inicial x.")
            if tol <= 0:
                raise ValueError("La tolerancia debe ser un valor positivo.")
            if niter <= 0:
                raise ValueError("El número de iteraciones debe ser un entero positivo.")


            try:
                resultado = calcular_radio_espectral(A)
                dominante = resultado["diagonal_dominante"]
                radio = resultado["radio_espectral"]

                if not dominante and radio >= 1:
                 return render_template(
                 'Seccion_2/formulario_gaussSeidel.html',
                  error_message=f"El método no converge: la matriz no es diagonalmente dominante y el radio espectral es {radio:.4f} ≥ 1."
                 )
               
                # Ejecutar MATLAB
                eng.addpath(dir_matlab)
                [r, N, xn, E, re, c] = eng.gaussSeidel(x, A, b, et, tol, niter, nargout=6)

                # Procesar resultados
                if isinstance(E, float) and np.isnan(E):
                    length = 0
                    data=[]
                else:
                    N = list(range(1, len(E[0])+1)) if isinstance(E, np.ndarray) else [1]
                    E = list(E[0]) if isinstance(E, np.ndarray) else [E]
                    xn = list(xn[0]) if isinstance(xn, np.ndarray) else [xn]
                    length = len(N)
                    
                    # Procesar el archivo CSV generado por MATLAB
                    tabla_path = os.path.join(dir_tables, 'tabla_gaussSeidel.csv')
                    if os.path.exists(tabla_path):
                        df = pd.read_csv(tabla_path)
                        
                        # Convertir la columna 'xn' en múltiples columnas x1, x2, etc.
                        if 'xn' in df.columns:
                            # Extraer valores numéricos de la cadena [x1;x2;...;xn]
                            xn_values = df['xn'].str.extractall(r'([-+]?\d*\.?\d+)').unstack()
                            xn_values.columns = [f'x{i+1}' for i in range(xn_values.shape[1])]
                            
                            # Combinar con las otras columnas
                            df = pd.concat([pd.DataFrame({'N': range(1, len(df)+1)}),  
                                 df[['E']],
                                xn_values
                            ], axis=1)
                        
                        data = df.astype(str).to_dict(orient='records')
                    else:
                        data = []

                # Procesar la ruta de la gráfica
                imagen_path = os.path.join(dir_static, 'grafica_gaussSeidel.png')
                if not os.path.exists(imagen_path):
                    imagen_path = None
                else:
                    imagen_path = url_for('static', filename='grafica_gaussSeidel.png')

                # Renderizar resultados
                return render_template(
                    'Seccion_2/resultado_gaussSeidel.html',
                    r=r, N=N, xn=xn, E=E, Re=re, length=length, data=data,
                    imagen_path=imagen_path, c=c, niter=niter
                )

            except matlab.engine.MatlabExecutionError as matlab_error:
                # Capturar errores de MATLAB y renderizar el formulario con un mensaje de error
                error_message = f"Error en MATLAB: {str(matlab_error)}"
                return render_template(
                    error_message=error_message
                )

        except ValueError as ve:
            # Errores específicos de validación
            error_message = str(ve)
            return render_template(
                'Seccion_2/formulario_gaussSeidel.html',
                error_message=error_message
            )

        except Exception as e:
            # Capturar cualquier otro error
            error_message = f"Error de sintaxis, para mas informacion ir al apartado de ayuda"
            return render_template(
                'Seccion_2/formulario_gaussSeidel.html',
                error_message=error_message
            )

    # Si es una solicitud GET, renderizar el formulario vacío
    return render_template('Seccion_2/formulario_gaussSeidel.html')  

@blueprint.route('/gaussSeidel/descargar', methods=['POST'])
def descargar_archivo_gaussSeidel():
    # Ruta del archivo que se va a descargar
    archivo_path = 'tables/tabla_gaussSeidel.xlsx'

    # Enviar el archivo al cliente para descargar
    return send_file(archivo_path, as_attachment=True)

#Método de Jacobi
@blueprint.route('/jacobi', methods=['GET', 'POST'])
def jacobi():
    if request.method == 'POST':
        try:
            # Validar y procesar datos del formulario
            A = request.form['A']
            b = request.form['b']
            x = request.form['x']
            error_type = request.form['error_type']
            tol = float(request.form['tol'].replace(',', '.'))
            niter = int(request.form['niter'])

            # Validar entradas
            if not A or not b or not x:
                raise ValueError("Debe ingresar las matrices A, b y el vector inicial x.")
            if tol <= 0:
                raise ValueError("La tolerancia debe ser un valor positivo.")
            if niter <= 0:
                raise ValueError("El número de iteraciones debe ser un entero positivo.")
             # Calcular radio espectral en Python
        
           
            
            try:
                resultado = calcular_radio_espectral(A)
                dominante = resultado["diagonal_dominante"]
                radio = resultado["radio_espectral"]

                if not dominante and radio >= 1:
                  return render_template(
                    'Seccion_2/formulario_gaussSeidel.html',
                       error_message=f"El método no converge: la matriz no es diagonalmente dominante y el radio espectral es {radio:.4f} ≥ 1."
                  )
                
                # Ejecutar MATLAB
                eng.addpath(dir_matlab)
                [r, N, xn, E, Re] = eng.jacobi(x, A, b, tol, niter, error_type, nargout=5)

                # Procesar resultados
                if not np.isnan(xn[0][0]):
                    N, E = list(N[0]), list(E[0])
                    length = len(N)
                else:
                    length = 0

                # Leer y procesar el archivo CSV generado por MATLAB
                tabla_path = os.path.join(dir_tables, 'tabla_jacobi.csv')
                if os.path.exists(tabla_path):
                    df = pd.read_csv(tabla_path)
                    data = df.astype(str).to_dict(orient='records')
                else:
                    data = []

                # Procesar la ruta de la gráfica
                imagen_path = os.path.join(dir_static, 'grafica_jacobi.png')
                if not os.path.exists(imagen_path):
                    imagen_path = None
                else:
                    imagen_path = url_for('static', filename='grafica_jacobi.png')

                # Renderizar resultados
                return render_template(
                    'Seccion_2/resultado_jacobi.html',
                    r=r, N=N, xn=xn, E=E, Re=Re, length=length, data=data,
                    imagen_path=imagen_path, tol=tol
                )

            except matlab.engine.MatlabExecutionError as matlab_error:
                # Capturar errores de MATLAB y renderizar el formulario con un mensaje de error
                error_message = f"Error en MATLAB: {str(matlab_error)}"
                return render_template(
                    'Seccion_2/formulario_jacobi.html',
                    error_message=error_message
                )

        except ValueError as ve:
            # Errores específicos de validación
            error_message = str(ve)
            return render_template(
                'Seccion_2/formulario_jacobi.html',
                error_message=error_message
            )

        except Exception as e:
            # Capturar cualquier otro error
            error_message = "Error de sintaxis, para más información ir al apartado de ayuda."
            return render_template(
                'Seccion_2/formulario_jacobi.html',
                error_message=error_message
            )

    # Si es una solicitud GET, renderizar el formulario vacío
    return render_template('Seccion_2/formulario_jacobi.html')



@blueprint.route('/jacobi/descargar', methods=['POST'])
def descargar_archivo_jacobi():
    # Ruta del archivo que se va a descargar
    archivo_path = 'tables/tabla_jacobi.xlsx'

    # Enviar el archivo al cliente para descargar
    return send_file(archivo_path, as_attachment=True)


#Método de sor
@blueprint.route('/sor', methods=['GET', 'POST'])
def sor():
    if request.method == 'POST':
        try:
            # Validar y procesar datos del formulario
            x0 = str(request.form['x'])
            A = request.form['A']
            b = str(request.form['b'])
            Tol = float(request.form['tol'].replace(',', '.'))
            niter = int(request.form['niter'])
            w = float(request.form['w'].replace(',', '.'))
            tipe = str(request.form['et'])

            # Validaciones de entrada
            if not A or not b or not x0:
                raise ValueError("Debe ingresar las matrices A, b y el vector inicial x.")
            if Tol <= 0:
                raise ValueError("La tolerancia debe ser un valor positivo.")
            if niter <= 0:
                raise ValueError("El número de iteraciones debe ser un entero positivo.")
            if w <= 0 or w > 2:
                raise ValueError("El factor de relajación (w) debe estar entre 0 y 2.")

            try:
                resultado = calcular_radio_espectral(A)
                dominante = resultado["diagonal_dominante"]
                radio = resultado["radio_espectral"]

                if not dominante and radio >= 1:
                 return render_template(
                 'Seccion_2/formulario_gaussSeidel.html',
                  error_message=f"El método no converge: la matriz no es diagonalmente dominante y el radio espectral es {radio:.4f} ≥ 1."
                 )

                # Ejecutar MATLAB
                eng.addpath(dir_matlab)
                [r, n, xi, E, radio] = eng.SOR(x0, A, b, Tol, niter, w, tipe, nargout=5)

                # Procesar resultados
                if not np.isnan(xi[0][0]):
                    n, E = list(n[0]), list(E[0])
                    length = len(n)
                else:
                    length = 0

                xi = [[xi[j][i] for j in range(len(xi))] for i in range(len(xi[0]))]

                # Leer y procesar el archivo CSV generado por MATLAB
                tabla_path = os.path.join(dir_tables, 'tabla_sor.csv')
                if os.path.exists(tabla_path):
                    df = pd.read_csv(tabla_path)
                    data = df.astype(str).to_dict(orient='records')
                else:
                    data = []

                # Procesar la ruta de la gráfica
                imagen_path = os.path.join(dir_static, 'grafica_sor.png')
                if not os.path.exists(imagen_path):
                    imagen_path = None
                else:
                    imagen_path = url_for('static', filename='grafica_sor.png')

                # Renderizar resultados
                return render_template(
                    'Seccion_2/resultado_sor.html',
                    r=r, n=n, xi=xi, E=E, radio=radio, length=length, data=data,
                    imagen_path=imagen_path
                )

            except matlab.engine.MatlabExecutionError as matlab_error:
                # Capturar errores de MATLAB y renderizar el formulario con un mensaje de error
                error_message = f"Error en MATLAB: {str(matlab_error)}"
                return render_template(
                    'Seccion_2/formulario_sor.html',
                    error_message=error_message
                )

        except ValueError as ve:
            # Errores específicos de validación
            error_message = str(ve)
            return render_template(
                'Seccion_2/formulario_sor.html',
                error_message=error_message
            )

        except Exception as e:
            # Capturar cualquier otro error
            error_message = "Error de sintaxis, para más información ir al apartado de ayuda."
            return render_template(
                'Seccion_2/formulario_sor.html',
                error_message=error_message
            )

    # Si es una solicitud GET, renderizar el formulario vacío
    return render_template('Seccion_2/formulario_sor.html')

@blueprint.route('/sor/descargar', methods=['POST'])
def descargar_archivo_sor():
    # Ruta del archivo que se va a descargar
    archivo_path = 'tables/tabla_sor.xlsx'

    # Enviar el archivo al cliente para descargar
    return send_file(archivo_path, as_attachment=True)

#Informe Comparativo
@blueprint.route('/informe2', methods=['GET', 'POST'])
def informe():
    if request.method == 'POST':
        try:
            # Validar y procesar datos del formulario
            A = request.form['A']
            b = request.form['b']
            x = request.form['x']
            error_type = request.form['error_type']
            tol = float(request.form['tol'].replace(',', '.'))
            w1 = float(request.form['w1'].replace(',', '.'))
            w2 = float(request.form['w2'].replace(',', '.'))
            w3 = float(request.form['w3'].replace(',', '.'))
            niter = int(request.form['niter'])
            # Validar entradas
            if not A or not b or not x:
                raise ValueError("Debe ingresar las matrices A, b y el vector inicial x.")
            if tol <= 0:
                raise ValueError("La tolerancia debe ser un valor positivo.")
            if niter <= 0:
                raise ValueError("El número de iteraciones debe ser un entero positivo.")

            try:
                resultado = calcular_radio_espectral(A)
                dominante = resultado["diagonal_dominante"]
                radio = resultado["radio_espectral"]

                if not dominante and radio >= 1:
                 return render_template(
                 'Seccion_2/formulario_gaussSeidel.html',
                  error_message=f"El método no converge: la matriz no es diagonalmente dominante y el radio espectral es {radio:.4f} ≥ 1."
                 )
                # Ejecutar MATLAB
                eng.addpath(dir_matlab)
                [r, methods, E, X1, Re, iter] = eng.Informe2(x, A, b, tol, niter, w1, w2, w3, error_type, nargout=6)

                # Procesar resultados
                if not np.isnan(X1[0][0]):
                    r, methods, N, E, xf, Re = list(r[0]), list(methods[0]), list(iter[0]), list(E[0]), list(X1[0]), list(Re[0])
                    length = len(N)
                else:
                    length = 0

                # Leer y procesar el archivo CSV generado por MATLAB
                tabla_path = os.path.join(dir_tables, 'tabla_informe2.csv')
                if os.path.exists(tabla_path):
                    df = pd.read_csv(tabla_path)
                    size = df.shape[1] - 5
                    data = df.astype(str).to_dict(orient='records')
                    data_iter = 0
                    data_error = 0
                    
                    if 'Triunfa' in df['Result'].tolist():
                        min_error = df[df['Result'].str.contains('Triunfa')].sort_values(by='Error').iloc[0]['Error']
                        min_iter  = df[df['Result'].str.contains('Triunfa')].sort_values(by='Iteration').iloc[0]['Iteration']

                        #Diccionario de métodos con menor iteraciones y menor error
                        data_iter = df[(df['Iteration']==min_iter)].drop(['RE', 'Result'], axis=1).astype(str).to_dict(orient='records')
                        data_error = df[(df['Error']==min_error)].drop(['RE', 'Result'], axis=1).astype(str).to_dict(orient='records')
                        
                    if len(data_iter)==0:
                        data_iter = 0
                    if len(data_error)==0:
                        data_error = 0
                     
                        
                else:
                    data = []
                    
                    size = 0
                x_vars = [f"x{i}" for i in range(1, size+1)]
                # Renderizar resultados
                return render_template(
                    'Seccion_2/resultado_informe2.html',
                    length=length, data=data, x_vars=x_vars, data_iter=data_iter, data_error=data_error
                )

            except matlab.engine.MatlabExecutionError as matlab_error:
                # Capturar errores de MATLAB y renderizar el formulario con un mensaje de error
                error_message = f"Error en MATLAB: {str(matlab_error)}"
                return render_template(
                    'Seccion_2/formulario_informe2.html',
                    error_message=error_message
                )

        except ValueError as ve:
            # Errores específicos de validación
            error_message = str(ve)
            return render_template(
                'Seccion_2/formulario_informe2.html',
                error_message=error_message
            )

        except Exception as e:
            # Capturar cualquier otro error
            error_message = "Error de sintaxis, para más información ir al apartado de ayuda."
            return render_template(
                'Seccion_2/formulario_informe2.html',
                error_message=e
            )

    # Si es una solicitud GET, renderizar el formulario vacío
    return render_template('Seccion_2/formulario_informe2.html')

@blueprint.route('/informe2/descargar', methods=['POST'])
def descargar_archivo_informe2():
    # Ruta del archivo que se va a descargar
    archivo_path = 'tables/tabla_informe2.csv'

    # Enviar el archivo al cliente para descargar
    return send_file(archivo_path, as_attachment=True)