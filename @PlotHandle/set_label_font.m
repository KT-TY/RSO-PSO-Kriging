function set_label_font(obj, hdl, type, str)
    switch type
        case 'a'
            for i = 1 : length(hdl)
                [hdl(i).XAxis.FontSize] = deal(obj.fs);
                [hdl(i).XAxis.FontWeight] = deal(obj.fw);
                [hdl(i).YAxis.FontSize] = deal(obj.fs);
                [hdl(i).YAxis.FontWeight] = deal(obj.fw);
                [hdl(i).ZAxis.FontSize] = deal(obj.fs);
                [hdl(i).ZAxis.FontWeight] = deal(obj.fw);
            end
        case {'x', 'X'}
            hdl.XLabel.String = str;
            hdl.XLabel.FontSize = obj.fs;
            hdl.XLabel.FontWeight = 'normal';
        case {'y', 'Y'}
            hdl.YLabel.String = str;
            hdl.YLabel.FontSize = obj.fs;
            hdl.YLabel.FontWeight = 'normal';
        case {'z', 'Z'}
            hdl.ZLabel.String = str;
            hdl.ZLabel.FontSize = obj.fs;
            hdl.ZLabel.FontWeight = 'normal';
        case {'t', 'T'}
            hdl.Title.Interpreter = 'tex';
            hdl.Title.String = str;
            hdl.Title.FontSize = obj.fs;
            hdl.Title.FontWeight = obj.fw;
        case {'l', 'L'}
            hdl.FontSize = obj.fs;
            hdl.FontWeight = obj.fw;
    end
end