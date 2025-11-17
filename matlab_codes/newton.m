function [r, N, xn, fm, dfm, E, c] = newton(f_str, x0, Tol, niter, et)
    % Crear función anónima directamente
    f = str2func(['@(x) ' f_str]);
    
    % Calcular la derivada numéricamente
    h = 1e-7;
    df = @(x) (f(x + h) - f(x)) / h;
    
    % Inicializar variables
    c = 0;
    fm(c+1) = f(x0);
    fe = fm(c+1);
    dfm(c+1) = df(x0);
    dfe = dfm(c+1);
    E(c+1) = Tol + 1;
    err = E(c+1);
    xn(c+1) = x0;
    N(c+1) = c;
    
    % Iteraciones del método
    while err > Tol && c < niter
        xn(c+2) = x0 - fe / dfe;
        fm(c+2) = f(xn(c+2));
        fe = fm(c+2);
        dfm(c+2) = df(xn(c+2));
        dfe = dfm(c+2);

        % Validar derivada
        if dfe == 0
            error('La derivada se anuló, posible raíz múltiple o estancamiento.');
        end
        
        if strcmp(et, 'Error Absoluto')
            E(c+2) = abs(xn(c+2) - x0);
        else
            E(c+2) = abs(xn(c+2) - x0) / abs(xn(c+2));
        end
        
        err = E(c+2);
        x0 = xn(c+2);
        N(c+2) = c+1;
        c = c + 1;
    end
    
    % Mensajes de resultado
    if fe == 0
       r = sprintf('%f es raíz de f(x)', x0);
    elseif err < Tol
       r = sprintf('%f es una aproximación de una raíz de f(x) con una tolerancia = %f', x0, Tol);
    else 
       r = sprintf('Fracasó en %f iteraciones', niter);
    end

    % Ajustar vectores a la misma longitud
    max_length = min([length(N), length(xn), length(fm), length(dfm), length(E)]);
    N = N(1:max_length);
    xn = xn(1:max_length);
    fm = fm(1:max_length);
    dfm = dfm(1:max_length);
    E = E(1:max_length);

    % Crear y guardar tabla CSV
    T = table(N', xn', fm', dfm', E', 'VariableNames', {'Iteration', 'xn', 'fxn', 'dfxn', 'Error'});

    currentDir = fileparts(mfilename('fullpath'));
    tablesDir = fullfile(currentDir, '..', 'app', 'tables');
    if ~exist(tablesDir, 'dir')
        mkdir(tablesDir);
    end
    csv_file_path = fullfile(tablesDir, 'tabla_newton.csv');
    writetable(T, csv_file_path);

    % Crear gráfica
    disp('Iniciando generación de gráfica...');
    fig = figure('Visible', 'off');

    x_min = min(xn) - 2;
    x_max = max(xn) + 2;

    % Validar si x_min y x_max son iguales
    if x_min == x_max
        x_min = x_min - 1;
        x_max = x_max + 1;
    end

    disp(['Rango de x: ', num2str(x_min), ' a ', num2str(x_max)]);

    x_plot = linspace(x_min, x_max, 100);
    y_plot = arrayfun(f, x_plot);

    hold on;
    yline(0, '--k'); % Línea horizontal en y = 0
    plot(x_plot, y_plot, 'b', 'LineWidth', 1.5); % Curva de la función
    scatter(xn, arrayfun(f, xn), 'ro'); % Puntos de las iteraciones
    title(['f(x) = ' f_str]); % Título dinámico con la función
    xlabel('x');
    ylabel('f(x)');
    grid on;

    % Guardar gráfica como SVG
    staticDir = fullfile(currentDir, '..', 'app', 'static');
    if ~exist(staticDir, 'dir')
        mkdir(staticDir);
    end

    % Generar nombre seguro para el archivo
    safe_f_str = regexprep(f_str, '[^a-zA-Z0-9]', '_');
    svgPath = fullfile(staticDir, ['newton.svg']);
    disp(['Guardando gráfica como: ', svgPath]);
    saveas(fig, svgPath, 'svg'); % Guardar como SVG
    close(fig); % Cerrar la figura

end
