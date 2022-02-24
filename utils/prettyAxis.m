function ax = prettyAxis()
set(gca, 'FontName', 'Helvetica')
set(gca, 'FontSize', 18)

    ax = gca;
    ax.LineWidth = 1.5;
    ax.TickLength = [0.02 0.02];
    ax.TickDir = 'out';
    box off
    ax.LineWidth = 2;
end
