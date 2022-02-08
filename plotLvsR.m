function plotLvsR(D,cohort)

mArray = get_mice(cohort); 
maxTransitionCount = D(1).maxTransitionCount;

%Empty variable to hold sides
y1 = nan(numel(mArray),maxTransitionCount);
y2 = nan(numel(mArray),maxTransitionCount);
y3 = nan(numel(mArray),maxTransitionCount);
y4 = nan(numel(mArray),maxTransitionCount);
for m=1:numel(mArray)
    %Get data for this mouse
    idx = findStrInCell(mArray{m},{D.subject});
    if ~isempty(idx)
        %Concatenate transition data across multiple sessions
        y1(m,:) = nanmean(vertcat(D(idx).noStimTranRight),1);
        y2(m,:) = nanmean(vertcat(D(idx).StimTranRight));
        y3(m,:) = nanmean(vertcat(D(idx).noStimTranLeft));
        y4(m,:) = nanmean(vertcat(D(idx).StimTranLeft));              
    end
end     

figure('Position',[1000 1100 305 238]); hold on
%Plot averages for unstimulated data 
shadedErrorBar(1:1:maxTransitionCount,nanmean(1-y1,1),nanstd(y1,[],1)./sqrt(size(y1,1)),{'Color',[0 1 0],'LineWidth',4},.8); hold on
shadedErrorBar(1:1:maxTransitionCount,nanmean(y3,1),nanstd(y3,[],1)./sqrt(size(y3,1)),{'Color',[0 0 1],'LineWidth',4},.8)

%Set figure properties
xlabel('Trials from Switch')
ylabel({'Fraction Left Choice'})
title('Cohort Average')
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;


