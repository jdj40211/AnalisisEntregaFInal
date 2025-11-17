function [r, methods, E, X1, Re, iter] = Informe2(x0, A, b, Tol, niter, w1, w2, w3, error_type)

    x0_j = eval(x0);
    x0_g = eval(x0);
    x0_s1 = eval(x0);
    x0_s2 = eval(x0);
    x0_s3 = eval(x0);

    A = eval(A);
    b = eval(b);
    c = 0;
    error_g = Tol + 1;
    error_j = Tol + 1;
    error_sor1 = Tol + 1;
    error_sor2 = Tol + 1;
    error_sor3 = Tol + 1;

    D = diag(diag(A));
    L = -tril(A, -1);
    U = -triu(A, +1);

    Tj = inv(D) * (L+U);
    Cj = inv(D) * b;
    Re_j=max(abs(eig(Tj)));

    Tg = inv(D-L) * U;
    Cg = inv(D-L) * b;
    Re_g=max(abs(eig(Tg)));

    Tsor1 = inv(D-w1*L) * ((1-w1)*D + w1*U);
    C1 = w1 * inv(D - w1 * L) * b;
    Re1=max(abs(eig(Tsor1)));

    Tsor2 = inv(D-w2*L) * ((1-w2)*D + w2*U);
    C2 = w2 * inv(D - w2 * L) * b;
    Re2=max(abs(eig(Tsor2)));

    Tsor3 = inv(D-w3*L) * ((1-w3)*D + w3*U);
    C3 = w3 * inv(D - w3 * L) * b;
    Re3=max(abs(eig(Tsor3)));

    iter_j = 0;  % Inicializar iter como una lista vacía
    iter_g = 0;  % Inicializar iter como una lista vacía
    iter_sor1 = 0;  % Inicializar iter como una lista vacía
    iter_sor2 = 0;  % Inicializar iter como una lista vacía
    iter_sor3 = 0;  % Inicializar iter como una lista vacía


    
    while (error_g > Tol || error_j > Tol || error_sor1 > Tol || error_sor2 > Tol || error_sor3 > Tol) && c < niter
        if error_j > Tol
            x1_j = Tj * x0_j + Cj;
            
            if strcmp(error_type, 'Error Absoluto')
                error_j = norm(x1_j - x0_j, 'inf');
            else
                error_j = norm((x1_j - x0_j) ./ x1_j, 'inf');
            end

            iter_j = c + 1;   % Agregar n a la lista N
            x0_j = x1_j;
           
        end

        if error_g > Tol
            x1_g = Tg * x0_g + Cg;
            
            if strcmp(error_type, 'Error Absoluto')
                error_g = norm(x1_g - x0_g, 'inf');
            else
                error_g = norm((x1_g - x0_g) ./ x1_g, 'inf');
            end
  
            iter_g = c + 1;   % Agregar n a la lista N
            x0_g = x1_g;
        end
        
        if error_sor1 > Tol
            x1_s1 = Tsor1 * x0_s1 + C1;
           
            if strcmp(error_type, 'Cifras Significativas')
                error_sor1 = norm((x1_s1 - x0_s1) ./ x1_s1, 'inf');
            else
                error_sor1 = norm(x1_s1 - x0_s1, 'inf'); 
            end
            iter_sor1 = c + 1;   % Agregar n a la lista n
            x0_s1 = x1_s1;
        end

        if error_sor2 > Tol
            x1_s2 = Tsor2 * x0_s2 + C2;
           
            if strcmp(error_type, 'Cifras Significativas')
                error_sor2 = norm((x1_s2 - x0_s2) ./ x1_s2, 'inf');
            else
                error_sor2 = norm(x1_s2 - x0_s2, 'inf'); 
            end
            iter_sor2 = c + 1;   % Agregar n a la lista n
            x0_s2 = x1_s2;
        end

        if error_sor3 > Tol
            x1_s3 = Tsor3 * x0_s3 + C3;
           
            if strcmp(error_type, 'Cifras Significativas')
                error_sor3 = norm((x1_s3 - x0_s3) ./ x1_s3, 'inf');
            else
                error_sor3 = norm(x1_s3 - x0_s3, 'inf'); 
            end
            iter_sor3 = c + 1;   % Agregar n a la lista n
            x0_s3 = x1_s3;
        end

        c = c+1;
    end
    % Suponiendo que x1_j, x1_g, etc. son vectores columna
    X1 = [x1_j'; x1_g'; x1_s1'; x1_s2'; x1_s3'];
    r = repmat({'Fracasa'}, 1, 5);
    %r = zeros(1, 5);
    E = [error_j; error_g; error_sor1; error_sor2; error_sor3];
    Re = [Re_j; Re_g; Re1; Re2; Re3];
    iter = [iter_j; iter_g; iter_sor1; iter_sor2; iter_sor3];
    methods = {'Jacobi'; 'Gauss-Seidel'; 'SOR-w1'; 'SOR-w2'; 'SOR-w3'};
    
    for i = (1:5)
        if E(i)<Tol
            r{i} = 'Triunfa';
            %r(i) = 1;
        end
    end
    % Crear nombres para las variables x1, x2, ..., xn
    n = length(x1_j); 
    var_names = arrayfun(@(i) sprintf('x%d', i), 1:n, 'UniformOutput', false);
    
    % Crear tabla con todos los datos
    x_table = array2table(X1, 'VariableNames', var_names);
    T = table(methods, iter, E, Re, r', 'VariableNames', {'Method', 'Iteration', 'Error', 'RE', 'Result'});
    T = [T, x_table];
    
    % Crear directorio si no existe
    currentDir = fileparts(mfilename('fullpath'));
    tablesDir = fullfile(currentDir, '..', 'app', 'tables');
    if ~exist(tablesDir, 'dir')
        mkdir(tablesDir);
    end
    
    % Escribir CSV
    csvFilePath = fullfile(tablesDir, 'tabla_informe2.csv');
    writetable(T, csvFilePath);
    



end