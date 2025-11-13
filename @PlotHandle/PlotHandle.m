classdef PlotHandle < handle
    properties (Access = public)
        num
        screen
        size
        fig
        name
        fs
        fw
    end

    methods (Access = public)
        function obj = PlotHandle(s)
            arguments
                s.path      string {mustBeFolder} = ".\";
                s.name      string {mustBeNonzeroLengthText} = "";
                s.num       double {mustBeInteger} = 1;
                s.type      string {mustBeNonzeroLengthText} = ".png";
                s.size      char {mustBeText} = 'h';
                s.folder    char {mustBeText} = 'Latex\Fig\';
                s.fs        double {mustBeInteger} = 16;
                s.fw        char {mustBeNonzeroLengthText} = 'bold';
            end

            folder = fullfile(s.path, s.folder);
            if ~exist(folder, 'dir'), mkdir(folder); end
            obj.num = s.num;
            if obj.num > 1, idx = num2str((1 : obj.num)'); else, idx = ''; end
            obj.name = folder + s.name + idx + s.type;
            obj.fs = s.fs;
            obj.fw = s.fw;

            hdl = [];
            for i = 1 : s.num, hdl = [hdl; figure('Color', 'White', 'Visible', 'off')]; end
            obj.fig = hdl;

            sz = @(x) ([1, 9/16] .* x(3));
            obj.screen = sz(get(0, 'screensize'));

            switch s.size
                case 'h', obj.size = [obj.screen(1), obj.screen(1) / 16 * 9];  % 16:9
                case 'v', obj.size = [obj.screen(2), obj.screen(2) / 9 * 16];  % 9:16
                case 's', obj.size = [obj.screen(2) / 3 * 4, obj.screen(2)];   % 4:3
            end

            obj.resize();
        end
    end

    methods(Access = public)
        active(obj, n);
        export(obj, idx);
        set_label_font(obj, hdl, type, str);
        resize(obj, idx);
    end
end
