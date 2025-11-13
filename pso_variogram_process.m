function beta = pso_variogram_process(pso)
    arguments
        pso.op      optim.options.Particleswarm = optimoptions('particleswarm', ...
                                                               'InertiaRange', [0.4, 0.9], ...
                                                               'SwarmSize', 800, ...
                                                               'FunctionTolerance', 1e-12, ...
                                                               'MaxStallIterations', 20, ...
                                                               'MinNeighborsFraction', 0.4);
        pso.model   char {mustBeText} = 'gaussian';
        pso.dBar    double {mustBeVector} = 0
        pso.rBar    double {mustBeVector} = 0
        pso.lostfun function_handle = @sin;
        pso.lb      double = []
        pso.ub      double = []
        pso.plt     double = 1
    end

    switch pso.model
        case 'gaussian'
            beta.fun = @(p, x) (p(1) * (1 - exp(-1 * (x .^ p(3)) ./ (p(2) ^ p(3)))));
            lb = [min(pso.rBar) * 0.01, 0.1, 0.1];
            ub = [max(pso.rBar), 100, 10];
        case 'stable'
            beta.fun = @(p, x) (p(1) * (1 - exp(-1 * (x .^ 1.5) ./ (p(2) ^ 1.5))));
            lb = [min(pso.rBar) * 0.9, 0.1];
            ub = [max(pso.rBar), Inf];
        case 'spherical'
            beta.fun = @(p, x) (p(1) * ((3 * x ./ (2 * p(2))) - 1 / 2 * (x ./ p(2)) .^ 3));
            lb = [min(pso.rBar) * 0.9, 0.1];
            ub = [max(pso.rBar), Inf];
        case 'exponential'
            beta.fun = @(p, x) (p(1) * (1 - exp(-x ./ p(2))));
            lb = [min(pso.rBar) * 0.9, 0.1];
            ub = [max(pso.rBar), Inf];
        otherwise
            warning('Unexpected model type.');
    end
    
    if isequal(@sin, pso.lostfun), pso.lostfun = @(p) norm((beta.fun(p, pso.dBar) - pso.rBar) / length(pso.rBar)); end
    if isempty(pso.lb), pso.lb = lb; end
    if isempty(pso.ub), pso.ub = ub; end
    beta.beta = particleswarm(pso.lostfun, length(pso.ub), pso.lb, pso.ub, pso.op);
    beta.x = pso.dBar;
    beta.y = pso.rBar;

    if pso.plt
        yp = beta.fun(beta.beta, beta.x);
        myfig; plot(beta.x, yp); hold on
        plot(beta.x, beta.y, ':o'); hold off;
        xlabel('d'); ylabel('\gamma(d)');
    end
end