function resize(obj, idx)
    if nargin < 2, idx = 1 : obj.num; end
    sz = [0.01 * obj.screen(1), 0.05 * obj.screen(2), 0.95 * obj.size];

    for i = idx
        set(obj.fig(i), 'OuterPosition', sz);
        set(obj.fig(i), 'visible', 'on');
    end
end