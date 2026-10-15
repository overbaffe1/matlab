function [arr, svc, wait, grid, u_cum, rho, n] = smo_progon(T, meanIA, kindIA, a, b, kindS, seed)
%SMO_PROGON  Одноканальная СМО A -> Q -> S -> R (FIFO, один сервер).
%  T      — горизонт, с
%  meanIA — средний интервал поступления, с
%  kindIA — 'const' или 'exp'
%  a,b    — параметры обслуживания (для uniform: min и max; для exp: среднее)
%  kindS  — 'uniform' или 'exp'
%  seed   — зерно генератора

    rng(seed);
    t = 0; tFree = 0;
    arr = []; svc = []; wait = [];
    busy = 0;
    left = []; right = [];
    while true
        if strcmp(kindIA, 'const')
            ia = meanIA;
        else
            ia = -meanIA * log(rand());
        end
        t = t + ia;
        if t > T
            break;
        end
        if strcmp(kindS, 'uniform')
            s = a + (b - a) * rand();
        else
            s = -a * log(rand());
            if s < 2, s = 2; end
            if s > 3*a, s = 3*a; end
        end
        start = max(t, tFree);
        finish = start + s;
        w = start - t;
        clip = min(finish, T);
        if clip > start
            busy = busy + (clip - start);
            left(end+1)  = start; %#ok<AGROW>
            right(end+1) = clip;  %#ok<AGROW>
        end
        tFree = finish;
        arr(end+1)  = t; %#ok<AGROW>
        svc(end+1)  = s;
        wait(end+1) = w;
    end
    n = numel(arr);
    rho = busy / T;
    grid = linspace(0, T, 400);
    inst = zeros(size(grid));
    for i = 1:numel(left)
        inst(grid >= left(i) & grid < right(i)) = 1;
    end
    u_cum = cumsum(inst) ./ (1:numel(inst));
end
