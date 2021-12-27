function [STIM, NOSTIM] = plotBehaviorAve(D,cohort)

figure('Position',[320 645 1121 160])

mArray = get_mice(cohort);
maxTransitionCount = D(1).maxTransitionCount;

%Setup Figure colors, according to cohort
    if strcmp(cohort, 'Int-MHb4-NpHR')
        colorAlpha = 'y';
    elseif strcmp(cohort, 'Int-MHb4-ChR2')
        colorAlpha = 'b';
    else
        colorAlpha = 'b';
    end

%Make empty variables
NOSTIM = nan(numel(mArray),maxTransitionCount);
STIM = nan(numel(mArray),maxTransitionCount);
cumNOSTIM = nan(numel(mArray),maxTransitionCount);
cumSTIM = nan(numel(mArray),maxTransitionCount);
for i=1:numel(mArray)
    subplot(1,numel(mArray),i)
    %Get data for this mouse
    idx = findStrInCell(mArray{i},{D.subject});
    if ~isempty(idx)       
        %Concatenate transition data across multiple sessions
        y1 =vertcat(D(idx).nostimTransitions);
        y2 =vertcat(D(idx).stimTransitions);

        %Plot averages for each animal
        shadedErrorBar(1:1:15,nanmean(y1,1),nanstd(y1,[],1)./sqrt(size(y1,1)),{'Color','k','LineWidth',4},.8)
        hold on
        shadedErrorBar(1:1:15,nanmean(y2,1),nanstd(y2,[],1)./sqrt(size(y2,1)),{'Color',colorAlpha,'LineWidth',4},.8)
        xlabel('Trials from Switch')
        ylabel({'Fraction on'; 'High pReward Port'})
        title(['Ave ' mArray{i}] )
        uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;
        
        %stash data for cohort  mean
        NOSTIM(i,:) = nanmean(y1,1);
        STIM(i,:) = nanmean(y2,1);   
        cumNOSTIM(i,:) = nanmean(cumsum(y1,2),1);
        cumSTIM(i,:) = nanmean(cumsum(y2,2),1); 
    end
end

%Figure Settings
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;
xlabel('Trials from Switch')
ylabel({'Fraction on'; 'High pReward Port'})
title('Cohort Average')

%Save out individual figure for illustrator
figure('Position',[1000 1100 305 238]); hold on
%mean
subplot(1,2,1)
hold on
shadedErrorBar(1:1:maxTransitionCount,nanmean(NOSTIM,1),nanstd(NOSTIM,[],1)./sqrt(numel(mArray)),{'Color','k','LineWidth',4},.8)
shadedErrorBar(1:1:maxTransitionCount,nanmean(STIM,1),nanstd(STIM,[],1)./sqrt(numel(mArray)),{'Color',colorAlpha,'LineWidth',4},.8)
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;
xlabel('Trials from Switch')
ylabel({'Fraction on'; 'High pReward Port'})
title('Cohort Average')
%Cumulative Sum
subplot(1,2,2)
hold on
shadedErrorBar(1:1:maxTransitionCount,nanmean(cumNOSTIM,1),nanstd(cumNOSTIM,[],1)./sqrt(numel(mArray)),{'Color','k','LineWidth',4},.8)
shadedErrorBar(1:1:maxTransitionCount,nanmean(cumSTIM,1),nanstd(cumSTIM,[],1)./sqrt(numel(mArray)),{'Color',colorAlpha,'LineWidth',4},.8)
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;
xlabel('Trials from Switch')
ylabel({'Fraction on'; 'High pReward Port'})
title('Cohort Average')
gcf;


