function export(obj, idx)
    % n = max(idx);
    % if n > obj.num, error('Error Figure Handle.'); end
    % exportgraphics(obj.fig(idx), obj.name(idx), 'ContentType', 'auto', 'BackgroundColor', 'white', 'Resolution', 600);
    if nargin < 2, idx = 1 : obj.num; end
    imin = min(idx);
    imax = max(idx);
    if or(imin > obj.num, imax > obj.num), error('Error Figure Handle.'); end
    for i = idx, exportgraphics(obj.fig(i), obj.name(i), 'ContentType', 'auto', 'BackgroundColor', 'white', 'Resolution', 600); end
end