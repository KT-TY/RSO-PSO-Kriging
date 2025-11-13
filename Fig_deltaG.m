startup;
glv = global_paramater_switch;
ifsave = 0;

%% 分类画图 90%
load deltaG.mat
load variogram_fitting_250324.mat
n = size(deltaG, 1) - 2;
nH = 133;
x = deltaG{n + 1};
y = deltaG{n + 2};
range = pso.beta(:, end);
range(1 : 6) = range([2, 1, 4, 3, 6, 5]);
deltaG(1 : 6) = deltaG([2, 1, 4, 3, 6, 5]);

% 直接出统计结果
resStruct = stistic_struct(x, y, deltaG(1 : n), [nH, 5 : 10]);
irect = find([resStruct.plt] > 0)';
iD = 1;
edgeColor = [0.1 0.1 0.3];
colorScheme = [0.2, 0.6, 1];

plt = PlotHandle('path', pwd, ...
    'name', 'delta_G_fit', ...
    'num', 5, ...
    'size', 's', ...
    'type', '.png', ...
    'fs', 14);
plt.screen(2) = 900;
plt.resize();

for i = 2 : 2 : n
    % 主图
    figure(plt.fig(i / 2));

    t = tiledlayout(1, 2, ...
        'TileSpacing', 'tight', ...
        'Padding', 'tight', ...
        'PositionConstraint', 'outerposition');

    % 子图1-全部等温图
    t1 = tiledlayout(t, 2, 1, ...
        'TileSpacing', 'compact', ...
        'Padding', 'tight');
    t1.Layout.Tile = 1;
    tl.PositionConstraint = 'outerposition';

    % 子图2-直方统计图区域
    t2 = tiledlayout(t, 2, 1, ...
        'TileSpacing', 'compact', ...
        'Padding', 'tight');
    t2.Layout.Tile = 2;
    t2.PositionConstraint = 'outerposition';

    for j = 1 : 2
        %%% 等温图
        ax1(j) = nexttile(t1);
        contourf(x, y, deltaG{i - 2 + j}, 20, 'LineColor', 'none', 'LineWidth', 1.5);
        colormap('hot');
        hc = colorbar;
        hc.Location = 'eastoutside';
        hc.Label.String = '\delta(mGal)';
        hc.FontSize = plt.fs - 2;
        hc.FontWeight = plt.fw;
        hc.Label.FontWeight = 'normal';
        axis equal;
        ikk = i - 2 + j;
        title(sprintf('range: %.2f, MAE: %.2e', range(ikk), resStruct(ikk * 6).mae), 'FontSize', plt.fs - 2, 'FontWeight', plt.fw);
        hold on;

        % 插入矩形
        rectangle('Position', resStruct(irect(iD)).rectangle, ...
            'EdgeColor', 'b', ...
            'LineWidth', 1.5, ...
            'LineStyle', '--', ...
            'Curvature', [0, 0]);

        % 插入文本
        text(resStruct(irect(iD)).textX, resStruct(irect(iD)).textY, '90%', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontSize', plt.fs - 2, ...
            'Color', 'b', ...
            'FontWeight', 'bold');

        hold off;

        %%% 直方图
        ax2(j) = nexttile(t2);

        bar(resStruct(irect(iD)).binCenters, resStruct(irect(iD)).count, 1, ... % 1 表示柱子宽度比例
            'FaceColor', colorScheme, ...
            'EdgeColor', edgeColor, ...
            'LineWidth', 1.5);

        % 样式优化
        ax = gca;
        ax.XLim = [resStruct(irect(iD)).binEdges(1), resStruct(irect(iD)).binEdges(end)]; % X轴范围
        ax.YGrid = 'on'; % 开启Y轴网格
        ax.GridLineStyle = '--';
        ax.GridAlpha = 0.3;

        % 添加参考线
        hold on
        leg1 = plot([resStruct(irect(iD)).mean, resStruct(irect(iD)).mean], ylim, '--r', 'LineWidth', 1.5); % 均值线
        yLimits = ylim;
        kdowm = 0.06;
        yPos = yLimits(1) - kdowm * (yLimits(2) - yLimits(1));

        text(resStruct(irect(iD)).mean, yPos, '\mu', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'top', ...
            'Interpreter', 'tex', ...
            'FontSize', plt.fs - 2, ...
            'FontWeight', plt.fw);

        hold on
        plot([resStruct(irect(iD)).mean - resStruct(irect(iD)).std, resStruct(irect(iD)).mean - resStruct(irect(iD)).std], ...
            ylim, ':r', ...
            'LineWidth', 1.5); % -1σ
        yLimits = ylim;
        yPos = yLimits(1) - kdowm * (yLimits(2) - yLimits(1));

        text(resStruct(irect(iD)).mean - resStruct(irect(iD)).std, yPos, '-\sigma', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'top', ...
            'Interpreter', 'tex', ...
            'FontSize', plt.fs - 2, ...
            'FontWeight', plt.fw);

        hold on
        leg2 = plot([resStruct(irect(iD)).mean + resStruct(irect(iD)).std, resStruct(irect(iD)).mean + resStruct(irect(iD)).std], ...
            ylim, ':r', ...
            'LineWidth', 1.5); % +1σ
        yLimits = ylim;
        yPos = yLimits(1) - kdowm * (yLimits(2) - yLimits(1));

        text(resStruct(irect(iD)).mean + resStruct(irect(iD)).std, yPos, '+\sigma', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'top', ...
            'Interpreter', 'tex', ...
            'FontSize', plt.fs - 2, ...
            'FontWeight', plt.fw);

        s1 = sprintf('\\mu = %.2e', resStruct(irect(iD)).mean);
        s2 = sprintf('\\sigma = %.2e', resStruct(irect(iD)).std);
        legend([leg1, leg2], s1, s2, 'Location', 'northeast', 'box', 'off', 'FontSize', plt.fs - 2, 'FontWeight', plt.fw);
        hold off;
        iD = iD + 1;
    end

    plt.set_label_font(ax1, 'a');
    plt.set_label_font(t1, 'x', '\it\lambda\rm(\circ)');
    plt.set_label_font(t1, 'y', '\itL\rm(\circ)');
    plt.set_label_font(t2, 't', 'error distribution: 90% of region');
    plt.set_label_font(ax2, 'a');
    plt.set_label_font(t2, 'x', '\delta(mGal)');
    plt.set_label_font(t2, 'y', 'Counts');
end

if ifsave == 1, plt.export(); end

%% excel
clearvars -except glv resStruct range err plt
m = size(resStruct, 1);
n = size(range, 1);
k = 2;
[exMean, exStd, exMax, exMin, exMae] = deal(zeros(n, m / n));
fullMat = deal(zeros(n * k, m / n));

for i = 1 : n
    ii = (i - 1) * n + 1 : i * n;
    exMean(i, :) = cell2mat({resStruct(ii).mean});
    exStd(i, :) = cell2mat({resStruct(ii).std});
    exMin(i, :) = cell2mat({resStruct(ii).min});
    exMax(i, :) = cell2mat({resStruct(ii).max});
    exMae(i, :) = cell2mat({resStruct(ii).mae});
end

fullMat(1 : n * k / 2, :) = exMean;
fullMat(n * k / 2 + 1 : n * k, :) = exStd;

%% 评估百分比统计
plt.active(4);
part = (5 : 10)';
semilogy(part, exMae([1, 3, 5, 2, 4, 6], :)', 'LineWidth', 1.5); hold on;
semilogy(part, 0.4 * ones(6, 1), 'LineWidth', 1.5, 'LineStyle', '-.'); hold off;
grid on;
ax = gca;
xticks(ax, part);
xticklabels(ax, {'50%', '60%', '70%', '80%', '90%', '100%'});
plt.set_label_font(ax, 'x', 'part of region');
plt.set_label_font(ax, 'y', '\delta(mGal)');
plt.set_label_font(ax, 'a');
legend('PSO-AS', 'PSO-MS', 'PSO-RS', 'DCG', 'HMLD', 'MLD', 'Threshold', ...
    'Location', 'northwest', ...
    'box', 'off', ...
    'NumColumns', 3, ...
    'FontSize', plt.fs, ...
    'FontWeight', plt.fw);

%% 性能提升百分比
ratio = [(exMae(5, :) ./ exMae(4, :))', ... % hmld
    (exMae(5, :) ./ exMae(6, :))', ...      % mld
    (exMae(5, :) ./ exMae(1, :))', ...      % psoAS
    (exMae(5, :) ./ exMae(3, :))']; % psoMS

plt.active(5);
colors = lines(4);
ax = bar(part, ratio);

for i = 1 : 4
    ax(i).FaceColor = colors(i, :);
    x = ax(i).XEndPoints;
    y = ax(i).YEndPoints;

    for j = 1 : 6
        text(x(j), y(j), sprintf('%d%%', round(y(j) * 100)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontSize', plt.fs - 4, ...
            'FontWeight', plt.fw);
    end
end

hold off;
ax = gca;
xticks(ax, part);
xticklabels(ax, {'50%', '60%', '70%', '80%', '90%', '100%'});
ylim([0.1, 1.1])
yticks(ax, 0.1 : 0.2 : 1.1);
yticklabels(ax, {'10%', '30%', '50%', '70%', '90%', '110%'});
plt.set_label_font(ax, 'x', 'part of region');
plt.set_label_font(ax, 'y', 'performance ratio');
plt.set_label_font(ax, 'a');
legend('HMLD', 'MLD', 'PSO-AS', 'PSO-MS', ...
    'Location', 'northeast', ...
    'box', 'off', ...
    'FontSize', plt.fs - 4, ...
    'FontWeight', plt.fw);

%% subfunction
function res = stistic_struct(x, y, z, idx)
    n = size(z, 1);
    nH = idx(1);
    per10 = fix(nH * 0.05);
    ratio = idx(2 : end);
    iidx = 1;
    numBins = 11;

    res = struct('plt', 0, ...
        'count', NaN(1, numBins - 1), ...
        'min', 0, ...
        'max', 0, ...
        'mean', 0, ...
        'std', 0, ...
        'rectangle', NaN(1, 4), ...
        'binEdges', NaN(1, numBins), ...
        'binCenters', NaN(1, numBins - 1), ...
        'textX', NaN, ...
        'textY', NaN);
    res = repmat(res, 6 * n, 1);

    for i = 1 : n
        for j = 1 : length(ratio)
            seq = per10 * (10 - ratio(j)) + 1 : nH - per10 * (10 - ratio(j));
            xx = x(seq, seq);
            yy = y(seq, seq);
            zz = z{i}(seq, seq);
            zz = zz(:);

            res(iidx).min = min(zz);
            res(iidx).max = max(zz);
            res(iidx).mean = mean(zz);
            res(iidx).std = std(zz);
            res(iidx).mae = mean(abs(zz));

            if ratio(j) == 9
                res(iidx).plt = 1;
                res(iidx).rectangle = [xx(1), yy(1), xx(end) - xx(1), yy(end) - yy(1)];
                res(iidx).binEdges = linspace(res(iidx).min, res(iidx).max, numBins);
                res(iidx).binCenters = (res(iidx).binEdges(1 : end - 1) + res(iidx).binEdges(2 : end)) / 2;
                res(iidx).count = histcounts(zz, res(iidx).binEdges);

                res(iidx).textX = res(iidx).rectangle(1) + res(iidx).rectangle(3) / 2;
                res(iidx).textY = res(iidx).rectangle(2) + res(iidx).rectangle(4) - 0.1;
            end

            iidx = iidx + 1;
        end
    end
end
