cd '~/Dropbox/MHb Figure Drafts/Data/'

%% Make FP Plots aligned to Syncs -  Left Panels F,G,H

%Get Plot Params
cohorts = {'Th','Tac','chat','calb','LHbCombo'};
outcomes = [1 2 3 4];
syncname = {'Reward'};
time_Win = 7;
sr=1017/50;
t = linspace(-time_Win,time_Win, (2*sr*time_Win));   
colors = mhbColors(2);
protocol = '6'; %Stage 6 after training
dataUnits = 'Zscore';
n = floor(time_Win*sr*2);
rewardWindow = round((time_Win)*sr:(time_Win+4)*sr);
nRewards = 40;

for c=1:numel(cohorts)
    
    %Set window for analysis (for Th, look at 
    if strcmp(cohorts{c},'Th')
        rewardWindow = round((time_Win-1)*sr:(time_Win)*sr);
    else
        rewardWindow = round((time_Win)*sr:(time_Win+4)*sr);
    end
    
    %Load cohort data
    load([pwd '/datafiles/FP/StandardTask/' cohorts{c} protocol '.mat'],'T')
    mArray = unique({T.subject});
    
    %% Analyze Data
    %set up empty variable for heatmap and barplot
    m_barplotdata = nan(200,numel(mArray));
    m_heatmap = nan(200,floor(time_Win*sr*2),numel(mArray));
    
    %Loop through Mice and average across all sessions per mouse
    for m=1:numel(mArray)
        idxMouse = findStrInCell(mArray{m},{T.subject});
        
        %Get mean across all animals for heatplot
        heatmapdata = nan(200,floor(time_Win*sr*2),numel(idxMouse));
        barplotdata = nan(200,numel(idxMouse));
        
        %Loop across all sessions run on this animal
        for s=1:numel(idxMouse)
            %Filter reward syncs by correct trials
            correct = find(T(idxMouse(s)).outcome==1);
            rewards  = T(idxMouse(s)).Reward(correct,:);
            
            %Get mean across all animals for heatplot
            heatmapdata(1:numel(correct),:,s) = rewards;
            
            %Get mean of reward widown for bar plot across trials in a session
            barplotdata(1:numel(correct),s) = nanmean(rewards(:,rewardWindow),2);
        end 
        
        %Add mean of this animal to cohort array
        m_barplotdata(:,m) = nanmean(barplotdata,2);
        m_heatmap(:,:,m) = nanmean(heatmapdata,3);
    end
    
    
    
    %% Make a heatplot of trials
    %Get mean across all animals in this cohort
    cohortMean = nanmean(m_heatmap(1:nRewards,:,:),3);
    xlim1 = -2
    xlim2 = 6
    timeWin2Plot = round((time_Win+ xlim1)*sr:(time_Win+xlim2)*sr);
    cohortMean = cohortMean(:,timeWin2Plot)
    
    %Generate Figure
    h = figure('PaperUnits', 'centimeters', 'Units', 'centimeters','Position',[0 0 3.4 2.8],'PaperSize',[6 6])
    %uniformFigureProps();
    imagesc(cohortMean);
    xline(2*sr,':w','LineWidth',.5)

    
    %Set colormap
    colormap inferno
    cb = colorbar; set(cb,'position',[.92 .65 .03 .25]); set(cb,'YTick',[-1 3])
    caxis([-1 3])


    %Set Axes
    xticks(0:2*sr:sr*(xlim2-xlim1))
    xticklabels({'-2','0','2','4','6'})
    xlim([0 sr*(xlim2-xlim1)])
    xlabel('Time from reward (s)')
    ylabel('n^{th} Correct Trial')
    
    t = text(170,38,'Z Score','FontSize',7)
    set(t,'Rotation',90)
    caxis([-1 3])

    %Add metadata to figure for paper legends
         text( 160,-1, ['n = ' num2str(numel(unique(mice))) ' mice'],'FontSize',4,'Color',[1 1 1 ]);
         text( 160,-2, ['n = ' num2str(sum(cell2mat({T.ntrials}))) ' trials'],'FontSize',4,'Color',[1 1 1 ]);
         text( 160,-3, ['From ' num2str(min(nSessions))...
             ' to ' num2str(max(nSessions)) ' sessions'],'FontSize',4,'Color',[1 1 1]);   
    %Save out plot
    uniformFigureProps();
    saveas(gcf, [pwd '/Figure 4/panels/' cohorts{c} '_nthCorrect_heatmap.pdf']) 

    %% Make a bar figure
    
    %Get mean across all animals in this cohort
    cohortMean = nanmean(m_barplotdata(1:nRewards,:),2);
    cohortStd = nanstd(m_barplotdata(1:nRewards,:),[],2);
    
    h = figure('PaperUnits', 'centimeters', 'Units', 'centimeters','Position',[0 0 3.2 2.8],'PaperSize',[6 6])
    colors = rewLightColors(1)
    hold on
    b=bar(cohortMean,'FaceColor',colors(2,:));
    e=errorbar(cohortMean,cohortStd./sqrt(size(m_mousedata,2)),'.k');
    
    %Conform to reward contingency color scheme
    e.LineStyle = 'none';
    e.Color = colors(2,:);
    e.LineWidth = .5;
    b.EdgeColor = 'none';
    e.CapSize = 2;
    e.Marker = 'none';
    %Adjust Limits for different cohorts
    xlim([0 40])
    yl =  ylim;
    if yl(1) <0
        ylim([-ceil(abs(yl(1))) ceil(abs(yl(2)))])
    else
        ylim([0 ceil(abs(yl(2)))])
    end
    yl = ylim;
    yticks( yl(1):1:yl(2));
    

    %Make axis format to style of figure
    ylabel('Z Score')
    xlabel('n^{th} Correct Trial')
    xticks(0:20:40)
    uniformFigureProps() 

    %Save out plot
    saveas(gcf, [pwd '/Figure 4/panels/' cohorts{c} '_nthCorrect_barplot.pdf']) 

end