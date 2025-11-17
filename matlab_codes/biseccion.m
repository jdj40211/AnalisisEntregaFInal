function [r, N, xn, fm, E] = biseccion(f_str, xi, xs, Tol, niter, tipe)
    % Convertir la cadena de la función a una función manejable
    f_str = strrep(f_str, '^', '.^');  % Reemplazar ^ con .^
    f = str2func(['@(x)', f_str]);

    % Evaluar la función en los extremos del intervalo
    fi = f(xi);
    fs = f(xs);

    % Inicializar las listas
    N_list = [];
    xn_list = [];
    fm = [];
    E = [];

    if fi == 0
        r  = sprintf('%f es raíz de f(x)', xi);
        N  = 0;
        xn = xi;
        fm = f(xi);
        E  = 0;
        return;
    elseif fs == 0
        r  = sprintf('%f es raíz de f(x)', xs);
        N  = 0;
        xn = xs;
        fm = f(xs);
        E  = 0;
        return;
    elseif fs * fi < 0
        N = 0;
        xm = (xi + xs) / 2;
        fm(1) = f(xm);
        fe = fm(1);
        N_list(1) = N;
        xn_list(1) = xm;
        E(1) = Tol + 1;
        err = E(1);
        while err > Tol && fe ~= 0 && N < niter
            if fi * fe < 0
                xs = xm;
                fs = f(xs);
            else
                xi = xm;
                fi = f(xi);
            end
            xa = xm;
            xm = (xi + xs) / 2;
            N = N + 1;
            fm(N + 1) = f(xm);
            fe = fm(N + 1);
            N_list(N + 1) = N;
            xn_list(N + 1) = xm;
            if strcmp(tipe, 'Cifras Significativas')
                E(N + 1) = abs(xm - xa) / abs(xm);
            else
                E(N + 1) = abs(xm - xa);
            end
            err = E(N + 1);
        end
        if fe == 0
            N = N + 1;
            xn_list(N) = xm;
            E(N)        = 0;
            fm(N)       = fe;
            xn = xm;
            r = sprintf('%f es raíz de f(x)', xm);
        elseif err < Tol
            xn = xm;
            r = sprintf('%f es una aproximación de una raíz de f(x) con una tolerancia = %f', xm, Tol);
        else
            xn = xm;
            r = sprintf('Fracasó en %d iteraciones', niter);
        end
    elseif fs * fi > 0
        error('Biseccion:IntervaloInvalido', ...
        'fs * fi > 0')
    else

        r = sprintf('El intervalo es inadecuado');
        N = 0;
        xn = NaN; 
        xn_list = NaN;
        fm = NaN;
        E = NaN;
        N_list = [];
    end
    
    % Asignar las listas de iteración y resultados si no están vacías
    if ~isempty(N_list)
        N = N_list;
        xn = xn_list;
    end

    % Guardar la tabla de resultados en un archivo CSV solo si el intervalo es adecuado
    if ~isempty(N_list)
        currentDir = fileparts(mfilename('fullpath')); % Directorio actual del script
        tablesDir = fullfile(currentDir, '..', 'app', 'tables'); % Ruta a la carpeta "tables"
        if ~exist(tablesDir, 'dir') % Si la carpeta no existe, crearla
            mkdir(tablesDir);
        end
        % Generar la tabla y escribirla en un archivo CSV
        csv_file_path = fullfile(tablesDir, 'tabla_biseccion.csv');
        T = table(N', xn', fm', E', 'VariableNames', {'Iteration', 'xn', 'fxn', 'E'});
        writetable(T, csv_file_path);
        disp(['Tabla de resultados generada en: ', csv_file_path]);
    else
        warning('No se pudo generar la tabla de resultados porque N_list está vacío.');
    end

        % Crear y guardar la gráfica de resultados solo si xn no está vacío
    if isempty(xn)
        warning('La lista xn está vacía. No se puede generar la gráfica.');
    else
        fig = figure('Visible', 'off');
        hold on;
        xplot = linspace(min(xn) - 0.5, max(xn) + 0.5, 1000); % Rango de la gráfica
        yline(0, '--', 'Color', 'black'); % Línea del eje Y
        plot(xplot, f(xplot), 'b', 'LineWidth', 1.5); % Gráfica de la función
        scatter(xn, f(xn), 'r', 'filled'); % Puntos intermedios
        scatter(xn(end), f(xn(end)), 'g', 'filled', 'DisplayName', 'Raíz aproximada'); % Raíz aproximada
        legend('Función', 'Iteraciones', 'Raíz aproximada');
        title(['f(x) = ', f_str]); % Título dinámico con la función
        xlabel('x');
        ylabel('f(x)');
        grid on;

        % Generar un nombre seguro para el archivo basado en la función
        safe_f_str = regexprep(f_str, '[^a-zA-Z0-9]', '_');

        % Guardar en formato SVG
        staticDir = fullfile(currentDir, '..', 'app', 'static'); % Ruta a la carpeta "static"
        if ~exist(staticDir, 'dir')
            mkdir(staticDir);
        end
        svgPath = fullfile(staticDir, ['biseccion.svg']);
        saveas(fig, svgPath, 'svg');

        disp(['Gráfica SVG generada en: ', svgPath]);
        close(fig);
    end
end
