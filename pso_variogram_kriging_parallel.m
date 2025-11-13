%% 数据读取预处理
startup;
load gridRow.mat
load gridKrg.mat
load drMap.mat

nH = size(gridKrg, 1);
nL = size(gridRow, 1);

% 采样点
lat1 = reshape(gridRow(:, :, 1)', [], 1); % y
lon1 = reshape(gridRow(:, :, 2)', [], 1); % x
gBase = gridRow(1, 1, 7);

% 待插值点, 或称为真实点
lat2 = reshape(gridKrg(:, :, 1), nH, nH); % Y
lon2 = reshape(gridKrg(:, :, 2), nH, nH); % X

idx = tril(true(nL ^ 2), -1);
x = [0, reshape(drMap.db(idx), 1, [])];
y = [0, reshape(drMap.rb(idx), 1, [])];
ym = max(y);
xm = max(x);

%%
op = optimoptions('particleswarm', ...
                  'InertiaRange', [0.4, 0.9], ...
                  'SwarmSize', 800, ...
                  'FunctionTolerance', 1e-12, ...
                  'MaxStallIterations', 20, ...
                  'MinNeighborsFraction', 0.4);
npso = 4;
lostfun = @(p) pso_lost_function_parallel_for_matlabpso(p, x, y);
ub1 = [ym, 100, 10, 0.4 * xm];
ub2 = [ym, 100, 10, 0.7 * xm];
ub3 = [ym, 100, 10, 1.0 * xm];
lb1 = [0.01 * ym, 0.1, 0.1, 0.1 * xm];
lb2 = [0.01 * ym, 0.1, 0.1, 0.4 * xm];
lb3 = [0.01 * ym, 0.1, 0.1, 0.7 * xm];
tic; beta1 = particleswarm(lostfun, npso, lb1, ub1, op); toc;
tic; beta2 = particleswarm(lostfun, npso, lb2, ub2, op); toc;
tic; beta3 = particleswarm(lostfun, npso, lb3, ub3, op); toc;

[~, pso1] = pso_lost_function(x, y, beta1);
[~, pso2] = pso_lost_function(x, y, beta2);
[~, pso3] = pso_lost_function(x, y, beta3);

[refStd1, label1] = mapminmax(pso1.yref', 0, 1);
prdStd1 = mapminmax('apply', pso1.yprd', label1);
[refStd2, label2] = mapminmax(pso2.yref', 0, 1);
prdStd2 = mapminmax('apply', pso2.yprd', label2);
[refStd3, label3] = mapminmax(pso3.yref', 0, 1);
prdStd3 = mapminmax('apply', pso3.yprd', label3);

myfig;
subplot(3,1,1);
plot(pso1.x', [refStd1; prdStd1]);
xlabel('d/nm'); ylabel('\it\gamma\rm(d)');
legend('参考值', '预测值', 'Location', 'northwest');
title(sprintf('动态dmax-%.3f', pso1.beta(end)));
subplot(3,1,2);
plot(pso2.x', [refStd2; prdStd2]);
xlabel('d/nm'); ylabel('\it\gamma\rm(d)');
legend('参考值', '预测值', 'Location', 'northwest');
title(sprintf('动态dmax-%.3f', pso2.beta(end)));
subplot(3,1,3);
plot(pso3.x', [refStd3; prdStd3]);
xlabel('d/nm'); ylabel('\it\gamma\rm(d)');
legend('参考值', '预测值', 'Location', 'northwest');
title(sprintf('动态dmax-%.3f', pso3.beta(end)));