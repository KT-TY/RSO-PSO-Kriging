function [dBar, rBar] = variogram_dataset(Dx, z, numDis, dmax)
    if nargin < 3, numDis = 30; end
    if nargin < 4, dmax = 42.71; end
    [n, m] = size(Dx);

    if m == n
        Z = bsxfun(@minus, z', z) .^ 2 / 2;
        numset = (n + 1) * n / 2;
        [d, r] = deal(zeros(numset, 1));
        nn = 0;

        for i = 1 : n
            ni = nn + 1;
            nn = nn + n - i + 1;
            d(ni : nn) = Dx(i, i : n)';
            r(ni : nn) = Z(i, i : n)';
        end
    elseif m == 1
        d = Dx;
        r = z;
    end

    % 需要调整策略
    % dmax = max(d) / 2;
    % tol = dmax / numDis;
    % idx = d < dmax;
    % dLimit = d(idx);
    % rLimit = r(idx);
    % edges = linspace(0, dmax, numDis + 1);
    % [~, ~, idx] = histcounts(dLimit, edges);            % 按范围划分dx
    % rBar = accumarray(idx, rLimit, [numDis, 1], @mean); % 按相同范围计算半方差均值
    % dBar = (edges(1 : end - 1) + tol / 2)';             % 理论上dBar应是每个范围的中点
    [dBar, rBar] = sort_by_dmax('x', d, 'y', r, 'dnum', numDis, 'dmax', dmax);
end
