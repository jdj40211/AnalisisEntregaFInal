function [tabla1, tabla3, pol_int, Errores] = Informe3(x,y)
    x_comp = x(end);
    y_comp = y(end);

    x = x(1:end-1);
    y = y(1:end-1);
    n = length(x);
    pol_vander = vander(x, y);
    pol_lagrange = lagrange(x, y);
    [T_N, pol_Newton] = Newtonint(x, y);
    
    
    f_lagrange = 0;
    f_newton = 0;
    f_vander = 0;
    for i = (1:n-1)
        f_lagrange = f_lagrange + x_comp^(n-i)*pol_lagrange(i);
        f_newton = f_newton + x_comp^(n-i)*pol_Newton(i);
        f_vander = f_vander + x_comp^(n-i)*pol_vander(i);
    end
    
    error_lagrange = abs(f_lagrange - y_comp);
    error_newton = abs(f_newton - y_comp);
    error_vander = abs(f_vander - y_comp);

    A1=zeros((2)*(n-1));
    b1=zeros((2)*(n-1),1);

    A3=zeros((4)*(n-1));
    b3=zeros((4)*(n-1),1);
    
    cua=x.^2;
    cub=x.^3;
    
    %lineal
    c=1;
    h=1;
    for i=1:n-1
        A1(i,c)=x(i);
        A1(i,c+1)=1;
        b1(i)=y(i);
        c=c+2;
        h=h+1;
    end
        
    c=1;
    for i=2:n
        A1(h,c)=x(i);
        A1(h,c+1)=1;
        b1(h)=y(i);
        c=c+2;
        h=h+1;
    end

    %% Cubic
    c=1;
    h=1;
    for i=1:n-1
        A3(i,c)=cub(i);
        A3(i,c+1)=cua(i);
        A3(i,c+2)=x(i);
        A3(i,c+3)=1;
        b3(i)=y(i);
        c=c+4;
        h=h+1;
    end
        
    c=1;
    for i=2:n
        A3(h,c)=cub(i);
        A3(h,c+1)=cua(i);
        A3(h,c+2)=x(i);
        A3(h,c+3)=1;
        b3(h)=y(i);
        c=c+4;
        h=h+1;
    end
        
    c=1;
    for i=2:n-1
        A3(h,c)=3*cua(i);
        A3(h,c+1)=2*x(i);
        A3(h,c+2)=1;
        A3(h,c+4)=-3*cua(i);
        A3(h,c+5)=-2*x(i);
        A3(h,c+6)=-1;
        b3(h)=0;
        c=c+4;
        h=h+1;
    end
        
    c=1;
    for i=2:n-1
        A3(h,c)=6*x(i);
        A3(h,c+1)=2;
        A3(h,c+4)=-6*x(i);
        A3(h,c+5)=-2;
        b3(h)=0;
        c=c+4;
        h=h+1;
    end
        
    A3(h,1)=6*x(1);
    A3(h,2)=2;
    b3(h)=0;
    h=h+1;
    A3(h,c)=6*x(end);
    A3(h,c+1)=2;
    b3(h)=0;

    tabla1 = reshape(A1\b1, 2, n-1)';
    tabla3 = reshape(A3\b3, 4, n-1)';
    
    figure;
    hold on;
    plot(x, y, 'ro', 'MarkerFaceColor', 'r'); % Puntos originales
    
    for i = 1:n-1
        xx = linspace(x(i), x(i+1), 100);
        yy = tabla1(i,1)*xx + tabla1(i,2);
        plot(xx, yy, 'b-');
    end
    title('Interpolación Spline Lineal');
    xlabel('x');
    ylabel('y');
    hold off

    figure;
    hold on;
    plot(x, y, 'ro', 'MarkerFaceColor', 'r'); % Puntos originales
    for i = 1:n-1
        xx = linspace(x(i), x(i+1), 100);
        yy = tabla3(i,1)*xx.^3 + tabla3(i,2)*xx.^2 + tabla3(i,3)*xx + tabla3(i,4);
        plot(xx, yy, 'b-');
    end
    title('Interpolación Spline Cúbico');
    xlabel('x');
    ylabel('y');
    hold off

    pos = 0;
    if x_comp >= x(end)
        pos = n-1;
    else
        for i = (1:n-1)
            if x_comp <= x(i+1) && x_comp >= x(i)
                pos = i;
                break;
            end
        end
    end
    
    f_spline1 = tabla1(pos, 1)*x_comp + tabla1(pos, 2);
    f_spline3 = tabla3(pos, 1)*x_comp^3 + tabla3(pos, 2)*x_comp^2 + tabla3(pos, 3)*x_comp + tabla3(pos, 4);
    
    error_spline1 = abs(f_spline1 - y_comp);
    error_spline3 = abs(f_spline3 - y_comp);
    
    pol_int = [pol_lagrange, pol_Newton, pol_vander];
    Errores = [error_lagrange, error_newton, error_vander, error_spline1, error_spline3];

    currentDir = fileparts(mfilename('fullpath'));
    tablesDir = fullfile(currentDir, '..', 'app', 'tables');
    mkdir(tablesDir);
    cd(tablesDir);
    
    % Guardar los archivos CSV
    csv_file_path1 = fullfile(tablesDir, "tabla_spline1.csv");
    csv_file_path3 = fullfile(tablesDir, "tabla_spline3.csv");
    
    writematrix(tabla1, csv_file_path1);
    writematrix(tabla3, csv_file_path3);
end