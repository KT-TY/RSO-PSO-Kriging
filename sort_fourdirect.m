function [EW, SN, NE, NW] = sort_fourdirect(x, y, z, kd, meanFlag)
    if nargin < 4, kd = 1; end
    if nargin < 5, meanFlag = 0; end
    [m, n] = size(z);
    numst = numel(z);
    maxmn = max(m, n);
    minmn = min(m, n);
    if n == 1, error('input data must be a matrix.'); end

    %%% 网格坐标法快速查找
    i = reshape(repmat(1 : m, [n, 1]), 1, []);
    j = reshape(repmat(1 : n, [m, 1])', 1, []);
    zij = reshape(z', 1, []);
    xij = reshape(x', 1, []);
    yij = reshape(y', 1, []);

    diffi = bsxfun(@minus, i, i');
    diffj = bsxfun(@minus, j, j');
    rij = bsxfun(@minus, zij, zij') .^ 2;
    dij = hypot(bsxfun(@minus, xij, xij'), bsxfun(@minus, yij, yij')) * kd;
    clearvars i j xij yij zij

    % EW
    for dd = 1 : n - 1
        if dd == 1, s = struct('d', nan(maxmn - 1, numst + 1), 'r', nan(maxmn - 1, numst + 1)); end
        idx = and(diffi == 0, diffj == dd);
        tmp = [dij(idx), rij(idx)];
        tr = tmp(~isnan(tmp(:, 2)), :);

        if meanFlag == 0
            s.d(dd, 1 : size(tr, 1) + 1) = [dd; tr(:, 1)]';
            s.r(dd, 1 : size(tr, 1) + 1) = [dd; tr(:, 2)]';
        else
            s.d(dd, 1 : 2) = [dd; mean(tr(:, 1))]';
            s.r(dd, 1 : 2) = [dd; mean(tr(:, 2))]';
        end
    end

    EW = reshape_struct(s, dd + 1, 'EW');

    % SN
    for dd = 1 : m - 1
        if dd == 1, s = struct('d', nan(maxmn - 1, numst + 1), 'r', nan(maxmn - 1, numst + 1)); end
        idx = and(diffi == dd, diffj == 0);
        tmp = [dij(idx), rij(idx)];
        tr = tmp(~isnan(tmp(:, 2)), :);
        
        if meanFlag == 0
            s.d(dd, 1 : size(tr, 1) + 1) = [dd; tr(:, 1)]';
            s.r(dd, 1 : size(tr, 1) + 1) = [dd; tr(:, 2)]';
        else
            s.d(dd, 1 : 2) = [dd; mean(tr(:, 1))]';
            s.r(dd, 1 : 2) = [dd; mean(tr(:, 2))]';
        end
    end

    SN = reshape_struct(s, dd + 1, 'SN');

    % NE
    for dd = 1 : minmn - 1
        if dd == 1, s = struct('d', nan(maxmn - 1, numst + 1), 'r', nan(maxmn - 1, numst + 1)); end
        idx = and(diffi == dd, diffj == dd);
        tmp = [dij(idx), rij(idx)];
        tr = tmp(~isnan(tmp(:, 2)), :);
        
        if meanFlag == 0
            s.d(dd, 1 : size(tr, 1) + 1) = [dd; tr(:, 1)]';
            s.r(dd, 1 : size(tr, 1) + 1) = [dd; tr(:, 2)]';
        else
            s.d(dd, 1 : 2) = [dd; mean(tr(:, 1))]';
            s.r(dd, 1 : 2) = [dd; mean(tr(:, 2))]';
        end
    end

    NE = reshape_struct(s, dd + 1, 'NE');

    % NW
    for dd = 1 : minmn - 1
        if dd == 1, s = struct('d', nan(maxmn - 1, numst + 1), 'r', nan(maxmn - 1, numst + 1)); end
        idx = and(diffi == dd, diffj == -dd);
        tmp = [dij(idx), rij(idx)];
        tr = tmp(~isnan(tmp(:, 2)), :);
        
        if meanFlag == 0
            s.d(dd, 1 : size(tr, 1) + 1) = [dd; tr(:, 1)]';
            s.r(dd, 1 : size(tr, 1) + 1) = [dd; tr(:, 2)]';
        else
            s.d(dd, 1 : 2) = [dd; mean(tr(:, 1))]';
            s.r(dd, 1 : 2) = [dd; mean(tr(:, 2))]';
        end
    end

    NW = reshape_struct(s, dd + 1, 'NW');
end

%% 子函数
function s = reshape_struct(s, n, mode)
    % 默认d=0时r=0
    d = reshape(s.d(:, 2 : end)', [], 1);
    r = reshape(s.r(:, 2 : end)', [], 1);
    idx = ~isnan(r);
    s = struct('d', [0; d(idx)], 'r', [0; r(idx)], 'n', n);
    if nargin == 3, prove_thrid_distance(s, mode, 0); end
end

function prove_thrid_distance(s, mode, plt)
    switch mode
        case 'EW'
            d = 1;
        case 'SN'
            d = 1;
        case 'NE'
            d = sqrt(2);
        case 'NW'
            d = sqrt(2);
    end

    d = (1 : 3)' * d;
    if nargin < 3, plt = 1; end

    if plt
        for i = 1 : 3
            idx = abs(s.d - d(i)) < 1e-10;
            r = s.r(idx);
            sr = sum(r);
            mr = mean(r) / 2;
            fprintf([mode, '-direction: %.2f\tsum(r): %d\tmean(r) :%.2f.\n'], d(i), sr, mr);
        end
    end
end
