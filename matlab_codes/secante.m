function [respuesta, N, XN, fm, E] = secante(func, x0, x1, Tol, niter, Terror)
    % Convertir la función de entrada a un handle de función
    f = str2func(['@(x)', func]);
    c = 0;
    if x0 == x1
        error('Secante:ValoresInvalidos', ...
        'Los valores x0 y x1 deben ser distintos');
    end
    % Inicializar vectores
    fm = zeros(1, niter + 1);
    E = zeros(1, niter + 1);
    N = zeros(1, niter + 1);
    XN = zeros(1, niter + 1);

    % Evaluar la función en los puntos iniciales
    fm(c + 1) = f(x0);
    f0 = fm(c + 1);
    fm(c + 2) = f(x1);
    fe = fm(c + 2);
    E(c + 1) = Tol + 1;
    E(c + 2) = Tol + 1;
    xn = x1;

    % Guardar las primeras iteraciones
    N(c + 1) = c;
    N(c + 2) = c + 1;
    XN(c + 1) = x0;
    XN(c + 2) = xn;

    % Iterar hasta cumplir criterios de parada
    while E(c + 2) > Tol && fe ~= 0 && c < niter
        % Calcular siguiente aproximación
        xm = xn - ((fe * (xn - x0)) / (fe - f0));
        XN(c + 3) = xm;

        % Actualizar valores
        f0 = fe;
        fm(c + 3) = f(xm);
        fe = fm(c + 3);

        % Calcular error según el criterio especificado
        if strcmp(Terror, 'Decimales Correctos')
            E(c + 3) = abs(xm - xn);
        else
            E(c + 3) = abs((xm - xn) / xm);
        end

        % Actualizar iteración
        x0 = xn;
        xn = xm;

        N(c + 3) = c + 2;
        c = c + 1;
    end

    % Verificar resultados finales
    if fe == 0
        respuesta = sprintf('%f es raíz exacta de f(x)', xn);
        E(c + 2) = 0;
    elseif E(c + 2) < Tol
        respuesta = sprintf('%f es una aproximación con tolerancia = %f', xn, Tol);
    else
        respuesta = sprintf('Fracasó en %d iteraciones', niter);
    end

    % Recortar vectores a la longitud utilizada
    N = N(1:c + 2);
    XN = XN(1:c + 2);
    fm = fm(1:c + 2);
    E = E(1:c + 2);

    % Crear tabla de resultados
    T = table(N', XN', fm', E', 'VariableNames', {'Iteration', 'xn', 'fxn', 'Error'});

    % Guardar tabla como CSV
    currentDir = fileparts(mfilename('fullpath'));
    tablesDir = fullfile(currentDir, '..', 'app', 'tables');
    if ~exist(tablesDir, 'dir')
        mkdir(tablesDir);
    end
    csvFilePath = fullfile(tablesDir, 'tabla_secante.csv');
    writetable(T, csvFilePath);

    % Crear gráfica de convergencia
    fig = figure('Visible', 'off');
    xplot = linspace(min(XN) - 1, max(XN) + 1, 1000);
    plot(xplot, arrayfun(f, xplot), 'b', 'LineWidth', 1.5);
    hold on;
    scatter(XN, arrayfun(f, XN), 'ro');
    yline(0, '--k');
    title(['f(x) = ', func]); % Título dinámico
    xlabel('x');
    ylabel('f(x)');
    grid on;

    % Generar nombre seguro para el archivo basado en la función
    safe_func_name = regexprep(func, '[^a-zA-Z0-9]', '_');

    % Guardar como SVG
    staticDir = fullfile(currentDir, '..', 'app', 'static');
    if ~exist(staticDir, 'dir')
        mkdir(staticDir);
    end
    svgPath = fullfile(staticDir, ['secante.svg']);
    saveas(fig, svgPath, 'svg');
    close(fig);
    
end
