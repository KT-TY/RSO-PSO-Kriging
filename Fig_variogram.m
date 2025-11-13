startup;
glv = global_paramater_switch;

load variogram_fitting_250324.mat
ifsave = 0;
nFig = 4;
plt = PlotHandle('path', pwd, ...
    'name', 'variogram', ...
    'num', nFig, ...
    'size', 's', ...
    'type', '.png');
plt.size(2) = plt.size(1) / 2;

texTitle = ["adjacent sector"; "mediate sector"; "remote sector"];
texLegend = ["DCG"; "HMLD"; "MLD"];
xm = pso.beta(end);
region = [0.1, 0.4, 0.7, 1] * xm;
fcu = @normlized;

for i = 2 : 2 : 2 * (nFig - 1)
    resPso = fcu(pso, i - 1);   % pso-rso
    resCal = fcu(pso, i);       % calculated

    plt.resize(i / 2);
    plt.active(i / 2);

    t = tiledlayout(1, 2, ...
        'TileSpacing', 'compact', ...
        'Padding', 'tight', ...
        'PositionConstraint', 'outerposition');

    ax = nexttile(t);
    plot(ax, resCal.xpre, [resCal.ypre; resCal.yref], 'LineWidth', 1.5);
    title(resCal.r, 'FontSize', plt.fs - 2, 'FontWeight', plt.fw);
    legend(texLegend(i / 2), 'referance', 'Location', 'northwest', 'FontSize', plt.fs - 2, 'FontWeight', plt.fw, 'Box', 'off');
    plt.set_label_font(ax, 'a')
    grid on;

    ax = nexttile(t);
    plot(ax, resPso.xpre, [resPso.ypre; resPso.yref], 'LineWidth', 1.5);
    title(resPso.r, 'FontSize', plt.fs - 2, 'FontWeight', plt.fw);
    legend('RSO-PSO', 'referance', 'Location', 'northwest', 'FontSize', plt.fs - 2, 'FontWeight', plt.fw, 'Box', 'off');
    plt.set_label_font(ax, 'a')
    grid on;

    plt.set_label_font(t, 'x', '\itd\rm(nm)');
    plt.set_label_font(t, 'y', '\it\gamma\rm(\itd\rm)(mGal^2)');
    % plt.set_label_font(t, 't', "variogram fitting: " + texTitle(i / 2));
end

plt.active(4);
ax = axes;
transparent = 0.2;
plot(ax, resCal.xpre, [resCal.ypre; resCal.yref], 'LineWidth', 1.5);
hold on;
grid on;

% 加竖线
stem(region, [1, 1, 1, 1], 'LineStyle', '-.', 'Marker', 'none', 'LineWidth', 1.5);

% 加图例
legend('Gaussian', 'referance', ...
    'Location', 'northwest', ...
    'FontSize', plt.fs - 2, ...
    'FontWeight', plt.fw);

% 区域颜色填充
xr = xregion(region(1 : 3), region(2 : 4));
xr(1).FaceColor = [0.18, 0.52, 0.28];   % 橄榄绿
xr(1).FaceAlpha = transparent;
xr(1).DisplayName = texTitle(1);
xr(2).FaceColor = [0.93, 0.51, 0.12];   % 陶土橙
xr(2).FaceAlpha = transparent;
xr(2).DisplayName = texTitle(2);
xr(3).FaceColor = [0.07, 0.34, 0.62];   % 深海蓝
xr(3).FaceAlpha = transparent;
xr(3).DisplayName = texTitle(3);

% 加突出点
ii = find(resCal.xpre > 60, 1);
xii = resCal.xpre(ii);
yii = resCal.yref(ii);
plot(xii, yii, 'p', ...
    'DisplayName', 'ideal range', ...
    'MarkerSize', plt.fs - 2, ...   % 大小
    'MarkerFaceColor', 'red', ...   % 填充颜色
    'MarkerEdgeColor', 'red');      % 边框颜色
hold on;

text(xii + 4, yii - 0.02, sprintf('%.2f', xii), ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', plt.fs - 2, ...
    'Color', 'k', ...
    'FontWeight', 'bold');
hold off

plt.set_label_font(ax, 'a');
plt.set_label_font(ax, 'x', '\itd\rm(nm)');
xlim([0, 86])
plt.set_label_font(ax, 'y', '\it\gamma\rm(\itd\rm)(mGal^2)');
plt.set_label_font(ax, 't', '');
if ifsave == 1, plt.export(); end

%% subfunction
function s = normlized(pso, idx)
    xPsoPred = pso.x(idx, :);
    yPsoRefe = pso.y(idx, :);
    yPsoPred = pso.model(pso.beta(idx, 1 : 3), xPsoPred);
    ft = pso.lost(yPsoPred, yPsoRefe);

    s.xpre = xPsoPred;
    s.ypre = yPsoPred;
    s.yref = yPsoRefe;
    s.ft = ft;
    s.r = sprintf('range: %.2f, fitness: %.2f', pso.beta(idx, end), s.ft);
end
