from flask import Blueprint, render_template, request, send_file
import os, json, csv
import matlab.engine
import pandas as pd
import numpy as np
from fractions import Fraction


blueprint = Blueprint('seccion_3', __name__)

eng = matlab.engine.start_matlab()

separador = os.path.sep 
dir_actual = os.path.dirname(os.path.abspath(__file__))
dir_matlab = separador.join(dir_actual.split(separador)[:-1])+'\matlab_codes'
dir_tables = os.path.join(dir_actual, 'tables')

eng.addpath(dir_matlab)

@blueprint.route('/lagrange', methods=['POST', 'GET'])
def lagrange():
    if request.method == 'POST':
    
        x = json.loads(request.form['vectorx'])
        y = json.loads(request.form['vectory'])
        
        eng.addpath(dir_matlab)
        
        matx = matlab.double(x)
        maty = matlab.double(y)
        
        respuesta = eng.lagrange(matx, maty)
        print("respuesta",respuesta)

        df = pd.read_csv(os.path.join(dir_tables,'tabla_lagrange.csv'))
        polinomio = df['Polinomio'][0]
          
        data = df.to_dict(orient='records')
        #print("data",data)

        df.to_excel(os.path.join(dir_tables,'tabla_lagrange.xlsx'), index=False)

        # Gráfica
        imagen_path = os.path.join('static','grafica_lagrange.png')  # Ruta de la imagen
        return render_template('Seccion_3/resultado_lagrange.html',respuesta=polinomio, data=data, imagen_path=imagen_path)
        
    return render_template('Seccion_3/lagrange.html')

@blueprint.route('/lagrange/descargar', methods=['POST'])
def descargar_archivoLagrange():
    # Ruta del archivo que se va a descargar
    archivo_path = 'tables/tabla_lagrange.xlsx'

    # Enviar el archivo al cliente para descargar
    return send_file(archivo_path, as_attachment=True)

@blueprint.route('/newtonint', methods=['POST', 'GET'])
def newtonint():
    if request.method == 'POST':
    
        x = json.loads(request.form['vectorx'])
        y = json.loads(request.form['vectory'])
        print(x)
        print(y)
        
        eng.addpath(dir_matlab)
        
        matx = matlab.double(x)
        maty = matlab.double(y)
        
        respuesta = eng.Newtonint(matx, maty)
        print("respuesta",respuesta)

        df = pd.read_csv(os.path.join(dir_tables,'tabla_polnewton.csv'))
        polinomio = df['Polinomio'][0]
          
        data = pd.read_csv(os.path.join(dir_tables,'tabla_newtonint.csv'))

        # Escribe los datos en un nuevo archivo Excel
        data.to_excel(os.path.join(dir_tables,'tabla_newtonint.xlsx'), index=False) 

        with open(os.path.join(dir_tables,'tabla_newtonint.csv'), 'r') as file:
            csv_reader = csv.reader(file)
            data = list(csv_reader)

        # Gráfica
        imagen_path = os.path.join('static','grafica_newtonint.png')  # Ruta de la imagen
        return render_template('Seccion_3/resultado_newtonint.html',respuesta=polinomio, data=data, imagen_path=imagen_path)
        
    return render_template('Seccion_3/newtonint.html')

@blueprint.route('/newtonint/descargar', methods=['POST'])
def descargar_archivoNewtonInt():
    # Ruta del archivo que se va a descargar
    archivo_path = 'tables/tabla_newtonInt.xlsx'

    # Enviar el archivo al cliente para descargar
    return send_file(archivo_path, as_attachment=True)


@blueprint.route('/vandermonde', methods=['POST', 'GET'])
def vandermonde():
    if request.method == 'POST':
    
        x = json.loads(request.form['vectorx'])
        y = json.loads(request.form['vectory'])
        
        eng.addpath(dir_matlab)
        
        matx = matlab.double(x)
        maty = matlab.double(y)
        
        respuesta = eng.vander(matx, maty)
        print("respuesta",respuesta)

        df = pd.read_csv(os.path.join(dir_tables, 'pol_vandermonde.csv'))
        polinomio = df['Polinomio'][0]
          
        data = df.to_dict(orient='records')
        #print("data",data)

        df.to_excel(os.path.join(dir_tables, 'pol_vandermonde.xlsx'), index=False) 

        # Gráfica
        imagen_path = os.path.join('static', 'grafica_vander.png')
        return render_template('Seccion_3/resultado_vander.html',respuesta=polinomio, data=data, imagen_path=imagen_path)
        
    return render_template('Seccion_3/vandermonde.html')

@blueprint.route('/vandermonde/descargar', methods=['POST'])
def descargar_polvander():
    archivo_path = 'tables/pol_vandermonde.xlsx'

    return send_file(archivo_path, as_attachment=True)


@blueprint.route('/spline', methods=['POST', 'GET'])
def spline():
    if request.method == 'POST':
        
        x = request.form['x']
        y = request.form['y']
        d = int(request.form['d'])
        

        x_list = [float(i.strip()) for i in x.strip("[]").split(',')]
        y_list = [float(i.strip()) for i in y.strip("[]").split(',')]

        xy_sorted = sorted(zip(x_list, y_list))
        x_sorted, y_sorted = zip(*xy_sorted)

        x_matlab = matlab.double(x_sorted)
        y_matlab = matlab.double(y_sorted)

        eng.addpath(dir_matlab)
        
        respuesta = eng.spline(x_matlab, y_matlab, float(d))
        print("respuesta",respuesta)

        df = pd.read_csv(os.path.join(dir_tables, 'tabla_spline.csv'))
        df = df.astype(str)
        data = df.to_dict(orient='records')
        df.to_excel(os.path.join(dir_tables, 'tabla_spline.xlsx'), index=False) 

        imagen_path = os.path.join('static', 'grafica_spline.png')


        x = [str(i) for i in x_sorted] 
        g = d
        grado = []
        while d > 0:
            grado.append(d)
            d = d - 1

        return render_template('Seccion_3/resultado_spline.html',respuesta=respuesta, data=data, imagen_path=imagen_path, x=x, grado = grado, g=g)
        
    return render_template('Seccion_3/spline.html')

@blueprint.route('/spline/descargar', methods=['POST'])
def descargar_archivoSpline():
    # Ruta del archivo que se va a descargar
    archivo_path = 'tables/tabla_spline.xlsx'

    # Enviar el archivo al cliente para descargar
    return send_file(archivo_path, as_attachment=True)


@blueprint.route('/informe3', methods=['POST', 'GET'])
def informe3():
    if request.method == 'POST':
    
        x = json.loads(request.form['x'])
        y = json.loads(request.form['y'])
        x_comp, y_comp = x[-1], y[-1]
        x, y = x[:-1], y[:-1]
        pares = list(zip(x, y))   

        pares_ordenados = sorted(pares, key=lambda par: par[0])

        x_ordenado, y_ordenado = zip(*pares_ordenados)
        
        x = list(x_ordenado)
        y = list(y_ordenado)
        n = len(x)
        x.append(x_comp)
        y.append(y_comp)
        
        eng.addpath(dir_matlab)
        
        x = matlab.double(x)
        y = matlab.double(y)
    
        [tabla1, tabla3, polinomios, errores] = eng.Informe3(x, y, nargout=4)
        polinomios = polinomios[0]
        errores = errores[0]

        polinomios = [polinomios[i * n:(i + 1) * n] for i in range(3)]
        print(polinomios)
        print(errores)
        
        etiquetas = ["Lagrange", "Newton", "Vandermonde"]

        polinomios = [
            [Fraction(c).limit_denominator() for c in pol]
            for pol in polinomios
        ]
    
        polinomios = dict(zip(etiquetas, polinomios))

        etiquetas_error = etiquetas + ['Spline Lineal', 'Spline Cúbico']
        menor_error = min(errores)
        mejor_met = []
        for i, e in enumerate(errores):
            if round(e, 5)==round(menor_error, 5):
                mejor_met.append(etiquetas_error[i])
        
        print(mejor_met)
        # Gráfica
        return render_template('Seccion_3/resultado_informe3.html', x=x[0], tabla1=tabla1, tabla3=tabla3, polinomios=polinomios, errores=errores, mejor_met=mejor_met)

    return render_template('Seccion_3/informe3.html')