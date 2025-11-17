function [respuesta, c, x1_rf, f_rf, E_rf] = rf(func, x0, x1, Tol, niter, Terror)
    % Convertir la función de entrada a un handle de función
    f = str2func(['@(x)', func]);

    % Inicializar valores
    c = 1;
    xi(c) = x0;
    xs(c) = x1;
    fi(c) = f(xi(c));
    fs(c) = f(xs(c));

    % Verificar raíces inmediatas
    if fi(c) == 0
        xm(c) = xi(c);
        fm(c) = f(xm(c));
        E(c) = 0;
        respuesta = sprintf('El límite inferior %f es raíz de f(x)', xi(c));
        x1_rf = xm;
        f_rf = fm;
        E_rf = E;
        return;
    elseif fs(c) == 0
        xm(c) = xs(c);
        fm(c) = f(xm(c));
        E(c) = 0;
        respuesta = sprintf('El límite superior %f es raíz de f(x)', xs(c));
        x1_rf = xm;
        f_rf = fm;
        E_rf = E;
        return;
    elseif fi(c) * fs(c) > 0
        respuesta = 'El intervalo proporcionado no es adecuado.';
        xm = NaN;
        fm = NaN;
        E = NaN;
        x1_rf = xm;
        f_rf = fm;
        E_rf = E;
        error('ReglaFalsa:IntervaloInvalido', ...
        'El intervalo es inadecuado: f(x0) * f(x1) >= 0');
        return;
    end

    % Iteración inicial
    xm(c) = xi(c) - (fi(c) * (xs(c) - xi(c))) / (fs(c) - fi(c));
    fm(c) = f(xm(c));
    E(c) = Tol + 1;

    % Iterar hasta que se cumpla la tolerancia o el número de iteraciones
    while E(c) > Tol && c < niter
        % Calcular nuevo intervalo
        if fm(c) == 0
            break; % Se encontró la raíz exacta
        elseif fm(c) * fi(c) < 0
            xs(c + 1) = xm(c);
            fs(c + 1) = fm(c);
            xi(c + 1) = xi(c);
            fi(c + 1) = fi(c);
        else
            xi(c + 1) = xm(c);
            fi(c + 1) = fm(c);
            xs(c + 1) = xs(c);
            fs(c + 1) = fs(c);
        end

        % Calcular nuevo xm y error
        xm(c + 1) = xi(c + 1) - (fi(c + 1) * (xs(c + 1) - xi(c + 1))) / (fs(c + 1) - fi(c + 1));
        fm(c + 1) = f(xm(c + 1));
        if strcmp(Terror, 'Decimales Correctos')
            E(c + 1) = abs(xm(c + 1) - xm(c));
        else
            E(c + 1) = abs((xm(c + 1) - xm(c)) / xm(c + 1));
        end

        c = c + 1;
    end

    % Verificar resultado final
    if fm(c) == 0
        respuesta = sprintf('%f es raíz exacta de f(x) en %d iteraciones', xm(c), c);
        E(c) = 0;
    elseif E(c) < Tol
        respuesta = sprintf('%f es una aproximación con tolerancia = %f en %d iteraciones', xm(c), Tol, c);
    else
        respuesta = sprintf('Fracasó en %d iteraciones', niter);
    end
    x1_rf = xm;
    f_rf = fm;
    E_rf = E;
    % Crear tabla de resultados
    T = table((1:c)', xm', xi', xs', fm', fi', fs', E', ...
        'VariableNames', ["n", "x_m", "x_i", "x_s", "f_m", "f_i", "f_s", "E"]);

    % Guardar tabla como CSV
    currentDir = fileparts(mfilename('fullpath'));
    tablesDir = fullfile(currentDir, '..', 'app', 'tables');
    if ~exist(tablesDir, 'dir')
        mkdir(tablesDir);
    end
    csvFilePath = fullfile(tablesDir, 'tabla_reglaFalsa.csv');
    writetable(T, csvFilePath);

    % Graficar resultados
    fig = figure('Visible', 'off');
    xplot = linspace(min([xi, xs]) - 1, max([xi, xs]) + 1, 1000);
    plot(xplot, arrayfun(f, xplot), 'b', 'LineWidth', 1.5);
    hold on;
    scatter(xm, arrayfun(f, xm), 'ro');
    yline(0, '--k');
    title(['f(x) = ', func]); % Título dinámico
    xlabel('x');
    ylabel('f(x)');
    grid on;

    % Guardar la gráfica con un nombre dinámico basado en la función
    safe_func = regexprep(func, '[^a-zA-Z0-9]', '_');
    staticDir = fullfile(currentDir, '..', 'app', 'static');
    if ~exist(staticDir, 'dir')
        mkdir(staticDir);
    end
    svgPath = fullfile(staticDir, ['rf.svg']);
    saveas(fig, svgPath, 'svg');
    disp(['Gráfica SVG generada en: ', svgPath]);
    close(fig);
end
