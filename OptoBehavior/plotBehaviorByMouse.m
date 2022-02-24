function [stim, nostim] = plotBehaviorByMouse(D,cohort)

figure('Position',[3131 405 1220 847])

%Variables to hold mean for each animal
mArray = get_mice(cohort);
nMice = numel(mArray);
maxTransitionCount = D(1).maxTransitionCount;
stim = nan(10,maxTransitionCount,nMice);
nostim = nan(10,maxTransitionCount,nMice);

if strcmp(cohort, 'Int-MHb4-NpHR')
    colorAlpha = 'y';
elseif strcmp(cohort, 'Int-MHb4-ChR2')
    colorAlpha = 'b';
else
    colorAlpha = 'b';
end

for m=1:nMice
    idxFiles = findStrInCell(mArray{m},{D.subject});
    stimData = nan(numel(idxFiles),maxTransitionCount);
    nostimData = nan(numel(idxFiles),maxTransitionCount);
    
    %Get max number of session for an animal
    nDays = max(histcounts(categorical({D.subject}),(mArray)));
    
    if ~isempty(idxFiles)
        for f=1:numel(idxFiles)
            idx = idxFiles(f);
            
            %Get stim and no stim dta
            stimData(f,:) = nanmean( D(idx).stimTransitions,1);
            nStim = size(D(idx).stimTransitions,1);
            nostimData(f,:) = nanmean(D(idx).nostimTransitions,1);
            nNoStim = size(D(idx).nostimTransitions,1);
            
            %Plot the data for this mouse and day
            subplot(nDays,nMice,((f-1)*nMice)+m)
            plot(nostimData(f,:),'k','LineWidth',4); hold on
            plot(stimData(f,:),colorAlpha,'LineWidth',4)            
            text(7,.2,{ ['n = ' num2str(nStim) ' stim'] ; ['n = ' num2str(nNoStim) ' no stim'] })
            uniformFigureProps(); ylim([0 1 ])
            title({['Ave ' mArray{m}] ; D(idx).date})
            ax = gca;
            ax.TitleFontSizeMultiplier =.7;
            stim(f,:,m) = stimData(f,:);
            nostim(f,:,m) = nostimData(f,:);
        end  
             
        %Figure Settings
        uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;
        xlabel('Trials from Switch')
        ylabel({'Fraction on'; 'High pReward Port'})
        title({['Ave ' mArray{m}] ; D(idx).date})
       
    end
end