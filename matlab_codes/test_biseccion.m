
% Test the biseccion.m function with sample inputs
clc;
clear;

% Definicion de Parametros
f_str = 'x^3 - x - 2';
xi = 1;
xs = 2;
Tol = 1e-6;
niter = 50;
tipe = 'Cifras Significativas';

[r, N, xn, fm, E] = biseccion(f_str, xi, xs, Tol, niter, tipe);

% Display results
disp('Raíz aproximada:');
disp(r);
disp('Iteraciones:');
disp(N);
disp('Valores de xn:');
disp(xn);
disp('Errores:');
disp(E);

% Check if the table and graph files were generated
tables_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'app', 'tables');
static_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'app', 'static');
csv_file = fullfile(tables_dir, 'tabla_biseccion.csv');
graph_file = fullfile(static_dir, 'grafica_biseccion.png');

if exist(csv_file, 'file')
    disp(['Tabla de resultados generada en: ', csv_file]);
else
    disp('Tabla de resultados no se generó.');
end

if exist(graph_file, 'file')
    disp(['Gráfica generada en: ', graph_file]);
else
    disp('Gráfica no se generó.');
end
