function [pol] = vander(vectorx, vectory)
    % Asignar los vectores de entrada
    xv = vectorx;
    yv = vectory;

    % Verificar que los vectores tienen la misma longitud
    if length(xv) ~= length(yv)
        error('Los vectores x e y deben tener la misma longitud.');
    end

    % Establecer la variable "degree"
    degree = length(xv);

    % Crear la matriz de Vandermonde
    A = zeros(degree);
    for i = 1:degree
        for j = 1:degree
            A(i, j) = xv(i)^(degree-j);
        end
    end

    % Resolver el sistema de ecuaciones para encontrar los coeficientes del polinomio
    coeficientes = A \ yv';

    % Construir el polinomio de salida
    pol = coeficientes';

    % Mostrar los resultados
    disp('Matriz de Vandermonde (A):');
    disp(A);
    disp('Vector de términos independientes (yv):');
    disp(yv);
    disp('Coeficientes del polinomio:');
    disp(pol);

    % Crear una representación en cadena del polinomio
    poly_str = '';
    for i = 1:degree
        coef = pol(i);
        exp = degree - i;
        if coef ~= 0
            term = sprintf('%.4f', coef);
            if exp > 0
                term = strcat(term, '*x^', num2str(exp));
            end
            if ~isempty(poly_str) && coef > 0
                poly_str = strcat(poly_str, ' + ', term);
            else
                poly_str = strcat(poly_str, term);
            end
        end
    end
    
    % Guardar el polinomio en un archivo CSV
    tabla = table({poly_str}, 'VariableNames', {'Polinomio'});
    currentDir = fileparts(mfilename('fullpath'));
    tablesDir = fullfile(currentDir, '..', 'app', 'tables');
    if ~exist(tablesDir, 'dir')
        mkdir(tablesDir);
    end
    csv_file_path = fullfile(tablesDir, 'pol_vandermonde.csv');
    writetable(tabla, csv_file_path);

    % Crear un conjunto de puntos para graficar el polinomio
    x_vals = linspace(min(xv), max(xv), 1000);
    y_vals = polyval(pol, x_vals);

    % Graficar el polinomio resultante
    figure;
    plot(x_vals, y_vals, 'r', xv, yv, 'bo'); % Polinomio en rojo, puntos en azul
    title('Polinomio usando matriz de Vandermonde');
    xlabel('x');
    ylabel('y');
    legend('Polinomio', 'Puntos de entrada');
    grid on;
    img = getframe(gcf);
    staticDir = fullfile(currentDir, '..', 'app', 'static');
    if ~exist(staticDir, 'dir')
        mkdir(staticDir);  % Crea el directorio si no existe
    end
    imgPath = fullfile(staticDir, 'grafica_vander.png');

    imwrite(img.cdata, imgPath);

end
