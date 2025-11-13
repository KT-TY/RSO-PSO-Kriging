%%
startup;
glv = global_paramater_switch;
ifsave = 0;
load gridRow.mat
load gridKrg.mat

%%
fcu1 = @preprocess_psodata;
fcu2 = @anisotropic_analysis;

nL = size(gridRow(:, :, 1), 1);
nH = size(gridKrg(:, :, 1), 1);
lat1 = reshape(gridRow(:, :, 1), nL, nL);
lat2 = reshape(gridKrg(:, :, 1), nH, nH);
lon1 = reshape(gridRow(:, :, 2), nL, nL);
lon2 = reshape(gridKrg(:, :, 2), nH, nH);
gaij = -diff(gridRow(:, :, 6 : 7), 1, 3) / glv.mGal;

kd = glv.Re / glv.nm;
meanFlag = 1;
[EW, SN, NE, NW] = sort_fourdirect(lon1, lat1, gaij, kd, meanFlag);

betaEW = fcu1(meanFlag, EW);
betaSN = fcu1(meanFlag, SN);
betaNE = fcu1(meanFlag, NE);
betaNW = fcu1(meanFlag, NW);

%%%%%%%%%%%%
% 各向异性绘图
[ytEW, ypEW, paEW] = fcu2(betaEW);
[ytSN, ypSN, paSN] = fcu2(betaSN);
[ytNE, ypNE, paNE] = fcu2(betaNE);
[ytNW, ypNW, paNW] = fcu2(betaNW);

%%
plt = PlotHandle('path', pwd, ...
    'name', 'anisotropy', ...
    'size', 's', ...
    'type', '.png');

plt.active();

t = tiledlayout(2, 2, ...
        'TileSpacing', 'compact', ...
        'Padding', 'tight', ...
        'PositionConstraint', 'outerposition');

ax(1) = nexttile(t);
h = plot(betaEW.x, ytEW, betaEW.x, ypEW, ':o', 'LineWidth', 1.5); grid on;
title(sprintf('EW-sill: %d, err: %.2e', paEW.sill, paEW.fit), 'FontSize', plt.fs, 'FontWeight', plt.fw);

ax(2) = nexttile(t);
plot(betaSN.x, ytSN, betaSN.x, ypSN, ':o', 'LineWidth', 1.5); grid on;
title(sprintf('SN-sill: %d, err: %.2e', paSN.sill, paSN.fit), 'FontSize', plt.fs, 'FontWeight', plt.fw);

ax(3) = nexttile(t);
plot(betaNE.x, ytNE, betaNE.x, ypNE, ':o', 'LineWidth', 1.5); grid on;
title(sprintf('NE-sill: %d, err: %.2e', paNE.sill, paNE.fit), 'FontSize', plt.fs, 'FontWeight', plt.fw);

ax(4) = nexttile(t);
plot(betaNW.x, ytNW, betaNW.x, ypNW, ':o', 'LineWidth', 1.5); grid on;
title(sprintf('NW-sill: %d, err: %.2e', paNW.sill, paNW.fit), 'FontSize', plt.fs, 'FontWeight', plt.fw);

plt.set_label_font(ax, 'a');
plt.set_label_font(t, 'x', '\itd\rm(nm)');
plt.set_label_font(t, 'y', '\gamma\rm(\itd\rm)(mGal^2)');
lgd = legend(h, {'true', 'pred'}, 'Orientation', 'horizontal', 'Box', 'off');
lgd.Layout.Tile = 'south';
lgd.FontSize = plt.fs;
lgd.FontWeight = plt.fw;

if ifsave == 1, plt.export(); end

%% subfunction
function [beta, dBar, rBar] = preprocess_psodata(meanFlag, s)
    if meanFlag == 1
        numDis = max(s.d) / 2;
        idx = s.d < numDis;
        dBar = s.d(idx);
        rBar = s.r(idx);
    else
        numDis = fix(s.n / 2);
        [dBar, rBar] = variogram_dataset(s.d, s.r, numDis);
    end

    beta = pso_variogram_process('dBar', dBar, 'rBar', rBar, 'plt', 0);
end

function [yt, yp, para] = anisotropic_analysis(beta)
    yt = reshape(beta.y, 1, []);
    yp = reshape(beta.fun(beta.beta, beta.x), 1, []);

    para.sill = round(beta.beta(1));
    para.fit = sqrt(mean((yp - yt) .^ 2));
end
