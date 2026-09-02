function make_report(inputCsv, outputPdf)
%MAKE_REPORT Stub report: strain channels and load against time, one PDF.
%   make_report(inputCsv, outputPdf) reads a CSV with a header row, plots every
%   ch##_ue column against time_s in the upper panel and load_kN in the lower
%   panel, and prints the figure to outputPdf. Stands in for the real function.

    T = readtable(inputCsv);
    names = T.Properties.VariableNames;
    isChan = ~cellfun('isempty', regexp(names, '^ch\d+_ue$', 'once'));
    chan = names(isChan);
    if isempty(chan)
        error('make_report:noChannels', 'No ch##_ue columns in %s', inputCsv);
    end
    if ~any(strcmp(names, 'time_s'))
        error('make_report:noTime', 'No time_s column in %s', inputCsv);
    end
    t = T.time_s;

    fig = figure('Visible', 'off', 'PaperOrientation', 'landscape', ...
        'PaperUnits', 'inches', 'PaperPosition', [0.5 0.5 10 7.5]);
    [~, stem, ~] = fileparts(inputCsv);

    subplot(2, 1, 1);
    hold on;
    for k = 1:numel(chan)
        plot(t, T.(chan{k}), 'DisplayName', chan{k});
    end
    hold off;
    grid on;
    xlabel('time (s)');
    ylabel('microstrain');
    title(sprintf('%s: strain channels', stem), 'Interpreter', 'none');
    legend('show', 'Location', 'best');

    subplot(2, 1, 2);
    if any(strcmp(names, 'load_kN'))
        plot(t, T.load_kN, 'k');
        ylabel('load (kN)');
    else
        text(0.5, 0.5, 'no load_kN column', 'HorizontalAlignment', 'center');
    end
    grid on;
    xlabel('time (s)');
    title('load', 'Interpreter', 'none');

    print(fig, '-dpdf', outputPdf);
    close(fig);
end
