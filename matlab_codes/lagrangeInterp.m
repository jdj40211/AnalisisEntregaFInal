function [pol] = lagrangeInterp(vectorx, vectory)
    % Validar entradas
    if nargin < 2
        error('Se requieren dos vectores de entrada: vectorx y vectory');
    end

    xv = vectorx;
    yv = vectory;
    n = length(xv);

    % Validar que los vectores tengan la misma longitud
    if length(xv) ~= length(yv)
        error('Los vectores x e y deben tener la misma longitud');
    end

    % Validar que haya al menos 2 puntos
    if n < 2
        error('Se requieren al menos 2 puntos para la interpolación');
    end

    % Validar que no haya valores x duplicados
    if length(unique(xv)) ~= n
        error('Los valores de x deben ser únicos para la interpolación');
    end
    Tabla = zeros(n, n);
    for i = 1:n
        Li = 1;
        den = 1;
        for j = 1:n
            if j ~= i
                paux = [1, -xv(j)];
                Li = conv(Li, paux);
                den = den * (xv(i) - xv(j));
            end
        end
        Tabla(i, :) = yv(i) * Li / den;
    end
    pol = sum(Tabla);

    % Crear una representación en cadena del polinomio (sin symbolic toolbox)
    degree = length(pol) - 1;
    polinomio_str = '';
    for i = 1:length(pol)
        coef = pol(i);
        exp = degree - (i - 1);
        if abs(coef) > 1e-10  % Ignorar coeficientes muy pequeños
            term = sprintf('%.4f', coef);
            if exp > 1
                term = strcat(term, '*x^', num2str(exp));
            elseif exp == 1
                term = strcat(term, '*x');
            end
            if ~isempty(polinomio_str)
                if coef > 0
                    polinomio_str = strcat(polinomio_str, ' + ', term);
                else
                    polinomio_str = strcat(polinomio_str, ' ', term);
                end
            else
                polinomio_str = term;
            end
        end
    end

    % Si el polinomio está vacío (todos los coeficientes eran muy pequeños), usar '0'
    if isempty(polinomio_str)
        polinomio_str = '0';
    end


    % Guardar el polinomio en un archivo CSV
    tabla = table({polinomio_str}, 'VariableNames', {'Polinomio'});
    currentDir = fileparts(mfilename('fullpath'));
    tablesDir = fullfile(currentDir, '..', 'app', 'tables');
    mkdir(tablesDir);

    csv_file_path = fullfile(tablesDir, 'tabla_lagrange.csv');
    writetable(tabla, csv_file_path);

    % Crear un conjunto de puntos para graficar el polinomio
    x_vals = linspace(min(xv), max(xv), 1000);
    y_vals = polyval(pol, x_vals);

    % Graficar el polinomio resultante
    figure;
    plot(x_vals, y_vals, 'r', xv, yv, 'bo'); % Polinomio en rojo, puntos en azul
    title('Polinomio de Lagrange');
    xlabel('x');
    ylabel('y');
    legend('Polinomio de Lagrange', 'Puntos de entrada');
    grid on;

    img = getframe(gcf);
    staticDir = fullfile(currentDir, '..', 'app', 'static');
    mkdir(staticDir);
    imgPath = fullfile(staticDir, 'grafica_lagrange.png');
    imwrite(img.cdata, imgPath);
end
