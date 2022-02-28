function  uniformFigureProps()
%%%Make all figures uniform in size, text, and tick properties.  


set(gcf,'DefaultAxesFontSize',7)
%set figure size and text size
%set(gcf, 'Position',  [378 806 360 307])
set(gca, 'FontSize',7)
set(gcf, 'PaperUnits', 'centimeters', 'Units', 'centimeters');
%Change box and ticks
box off
ax = gca;
ax.TickLength = [0.01 0.01];
ax.TickDir = 'out';
box off
ax.LineWidth = .75;
ax.XRuler.TickLabelGapOffset = -2;
ax.YRuler.TickLabelGapOffset = -1;


end
