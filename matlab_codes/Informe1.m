function [res, methods, E, X1, fX1, iter] = Informe1(f, g, x0, x1, xi, xs, tol, niter, error_type)
    [res_b, N_b, x1_b, f_b, E_b] = biseccion(f, xi, xs, tol, niter, error_type);
    [res_new, N_new, x1_new, f_new, df_new, E_new, c_new] = newton(f, x0, tol, niter, error_type);
    [res_pf, N_pf, x1_pf, f_pf, E_pf] = pf(f, g, x0, tol, niter, error_type);
    [res_rm, N_rm, x1_rm, f_rm ,E_rm] = raices_multiples(f, x0, tol, niter, error_type);
    [res_rf, N_rf, x1_rf, f_rf, E_rf] = rf(f, x0, x1, tol, niter, error_type);
    [res_sec, N_sec, x1_sec, f_sec, E_sec] = secante(f, x0, x1, tol, niter, error_type);
    
    
    % Suponiendo que x1_j, x1_g, etc. son vectores columna
    res = repmat({'Fracasa'}, 1, 5);
    X1 = [x1_b(end); x1_new(end); x1_pf(end); x1_rm(end); x1_rf(end); x1_sec(end)];
    E = [E_b(end); E_new(end); E_pf(end); E_rm(end); E_rf(end); E_sec(end)];
    fX1 = [f_b(end); f_new(end); f_pf(end); f_rm(end); f_rf(end); f_sec(end)];
    iter = [N_b(end); N_new(end)-1; N_pf(end); N_rm; N_rf-1; N_sec(end)-1];
    methods = {'Biseccion'; 'Newton'; 'Punto-fijo'; 'Raices-multiples'; 'Regla-falsa'; 'Secante'};
    
    for i = (1:6)
        if E(i)<tol
            res{i} = 'Triunfa';
            %r(i) = 1;
        end
    end
    % Crear nombres para las variables x1, x2, ..., xn
    %n = length(x1_j); 
    %var_names = arrayfun(@(i) sprintf('x%d', i), 1:n, 'UniformOutput', false);
    
    % Crear tabla con todos los datos
    T = table(methods, iter, E, X1, fX1, res', 'VariableNames', {'Method', 'Iteration', 'Error', 'x1', 'fx1', 'Result'});
    
    % Crear directorio si no existe
    currentDir = fileparts(mfilename('fullpath'));
    tablesDir = fullfile(currentDir, '..', 'app', 'tables');
    if ~exist(tablesDir, 'dir')
        mkdir(tablesDir);
    end
    
    % Escribir CSV
    csvFilePath = fullfile(tablesDir, 'tabla_informe1.csv');
    writetable(T, csvFilePath);