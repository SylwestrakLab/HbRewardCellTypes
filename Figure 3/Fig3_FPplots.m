
%% Make FP Plots aligned to Syncs -  Left Panels C, D, E, F, G
%This script plots 
%1. The FP time series around the rewardy port entry,
%sparated by reward contingency (no reward, no reward light, or neither)

%2. The summary statistics for each time series, quantified as chagne in
%zscore before and after the reward port entry, plotted as a bar graph with 
%individual animals overlayed, and exports summary
%data to .csv file for statistical analysis.  



cd '~/Dropbox/MHb Figure Drafts/Data/'

%Get Plot Params
dataLabels = {'Correct','Incorrect','Omitted','Premature'};
cohorts = {'Th','Tac','chat','calb','LHbCombo'};
%cohorts = {'Th','Tac','chat','calb'};
o=1;
rewards = [0 1 2 3];
syncname = {'Start'; 'Cue'; 'Poke'; 'Reward';'HeadIn'};
time_Win = 7;
sr=1017/50;
t = linspace(-time_Win,time_Win, (2*sr*time_Win));   
colors = rewLightColors(1);
save_figure = 1;
protocol = 'RewLight'; %Stage 6 after training
DataOutputFolder = 'FP_3CSRTT';
dataUnits = 'Zscore';
fpstats=cell(numel(cohorts),1,4);
ymin = [-1 -2 -2 -2 -2];
ymax = [3 6 2 2 4 ];

%% Plot time series around reward port entry, separated by reward contingency

for c=1:numel(cohorts)
    %Account for change in name of Light protocol
    if strcmp(cohorts{c},'LHbCombo')
        protocol = '10';
    else
        protocol = 'RewLight'; %Stage 6 after training
    end
    
    %Load cohort data
    load([pwd '/datafiles/FP/WithheldRewards/' cohorts{c} protocol '.mat'],'T')
    D = convertoldMPCstruct(T,10);
    %D=T;
    mArray = unique({D.subject});
    
    %Loop through behavioral syncs
    for j=2:4
        figure('DefaultAxesFontSize',24,'Position',[1 393 284 239])
        
        %Get data from all outcome types
        for r = rewards
            M = nan(size(D(1).(syncname{1}),2),numel(mArray));
            zM = nan(size(D(1).(syncname{1}),2),numel(mArray));
            nSessions = nan(numel(mArray),1);
            for a=1:numel(mArray)
                idx = findStrInCell(mArray{a},{D.subject});
                nSessions(a) = numel(idx);
                zdata = vertcat(D(idx).(syncname{j}));
                data = vertcat(D(idx).([syncname{j} '_df']));
                
                %%%%%%Limit by Outcome
                alloutcomes = vertcat(D(idx).outcome);
                allrewards = vertcat(D(idx).rewardDel);
                zdata = zdata(alloutcomes==o & allrewards==r,:);
                data = data(alloutcomes==o & allrewards==r,:);

                %Exclude sessions w/ sync irregularities
                    if ~isempty(data) 
                        if (((o>1) && j==4) || (j==2 && o==4) || (j==5 && o==1))
                            zdata=[];
                        else; 
                            M(:,a) = nanmean(data,1);
                            zM(:,a) = nanmean(zdata,1);
                        end
                    end
            end
            
            %Plot Data
            if ~isempty(M)
                %limit to smaller xwin
                xstart = round((time_Win-1)*sr);
                xend = round((time_Win+4)*sr);
                x = t(xstart:xend);
                y = zM(xstart:xend,:);
                hold on;
                shadedErrorBar(x,nanmean(y,2),nanstd(y,0,2)./sqrt(size(y,2)),{'Color',colors(r+1,:)},.8,2);
                
                %%Stash means for dF/F for stats below
                fpstats{c,j,r+1}{1,1} = nanmean(zM(round((time_Win-1)*sr):round(time_Win*sr),:),1);
                fpstats{c,j,r+1}{1,2} = nanmean(zM(round((time_Win)*sr):round((time_Win+2)*sr),:),1);
                fpstats{c,j,r+1}{1,3} = nanmean(zM(round((time_Win-2)*sr):round((time_Win-1)*sr),:),1);
                fpstats{c,j,r+1}{1,4} = nanmean(zM(round((time_Win-.5)*sr):round((time_Win+.5)*sr),:),1);
        
            end
            
            %Add metadata to figure for paper legends
             text( 1,2, ['n = ' num2str(numel(unique(mArray))) ' mice'],'FontSize',6,'Color',[.9 .9 .9 ]);
             text( 1,1.8, ['n = ' num2str(sum(cell2mat({T.ntrials}))) ' trials'],'FontSize',6,'Color',[.9 .9 .9 ]);
             text( 1,1.6, ['Across ' num2str(sum(nSessions)) ' sessions'],'FontSize',6,'Color',[.9 .9 .9 ]);    

            %Set Axes Lims
            h=gcf; 
            xlim([-1 4])
            xticks([0 2 4])
            ylim([ymin(c) ymax(c)])
            prettyAxis()
            ax = gca;
            ax.LineWidth = 3;
        end
        
        %Save out figure as svg for manuscript
        if save_figure == 1
            plot2svg([pwd '/Figure 3/panels/' cohorts{c} '/' cohorts{c} protocol syncname{j} '.svg'],h);                            
        end  
    end
end

%% Plot Stats and export to csv.  - Right Panels C, D, E, F, G
close all
colors = rewLightColors(1)
colors = colors([2 1 3 4],:);
for c=1:numel(cohorts)
    j=4; %Reward syncs only
    
    %Make Fig
    h = figure('Position',[1000 1148 167 190])
    
    %Get data
    data = vertcat(fpstats{c,j,:});
    pre = cell2mat(data(:,1));
    post = cell2mat(data(:,2));
    data = post-pre;
    data = data([2 1 3 4],:)
    
    %Make Plot
    plotDistwMean(data',colors)
    
    %figure props
    xlim([0.5,4.5])
    xticks([1 2 3 4])
    xticklabels({});
    prettyAxis()
    box off
    ylabel('Z Score')
    
    %Save out figure
    saveas(gcf, [pwd '/Figure 3/panels/' cohorts{c} '/' cohorts{c} '_RewLight_stats.pdf']);    
    
    %Export Stats for Prism
    eventLabels = {'Start','Cue', 'Poke', 'Reward'};
    nData = numel(fpstats{c,j,1}{1});
    statExport = nan(4,nData,2);
    for i=1:4
        statExport(i,:,1) = fpstats{c,j,i}{1};
        statExport(i,:,2) = fpstats{c,j,i}{2};
    end
    csvwrite([pwd '/Figure 3/stats/' cohorts{c} '_' eventLabels{i} '_RewLight_FPstats.csv'],statExport);
    
    %For TH, also look at Approach
    if c==1
       h = figure('Position',[1000 1148 167 190])
        data = vertcat(fpstats{c,j,:});
        pre = cell2mat(data(:,3));
        post = cell2mat(data(:,4));
        data = post-pre;
        data = data([2 1 3 4],:)
        plotDistwMean(data',colors)
        xlim([0.5,4.5])
        xticks([1 2 3 4])
        xticklabels({});
        prettyAxis()
        box off
        ylabel('Z Score') 
        saveas(gcf, [pwd '/Figure 3/panels/' cohorts{c} '/' cohorts{c} '_RewLightApproach_stats.pdf']);   
    end
    
end



