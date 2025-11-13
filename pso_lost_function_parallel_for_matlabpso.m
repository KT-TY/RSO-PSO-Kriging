function fitmess = pso_lost_function_parallel_for_matlabpso(p, x, y)
    x = reshape(x, [], 1);
    y = reshape(y, [], 1);
    mp = size(p, 1);
    nx = 30;
    for i = 1 : mp, [dBar, rBar] = sort_by_dmax('x', x, 'y', y, 'dmax', p(4), 'dnum', nx); end
    fitmess = norm((p(1) * (1 - exp(-1 * (dBar ./ p(2)) .^ p(3))) - rBar) / nx);
end
