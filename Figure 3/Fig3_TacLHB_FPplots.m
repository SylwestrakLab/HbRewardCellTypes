%% Make plots for figure 3 I-K

%% Load Data set of LHb Targeted Tac1 FP mice

load([pwd '/data/FP/WithheldRewards/Int-LHb7.mat'])

%Get Plot Params
cohorts = {'Int-LHb2'};
o=1; %only correct trials
rewards = [0 1]; %Simplifed scheme of rewarded/withheld
syncname = {'Start'; 'Cue'; 'Poke'; 'Reward';'HeadIn'};
time_Win = 7;
sr=1017/50;
t = linspace(-time_Win,time_Win, (2*sr*time_Win));   
colors = rewLightColors(1); %Black/Green color scheme
save_figure = 1;
j=4;  %Rewarded Syncs only
protocol = '7'; %Stage 6 after training
DataOutputFolder = 'FP_3CSRTT';
dataUnits = 'Zscore';
fpstats=cell(numel(cohorts),1,4);
ymin = -1;
ymax = 5;



%Load cohort data
load([pwd '/data/FP/WithheldRewards/' cohorts{c} protocol '.mat'],'T')
D = convertoldMPCstruct(T);
mArray = unique({D.subject});

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


%% Plot Stats - Right Panels C, D, E, F, G
close all
colors = rewLightColors(1)
colors = colors([2 1 3 4],:);   
    %Make Fig
    h = figure('Position',[1000 1148 167 190])
    
    %Get data
    data = vertcat(fpstats{c,j,:});
    pre = cell2mat(data(:,1));
    post = cell2mat(data(:,2));
    data = post-pre;
    data = data([2 1],:)
    
    %Make Plot
    plotDistwMean(data',colors)
    
    %figure props
    xlim([0.5,2.5])
    xticks([1 2])
    xticklabels({});
    prettyAxis()
    box off
    ylabel('Z Score')
    
    %Save out figure
    saveas(gcf, [pwd '/Figure 3/panels/' cohorts{c} '/' cohorts{c} '_TacWitheld_stats.pdf']);    
    
    %Export Stats for Prism
    eventLabels = {'Start','Cue', 'Poke', 'Reward'};
    nData = numel(fpstats{c,j,1}{1});
    statExport = nan(2,nData,2);
    for i=1:2
        statExport(i,:,1) = fpstats{c,j,i}{1};
        statExport(i,:,2) = fpstats{c,j,i}{2};
    end
    csvwrite([pwd '/Figure 3/stats/' cohorts{c} '_' eventLabels{i} '_TacWitheld_FPstats.csv'],statExport);
    

    


