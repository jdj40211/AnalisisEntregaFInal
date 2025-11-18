function [r, N, xn, fm, E] = pf(f_str, g_str, x0, Tol, niter, tipe)
    currentDir = fileparts(mfilename('fullpath'));
    f = str2func(['@(x)' f_str]);
    g = str2func(['@(x)' g_str]);
    % —– Validación básica: verificar que g(x0) es diferente de x0 —–
    % Para punto fijo, buscamos x = g(x), por lo que si x0 = g(x0),
    % ya encontramos un punto fijo (que debería ser raíz de f)
    g0 = g(x0);
    f0 = f(x0);

    % Si g(x0) = x0, verificar si es raíz
    if abs(g0 - x0) < 1e-10
        if abs(f0) < 1e-10
            % Ya encontramos la raíz
            return;
        else
            warning('PuntoFijo:PuntoFijoNoEsRaiz', ...
                'x0=%g es un punto fijo de g(x) pero no es raíz de f(x). |f(x0)|=%.3g', ...
                x0, abs(f0));
        end
    end

    % Inicializar variables como vectores
    fm = zeros(1, niter + 1);
    E = zeros(1, niter + 1);
    xn = zeros(1, niter + 1);
    N = zeros(1, niter + 1);

    c = 0;
    xn(c + 1) = x0;
    fm(c + 1) = f(x0);
    fe = fm(c + 1);
    if fe == 0
        r      = sprintf('%f es raíz de f(x)\n', x0);
        N      = 0;
        xn     = x0;
        fm     = f(x0);
        E      = 0;
        T = table(0, x0, f(x0), 0, ...
            'VariableNames', {'Iteration','xn','fxn','E'});
        tablesDir = fullfile(currentDir, '..', 'app', 'tables');
        if ~exist(tablesDir,'dir'), mkdir(tablesDir); end
        writetable(T, fullfile(tablesDir, 'tabla_pf.csv'));
        return
    end
    E(c + 1) = Tol + 1;
    err = E(c + 1);
    N(c + 1) = c;

    while err > Tol && fe ~= 0 && c < niter
        xn(c + 2) = g(x0);
        fm(c + 2) = f(xn(c + 2));
        fe = fm(c + 2);

        if strcmp(tipe, 'Cifras Significativas')
            E(c + 2) = abs(xn(c + 2) - x0) / abs(xn(c + 2));
        else
            E(c + 2) = abs(xn(c + 2) - x0);
        end

        err = E(c + 2);
        x0 = xn(c + 2);
        N(c + 2) = c + 1;
        c = c + 1;
    end

    % Recortar las variables a las iteraciones realmente necesarias
    N = N(1:c + 1);
    xn = xn(1:c + 1);
    fm = fm(1:c + 1);
    E = E(1:c + 1);

    if fe == 0 && f ~= "inf"
        r = sprintf('%f es raíz de f(x)\n', x0);
    elseif err < Tol
        r = sprintf('%f es una aproximación de una raíz de f(x) con una tolerancia= %f\n', x0, Tol);
    else
        error('PuntoFijo:FuncionInvalida', ...
        'La función g(x) no garantiza convergencia (∣g´(x)∣>=1)');
    end

    % Guardar los resultados en un archivo CSV
    
    tablesDir = fullfile(currentDir, '..', 'app', 'tables');
    if ~exist(tablesDir, 'dir')
        mkdir(tablesDir);
    end
    csv_file_path = fullfile(tablesDir, 'tabla_pf.csv');
    T = table(N', xn', fm', E', 'VariableNames', {'Iteration', 'xn', 'fxn', 'E'});
    writetable(T, csv_file_path);

    % Generar un nombre seguro para el archivo basado en la función
    safe_f_str = regexprep(f_str, '[^a-zA-Z0-9]', '_'); % Reemplazar caracteres no permitidos

    % Generar y guardar la gráfica como SVG
    fig = figure('Visible', 'off');
    x_min = min(xn) - 2;
    x_max = max(xn) + 2;
    xplot = linspace(x_min, x_max, 1000);
    yplot = arrayfun(f, xplot);

    hold on;
    yline(0, '--', 'Color', 'black'); % Línea del eje Y
    plot(xplot, yplot, 'b', 'LineWidth', 1.5); % Curva de la función
    scatter(xn(end), fm(end), 'r', 'filled', 'DisplayName', 'Raíz aproximada'); % Raíz aproximada
    title(['f(x) = ' f_str]); % Título dinámico con la función
    xlabel('x');
    ylabel('f(x)');
    legend;
    grid on;


    staticDir = fullfile(currentDir, '..', 'app', 'static');
    if ~exist(staticDir, 'dir')
        mkdir(staticDir);
    end
    svgPath = fullfile(staticDir, ['pf.svg']);
    saveas(fig, svgPath, 'svg'); % Guardar como SVG
    disp(['Gráfica SVG generada en: ', svgPath]);

    hold off;
    close(fig);
end
