

%% Fiber Photometry Panels, Stats and Summary for Figure 2

%This Script Runs 3 types of analysis.  

%1. For Left Panels F,G,H, it aligns
%the specified data (Zscore or DF/F) at the specified behavior sync, sorted
%by trial outcome (correct, incorrect, omitted, premature)

%2. For each behavioral synce, for each cohort, the F is calulcated before
%and after the behavioral sync for each outcome. For Cue and Poke, where
%more than one outcome exists, and ANOVA is used. For reward, a paried
%t-test is used. 

%3. The data is analyzed for both reward approach and reward consumption.
%A metric of post-pre is calculated. %The data are compared across cohorts 
%for summary plot One Sample T-test plus FDR is used to determine if there
%is a significant effect for each cohort for the two reward metrics. 

%% Make FP Plots aligned to Syncs -  Left Panels F,G,H
cd '~/Dropbox/MHb Figure Drafts/Data/'
%Get Plot Params
dataLabels = {'Correct','Incorrect','Omitted','Premature'};
cohorts = {'Th','Tac','chat','calb','LHbCombo'};
cohortLabels = {'Th','Tac1','ChAT','Calb1','Nonspecific LHb'};
outcomes = [1 2 3 4];
syncname = {'Start'; 'Cue'; 'Poke'; 'Reward';'HeadIn'};

time_Win = 7;
sr=1017/50;
t = linspace(-time_Win,time_Win, (2*sr*time_Win));   
colors = mhbColors(2);
save_figure = 1;
protocol = '6'; %Stage 6 after training
DataOutputFolder = 'FP_3CSRTT';
dataUnits = 'Zscore';
fpstats=cell(numel(cohorts),numel(syncname),2);
for c=1:numel(cohorts)
    %Load cohort data
    load([pwd '/datafiles/FP/StandardTask/' cohorts{c} protocol '.mat'],'T')
    D=T;
    mArray = unique({D.subject});
    
    %Loop through behavioral syncs
    for j=2:4
        figure('DefaultAxesFontSize',24,'Position',[1 393 284 239])
        
        %Get data from all outcome types
        for o = outcomes
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
                zdata = zdata(alloutcomes==o,:);
                data = data(alloutcomes==o,:);

                %Exclude sessions w/ sync irregularities
                if ~isempty(data) 
                    if (((o>1) && j==4) || (j==2 && o==4) || (j==5 && o==1))
                        zdata=[];
                        data = [];
                    else 
                        zM(:,a) = nanmean(zdata,1);
                        M(:,a) = nanmean(data,1);
                    end
                end
            end
            
            %Plot Data
            if ~isempty(M)
                %limit to smaller xwin for compact figures
                xstart = round((time_Win-1)*sr);
                xend = round((time_Win+4)*sr);
                x = t(xstart:xend);
                y = zM(xstart:xend,:);
                hold on;

                %Make a shaded error bar
                h = shadedErrorBar(x,nanmean(y,2),nanstd(y,0,2)./sqrt(size(y,2)),{'Color',colors(o,:)},.8,2);
                set(get(get( h(1).patch,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                
                %%Stash means for dF/F for stats below. Accomodate
                %%different analysis windows for some syncs.
                if j<4
                    fpstats{c,j,o}{1,1} = nanmean(M(round((time_Win-1)*sr):round(time_Win*sr),:),1);
                    fpstats{c,j,o}{1,2} = nanmean(M(round((time_Win)*sr):round((time_Win+1)*sr),:),1);
                else
                    fpstats{c,j,o}{1,1} = (nanmean(M(round((time_Win-1)*sr):round(time_Win*sr),:),1));
                    fpstats{c,j,o}{1,2} = (nanmean(M(round((time_Win)*sr):round((time_Win+4)*sr),:),1));
                    fpstats{c,j,o}{2,1} = (nanmean(M(round((time_Win-1.5)*sr):round((time_Win-.5)*sr),:),1));
                    fpstats{c,j,o}{2,2} = (nanmean(M(round((time_Win-.5)*sr):round((time_Win)*sr),:),1));
                    fpstats{c,j,o}{3,1} = (nanmean(M(round((time_Win-1)*sr):round((time_Win-0)*sr),:),1));
                    fpstats{c,j,o}{3,2} = (nanmean(M(round((time_Win)*sr):round((time_Win+2)*sr),:),1));
                end
            end

            %Add rectangle for cue light
            switch syncname{j}
                case 'Cue' 
                    width = 1;
                    height = 1;
                    if  ~isnan(height)
                    x = [0 height];
                    rectangle('Position', [x width height*1/10],...
                         'FaceColor', 'y','EdgeColor', 'k');
                    end
                otherwise
                    plot([0 0],[-5 20],'--k','LineWidth',1.5)
            end  
            
            %Add metadata to figure for paper legends
             text( 1,1.8 , ['n = ' num2str(numel(unique(mArray))) ' mice'],'FontSize',6,'Color','w');
             text( 1,1.6, ['n = ' num2str(sum(cell2mat({T.ntrials}))) ' trials'],'FontSize',6,'Color','w');
             text( 1,1.4, ['Across ' num2str(sum(nSessions)) ' sessions'],'FontSize',6,'Color','w');    

            %Set Axes Lims
            h=gcf; 
            if j==4
                 xlim([-1 4])
                 xticks([0 2 4])
            else
                 xlim([-1 2])
                 xticks([-1 0 1 2])
            end
            ylim([-1 2])

            %%Make uniform figure properties
            prettyAxis()
            ax = gca;
            ax.LineWidth = 3;
            title(cohortLabels{c});
            xlabel(['Time from ' syncname{j} ' (s)'])
            ylabel(dataUnits)
        end
        %Save out figure as svg for manuscript
            if save_figure == 1
                %plot2svg([pwd '/Figure 2/panels/' cohorts{c} '/' cohorts{c} protocol syncname{j} '.svg'],h);                            

            end  
    end
end

%% Plot Stats 
close all
color = mhbColors(2);
x= [1 2];
for c=1:numel(cohorts)
    for j=[2 3 4]
        h = figure('Position',[1000 1148 167 190]);
        %Plot Pre v. Post dF/F
        if j<4
            for o=[1 2 3 4]
                meanFP = [fpstats{c,j,o}{1,1}; fpstats{c,j,o}{1,2}];
                y=nanmean(meanFP,2);
                err = nanstd(meanFP,[],2)./sqrt(size(meanFP,2));
                b=scatter(x,y,60,color(o,:),'filled');
                hold on
                for i=1:numel(err)
                    eb = errorbar(x(i),y(i), err(i), 'vertical', 'LineStyle', 'none');
                    set(eb, 'color', color(o,:), 'LineWidth',1)
                end
            end  
        else
            meanFP = [fpstats{c,j,1}{1,1}; fpstats{c,j,1}{1,2}]';
            y=nanmean(meanFP,1);
            plot(meanFP','Color',color(1,:))
            hold on
            b=scatter(x,y',60,color(1,:),'filled');
        end
        
        %Setup Fig props
        xticks([1 2])
        xticklabels({'Pre ','Post'});
        xtickangle(90)
        xlim([0 3])
        box off
        prettyAxis()
        ylabel('%\DeltaF/F')
        set(gca, 'FontSize',16)
        title([cohortLabels{c} ' - ' syncname{j}] )

        %Add stats
        if j<4
            %Export Stats 
            nData = numel(fpstats{c,j,i}{1});
            statExport = nan(4,nData,2);
            for i=1:4
                statExport(i,:,1) = fpstats{c,j,i}{1};
                statExport(i,:,2) = fpstats{c,j,i}{2};
                %csvwrite([pwd '/Figure 2/stats/' cohorts{c} '_' syncname{i} '_6_FPstats.csv'],statExport);
            end
            p=1;
        else
            [h,p] = ttest(meanFP(:,1),meanFP(:,2));
        end

        %Add significance symbols
        if p<=0.05 
            [a b] = max(y);
            text(1.5,a + err(b) +.1,['* p=' num2str(round(p,3))],'FontSize',10)
        end    

        %Save out figure
        if save_figure == 1
            %saveas(gcf, [pwd '/Figure 2/panels/' cohorts{c} '/' cohorts{c} protocol syncname{j} '_stats.pdf']);                            
        end  
        
    end
        
end



%% Compare across cohorts for summary plot.  One Sample T-test plus FDR
%Plot for both reward approach (datawindow==2) and reward consumption
%(datawindow = 3)

%Set up figs
nCohorts = numel(cohorts);
cohortLabels = {'TH','Tac1','ChAT','Calb1','LHb'};
pos1 = ones(10,1)*[1:1:numel(cohorts)];
colors = [mhbColors(1); [0 0 0]]
colors(4,:) = [239 192 82]/255
plotLabel = {'Approach','Consume'};

for datawindow = 2:3
    h=figure('DefaultAxesFontSize',25,'Position', [132 381 248 266]);
    hold on
    dF=nan(10,nCohorts);
    idx=nan(10,nCohorts);
    for c=1:numel(cohorts)
        dF(1:size(fpstats{c,4,1}{datawindow,1},2),c) = fpstats{c,4,1}{datawindow,2}-fpstats{c,4,1}{datawindow,1};
        idx(1:size(fpstats{c,4,1}{datawindow,1},2),c) = c*(ones(size(fpstats{c,4,1}{datawindow,1},2),1));
    end
    plotSpread(dF(:),'distributionIdx',pos1(:),'distributionColors',colors(1:numel(cohorts),:),'distributionMarkers',{'o'},'categoryColors',{'r','b'},'filled',1,'markerSize',5)
    prettyAxis()
    %ylim([-2 2])
    xticklabels({})
    %Get Stats
    tickpos = 1:1:numel(cohorts)
    for i=1:numel(cohorts)
    [~,p(i)] =ttest(dF(:,i));
    end

    %Correct for False Discovery Rate
    q=0;
    FDR = mafdr(p,'BHFDR','true');
    for i=1:numel(cohorts)
        if FDR(i)<0.001
            ptest = '***';
        elseif FDR(i)<0.01
                ptest = '**';
        elseif FDR(i)<0.05
                ptest = '*';
        else; ptest = ' ';
        end
        %Add text to plot
        t = text(tickpos(i),1.5,ptest,'FontSize',20);
        t = text(tickpos(i),1.7,num2str(round(FDR(i),4)),'FontSize',6);
        set(t,'Rotation',90);
        q=q+1;
    end
    
    %Save out plot
     %saveas(gcf, [pwd '/Figure 2/panels/' plotLabel{datawindow-1} '_Reward.pdf']) 
     
end
