startup;
glv = global_paramater_switch;
ifsave = 0;
load gridRow.mat
X = gridRow(:, :, 2) / glv.deg;
Y = gridRow(:, :, 1) / glv.deg;
Z = -diff(gridRow(:, :, 6 : 7), 1, 3) / glv.mGal;

%%
plt = PlotHandle('path', pwd, ...
    'name', 'simu_region', ...
    'num', 1, ...
    'size', 's', ...
    'type', '.png', ...
    'fs', 14);

figure(plt.fig);
contourf(X, Y, Z, 20, 'LineColor', 'none', 'LineWidth', 1.5); % 20条等高线，无轮廓线
colormap('hot');
hc = colorbar;
hc.Location = 'eastoutside';
hc.Label.String = '\delta\itg\rm(mGal)';
hc.FontSize = plt.fs - 2;
hc.FontWeight = plt.fw;
hc.Label.FontWeight = 'normal';
axis equal;
ax = gca;
plt.set_label_font(ax, 'a');
plt.set_label_font(ax, 'x', '\it\lambda\rm(\circ)');
plt.set_label_font(ax, 'y', '\itL\rm(\circ)');
