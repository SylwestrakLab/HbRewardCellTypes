clear all
close all
saveFigs=1;


%Set the cohort and stimulation type
cohort = 'Int-MHb4-NpHR';
SessionType = 'Rewarded';


%Get list of Bpod Files
rootdir = '~/Dropbox (University of Oregon)/UO-Sylwestrak Lab/Bpod Local/Data/';
filelist = dir(fullfile(rootdir, '**/m*Stim_*.mat'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list

%Get dates to Analayze
analysisDates = {'20211026', '20211027','20211028','20211029','20211030','20211031','20211101','20211102','20211103',...
    '20211104','20211104','20211106','20211107','20211109','20211111','20211112','20211211','20211212','20211213','20211214','20211215'};

% %Limit Filelist to these dates
% idx=[];
% for i=1:numel(analysisDates)
%     idx1 = findStrInCell(analysisDates{i},{filelist.name});
%     idx = [idx idx1];
% end
% filelist = filelist(idx);
% clear idx

%Get Mouse Array
mArray = get_mice(cohort);
%Limit Filelist to these mice
idx=[];
for i=1:numel(mArray)
    idx1 = findStrInCell(mArray{i},{filelist.name});
    idx = [idx idx1];
end
filelist = filelist(idx);
clear idx


%Setup Figure colors for later, according to cohort
if strcmp(cohort, 'Int-MHb4-NpHR')
    colorAlpha = 'y';
    colorNum = [ 1 1 0 ];
    lightColorLabel = 'Yellow Light';
elseif strcmp(cohort, 'Int-MHb4-ChR2')
    colorAlpha = 'b';
    colorNum = [ 0 0 1  ];
    lightColorLabel = 'Blue Light';
else
    colorAlpha = 'b';
    colorNum = [ 0 0 1  ];
    lightColorLabel = 'Blue Light';
end
%

%Setup Variables for Stim and No Stim Transitions
%Set the minimum number of transitions for a day to use the data
%Set the performance criteria for no light conditions  
minTransitions = 2;
performanceThreshhold = 0;
maxTransitionCount = 15;  %number of trails after transition to analyze
nMice =numel(mArray);
idxExclude = [];  %array to keep track of filenames to exclude

%Load all the files but mark for exclusion files that have been flagged
%(due to short/restarts) 
for f = 1:numel(filelist)
    load(fullfile(filelist(f).folder,filelist(f).name))
    if ~isfield(SessionData,'lightOn')
        SessionData.lightOn = 0;
        SessionData.StimBlock  = zeros(numel(SessionData.StimBlock),1);
    else 
        D(f).lightOn =  SessionData.lightOn;
    end
    %include only valid files, of this stim type, with the laser light on. 
    if (~isfield(SessionData.Info,'Exclude') || SessionData.Info.Exclude==0)...  %files excluded due to run errors
            && strcmp(SessionData.stimType,SessionType) ... %restrict to protocol type
            && ~isempty(find(diff(SessionData.ActivePort)))...  % eliminate sessions stopped short with no transition switches
            && SessionData.lightOn==1    %restrict to session where the laser was on
            %Make Variables to hold lick rasters
                nAllTrials = numel(SessionData.TrialTypes);
                firstLick = nan(nAllTrials,1);
                lickL = cell(nAllTrials,1); 
                lickR = cell(nAllTrials,1);
                Cue = nan(nAllTrials,1);
                noLick = zeros(nAllTrials,1);
                latency = nan(nAllTrials,1);
                StimState = nan(nAllTrials,1);
                Rewarded = nan(nAllTrials,1);
            %Get all lick  for raster and identify which port was the first lick.
                for t=1:nAllTrials
                    
                    %Get Cue Time
                    Cue(t) = SessionData.RawEvents.Trial{t}.States.Cue(1);
                    
                    %Get all Licks for Raster
                    y =SessionData.RawEvents.Trial{t}.Events;
                    fL = nan(2,1);
                    
                    if isfield(y,'Port1In') 
                        lickL{t} = y.Port1In-Cue(t);
                        fL(1) = y.Port1In(1)-Cue(t);
                    end
                    if isfield(y,'Port2In') 
                        lickR{t} = y.Port2In-Cue(t);
                        fL(2) = y.Port2In(1)-Cue(t);
                    end
                    %Grab latency of first lick
                    [lat, idx] = min(fL);     

                    %Determine port of first lick
                    if any(~isnan(fL))
                        latency(t) = lat;
                        switch  idx
                            case 1
                                firstLick(t)=-1;
                            case 2
                                firstLick(t)=1;
                        end
                    else
                        firstLick(t)=0;
                    end
                    
                    %Get Omitted Trials                   
                    if ~isfield(y,'Port1In') && ~isfield(y,'Port2In')
                        noLick(t) = 1;
                    end
                    
                    
                    %Determine if there was simulation on this Trial due ot
                    %presence of the 'stim' state
                    if ~isnan(SessionData.RawEvents.Trial{t}.States.Stim(1))
                        StimState(t) = 1;
                    else
                        StimState(t) = 0;
                    end
                    
                    %Determine if the trial was rewarded
                    if ~isnan(SessionData.RawEvents.Trial{t}.States.RewardRight(1)) || ...
                            ~isnan(SessionData.RawEvents.Trial{t}.States.RewardLeft(1))
                        Rewarded(t) = 1;
                    else
                        Rewarded(t) = 0;
                    end
                end
                
                              
                %Save out session data in D Struct 
                strparts = split(filelist(f).name,'_');
                D(f).date = strparts{3};
                D(f).subject = filelist(f).name(1:5);
                D(f).highPR = SessionData.RewardFraction1;
                D(f).lowPR = SessionData.RewardFraction2;
                D(f).lightOn = SessionData.lightOn;
                D(f).StimType = SessionData.stimType;
                
                %Save out trial data for non-premature trials
                idxKeep = find(SessionData.TrialTypes~=0); %Remove premature trials (where SessionData.TrialTypes==0) 
                D(f).idxKeep = idxKeep;
                D(f).Cue = Cue(idxKeep);
                D(f).lickR = lickR(idxKeep);
                D(f).lickL = lickL(idxKeep); 
                D(f).firstLick = firstLick(idxKeep);
                D(f).ActivePort = SessionData.ActivePort(idxKeep);
                D(f).noLick = noLick(idxKeep);
                D(f).Latency = latency(idxKeep);
                D(f).StimState = StimState(idxKeep);
                D(f).Rewarded = Rewarded(idxKeep);
                
                %Save if this was a potential stim trial, was misspelled in
                %some sessions, so have to check for both spellings
                if isfield(SessionData, 'stimDelievered')
                    D(f).stimDelievered  = SessionData.stimDelievered(idxKeep);
                end
                if isfield(SessionData, 'stimDelivered')
                    D(f).stimDelievered  = SessionData.stimDelivered(idxKeep);
                end
                   
                
                %%%%%Find Transitions
                
                %Find Transitions using active port changes
                %Index is the first trial of the new block
                ActivePort = D(f).ActivePort;
                idxTransition = find(diff(ActivePort))+1; %First trial of new block           
                stimDelievered= D(f).stimDelievered;
                
                %Make transitions variable and laser variable that holds
                %info on if stim was delivered or not
                transitions = nan(numel(idxTransition),maxTransitionCount);
                stimTrials = nan(numel(idxTransition),maxTransitionCount);
                
                
                %Calculate duration of each block
                blockDur = diff(idxTransition) ;%get the total block duration to make sure it's more than the transition count
                blockDur  = [blockDur (numel(ActivePort)-idxTransition(end))]; %add on the length of the last block
                %Make array to get response rate and latency
                responded = nan(numel(idxTransition),maxTransitionCount);  %to calculate response rate (% of trials w/ lick)
                latArray = nan(numel(idxTransition),maxTransitionCount); %to calculate latency to first lick
                
                %Average over all transitions between blocks
                for i = 1:numel(idxTransition)
                    act = ActivePort(idxTransition(i)); %get high reward prob port for this block
                    Correct = firstLick == act; %determine if first lick was on high prob port
                    if blockDur(i)>=(maxTransitionCount) %If the block is longer than the maxTransitionCount, analyze maxTransitionCount
                        transitions(i,:) = Correct(idxTransition(i):idxTransition(i)+(maxTransitionCount-1)); %High Prob Choices During Transition
                        stimTrials(i,:) = stimDelievered(idxTransition(i):idxTransition(i)+(maxTransitionCount-1)); %Potential Stim Trials
                        responded(i,:) = ~noLick(idxTransition(i):idxTransition(i)+(maxTransitionCount-1));  %Was there a lick
                        latArray(i,:) = latency(idxTransition(i):idxTransition(i)+(maxTransitionCount-1)); %Get latency of first lick
                    else %if the block is too short, analyze only this block
                        transitions(i,1:blockDur(i)) = Correct(idxTransition(i):idxTransition(i)+blockDur(i)-1);
                        stimTrials(i,1:blockDur(i)) = stimDelievered(idxTransition(i):idxTransition(i)+blockDur(i)-1);
                        responded(i,1:blockDur(i)) = ~noLick(idxTransition(i):idxTransition(i)+blockDur(i)-1);
                        latArray(i,1:blockDur(i)) = latency(idxTransition(i):idxTransition(i)+blockDur(i)-1);
                    end
                    %Save which side was the high prob. side
                    D(f).portBlock(i) = act;
                end
                
                %Add in these analaysis to D struct
                D(f).transitions=transitions;
                D(f).responded=responded;
                D(f).latArray = latArray;
                D(f).StimBlock =logical(stimTrials(:,1))';
                D(f).idxTransition= idxTransition;
               
    else     
        idxExclude = [idxExclude f];
    end
    
end

%Remove files excluded due to 
filelist(idxExclude)=[];
D(idxExclude)=[];

clearvars -except D maxTransitionCount nMice mArray minTransitions ...
    lightColorLabel colorAlpha colorNum saveFigs ...
    cohort SessionType...
    filelist

           
%%  Plot the behavior of each session for each animal
figure('Position',[3131 405 1220 847])

%Variables to hold mean for each animal
STIM = nan(nMice,maxTransitionCount);
NOSTIM = nan(nMice,maxTransitionCount);

for m=1:nMice
    excludePoorPerformace = [];
    idxFiles = findStrInCell(mArray{m},{D.subject});
    stimData = [];
    nostimData =[];
    pctRespond=[];
    if ~isempty(idxFiles)
        for f=1:numel(idxFiles)
            idx = idxFiles(f);
            
            %Remove first 3 blocks w/ helper water
            transitions = D(idx).transitions(4:end-1,:);
            StimBlock = D(idx).StimBlock(4:end-1);
            portBlock = D(idx).portBlock(4:end-1);
            
            %Split up stim and no stim
            stimData(f,:) = nanmean(transitions(StimBlock,:),1);
            nostimData(f,:) = nanmean(transitions(~StimBlock,:),1);
           
            if size(transitions,1) >=minTransitions
                %Add into D struct
                D(idx).stimTransitions = transitions(StimBlock,:);
                D(idx).nostimTransitions = transitions(~StimBlock,:);
                
                D(idx).noStimTranRight= transitions((~StimBlock & portBlock==-1),:);
                D(idx).StimTranRight= transitions((StimBlock & portBlock==-1),:);
                D(idx).noStimTranLeft= transitions((~StimBlock & portBlock==1),:);
                D(idx).StimTranLeft= transitions((~StimBlock & portBlock==1),:); 
                
                %Plot the data for this mouse and day
                subplot(7,nMice,((f-1)*nMice)+m)
                plot(nostimData(f,:),'k','LineWidth',4); hold on
                plot(stimData(f,:),colorAlpha,'LineWidth',4)            
                text(7,.2,{ ['n = ' num2str(sum(StimBlock)) ' stim'] ; ['n = ' num2str(sum(~StimBlock)) ' no stim'] })
                uniformFigureProps(); ylim([0 1 ])
                title({['Ave ' mArray{m}] ; D(idx).date})
                ax = gca;
                ax.TitleFontSizeMultiplier =.7;   
            else
                excludePoorPerformace = [excludePoorPerformace f];
            end
        end
        
        %Exclude Data with too few transitions in the session
        nostimData(excludePoorPerformace,:)=[];
        stimData(excludePoorPerformace,:)=[];
             
        %Figure Settings
        uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;
        xlabel('Trials from Switch')
        ylabel({'Fraction on'; 'High pReward Port'})
        title({['Ave ' mArray{m}] ; D(idx).date})
        
        %%%Stash data for cohort mean
        if ~isempty(stimData)
        STIM(m,:) = nanmean(stimData,1);
        NOSTIM(m,:) = nanmean(nostimData,1);
        end
       
    end
end

h=gcf;
h.PaperSize = [20 20];
%print(['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/SwitchingBehaviorByDay_' SessionType  '_' cohort '.pdf'],'-dpdf')
%close gcf

clearvars -except D maxTransitionCount nMice mArray minTransitions ...
    lightColorLabel colorAlpha colorNum saveFigs cohort SessionType


%% Plot Averages for Each animal, and Cohort Average
figure('Position',[2896 751 1241 413])

for i=1:numel(mArray)
    subplot(2,6,i)
    %Get data for this mouse
    idx = findStrInCell(mArray{i},{D.subject});
    if ~isempty(idx)       
        %Concatenate transition data across multiple sessions
        y1 =vertcat(D(idx).nostimTransitions)
        y2 =vertcat(D(idx).stimTransitions)

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

%%%Plot Cohort Average
subplot(2,6,7); hold on
shadedErrorBar(1:1:maxTransitionCount,nanmean(NOSTIM,1),nanstd(NOSTIM,[],1)./sqrt(numel(mArray)),{'Color','k','LineWidth',4},.8)
shadedErrorBar(1:1:maxTransitionCount,nanmean(STIM,1),nanstd(STIM,[],1)./sqrt(numel(mArray)),{'Color',colorAlpha,'LineWidth',4},.8)

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

if saveFigs
plot2svg(['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/panels/cohortAverage_' cohort '_' SessionType '.svg'],gcf)
end
%close gcf


clearvars -except D maxTransitionCount nMice mArray minTransitions ...
    lightColorLabel colorAlpha colorNum saveFigs cohort SessionType

%% Plot Averages for Left vs Right

figure('Position',[1000 1100 305 238]); hold on
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

%Plot averages for unstimulated data 
shadedErrorBar(1:1:15,nanmean(1-y1,1),nanstd(y1,[],1)./sqrt(size(y1,1)),{'Color',[0 1 0],'LineWidth',4},.8); hold on
shadedErrorBar(1:1:15,nanmean(y3,1),nanstd(y3,[],1)./sqrt(size(y3,1)),{'Color',[0 0 1],'LineWidth',4},.8)

%Set figure properties
xlabel('Trials from Switch')
ylabel({'Fraction Left Choice'})
title('Cohort Average')
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;


%Save our figure

if saveFigs
plot2svg(['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/panels/cohortAverageLvsR_' cohort '_' SessionType '.svg'],gcf)
end
%close gcf

h=gcf;
h.PaperSize = [22 6];
d = datestr(now,'yyyymmdd');

clearvars -except D maxTransitionCount nMice mArray minTransitions ...
    lightColorLabel colorAlpha colorNum saveFigs cohort SessionType

%% Analyze switch lag using trials 11-15

for i=1:numel(mArray)
     idx = findStrInCell(mArray{i},{D.subject});
    if ~isempty(idx)       
        %Concatenate transition data across multiple sessions
        x1 =vertcat(D(idx).nostimTransitions)
        x2 =vertcat(D(idx).stimTransitions)
        NOSTIM(i,:) = nanmean(x1,1);
        STIM(i,:) = nanmean(x2,1);   
    end
end
%Plot Data
y1 = mean(NOSTIM(:,11:15),2);
y2 = mean(STIM(:,11:15),2);
[~, p] = ttest(y1,y2);
subplot(2,6,8)
figure

%Figure Settings
b = barwitherr([nanstd(y1)./sqrt(numel(y1)), nanstd(y2)./sqrt(numel(y2))],[mean(y1), mean(y2)],'facecolor', 'flat');
b.CData(1,:) = [ 0 0 0 ]; b.CData(2,:) = colorNum; b.EdgeAlpha = 0;
hold on
plot([y1'; y2'],'Color',[.3 .3 .3])
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;xticks([1 2])
xticklabels({'No Light', lightColorLabel})
xtickangle(45)
ylabel({'Fraction on'; 'High pReward Port'})
title('Cohort Average')
text(.5,.95,['p = ' num2str(round(p,3))])

clearvars -except D maxTransitionCount nMice mArray minTransitions ...
    lightColorLabel colorAlpha colorNum saveFigs cohort SessionType ...
    win lose

%% Compare Lick at First Reward after switch w/ and w/o stim to look at general lick suppression
%Make variables to hold licks for rasters
nostimLicks = cell(20,1);
stimLicks = cell(20,1);
nostimLicksNextTrial=cell(20,1);
stimLicksNextTrial=cell(20,1);

%Keep track of how many stim an no stim trials there are for normalization
noStimTrialCount=0;
StimTrialCount=0;

for m=1:nMice
    %Grab data from this mouse
    idxFiles = findStrInCell(mArray{m},{D.subject});
        
    %iterate through multiple sessions   
    for j=1:numel(idxFiles)
        f = idxFiles(j);
        
        %%%%Get the "correct" trials that the LASER TURNED OFF
        idxStim = find((D(f).firstLick == D(f).ActivePort')&~D(f).stimDelievered');
        
        %Get indices of trials at start of no stim transitions
        idxTran = D(f).idxTransition(~D(f).StimBlock);
        
        %iterate through each stimulated transition
        if ~isempty(idxTran)
            for i=1:numel(idxTran)
                %Find the first would-be trial after the transition
                firstStimIdx = idxStim(idxStim>idxTran(i) & idxStim<idxTran(i)+9);
                if ~isempty(firstStimIdx)
                    for ii=1:numel(firstStimIdx)
                        %if one exists, get left and right lick array for that trial
                        nostimLicks{i} = [nostimLicks{i} [D(f).lickR{firstStimIdx((ii))}] [D(f).lickL{firstStimIdx((ii))}]];
                        
                        % And the arrays for the next trial
                        nostimLicksNextTrial{i} = [nostimLicksNextTrial{i} [D(f).lickR{firstStimIdx((ii))+1}] [D(f).lickL{firstStimIdx((ii))+1}]];
                        
                        %Add this trial to the count for normalization
                        noStimTrialCount  = noStimTrialCount +1;
                    end
                end
            end
        end 
        
        %%%%%Get the  "correct" trials that the LASER TURNED ON
        idxStim = find((D(f).firstLick == D(f).ActivePort')&D(f).stimDelievered');
        
        %Get indices of trials at start of stim transitions
        idxTran = D(f).idxTransition(D(f).StimBlock);
        
        %iterate through each stimulated transition
        if ~isempty(idxTran)
            for i=1:numel(idxTran)
                %Find the first stim trial after the transition
                firstStimIdx = idxStim(idxStim>idxTran(i) & idxStim<idxTran(i)+10) ;
                
                %if one exists, get the lick array for that trial and the
                %next trial
                if ~isempty(firstStimIdx)
                        %if one exists, get left and right lick array for that trial
                        stimLicks{i} = [stimLicks{i} [D(f).lickR{firstStimIdx(1)}] [D(f).lickL{firstStimIdx(1)}]];
                        
                        % And the arrays for the next trial
                        stimLicksNextTrial{i} = [stimLicksNextTrial{i} [D(f).lickR{firstStimIdx(1)+1}] [D(f).lickL{firstStimIdx(1)+1}]];
                        
                        %Add this trial to the count for normalization
                        StimTrialCount  = StimTrialCount +1;
                end
            end
        end        
    end
end
%
%Plot Data
figure('Position',[440 514 551 284])
figureLabels = {'Trial_t', 'Trial_t+1'};
for s = 1:2
subplot(1,2,s)
if s==1
    [N,edges1,~] = histcounts(nostimLicks{s});
else
    [N,edges1,~] = histcounts(nostimLicks{s},edges);
end

counts = N / noStimTrialCount;
b1 = bar(edges1(1:end-1), counts,'FaceColor','k','EdgeColor','none','FaceAlpha',0.5);
hold on
maxCounts(1,s) = max(counts);

%Reuse edges from no stim histogram to directly compare
[N,edges,~] = histcounts(stimLicks{s},edges1);
counts = N / StimTrialCount;
b2 = bar(edges(1:end-1), counts,'FaceColor',colorAlpha,'EdgeColor','none','FaceAlpha',0.5);
maxCounts(2,s) = max(counts);

%Figure Settings
l1=legend({'No Light', 'Light'});
xlim([-.5 6])

set(l1,'Box','off')
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;
xlabel('Time from Cue Start')
ylabel({'Norm. Number of Licks'})
title(figureLabels{s})

end
for i=1:2
    subplot(1,2,i)
    ylim([0 max(maxCounts(:))+.5])
end

gcf;
if saveFigs
print(['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/panels/lickDist_' cohort '_' SessionType '.pdf'],'-dpdf')
end
%close gcf


hold off

clearvars -except D maxTransitionCount nMice mArray minTransitions ...
    lightColorLabel colorAlpha colorNum saveFigs cohort SessionType ...
    win lose

%% Analyze Win-Stay
%For rewarded stim sessions 
win = 1;
lose  = 0;
R1=nan(6,2);
S1=nan(6,2);
L1=nan(6,2);
for stimType = [0 1]
%%% Get Probability for  Trials

for m=1:numel(mArray)
    %Get Sessions From This mouse
    idxMouse = findStrInCell(mArray{m},{D.subject});
    D2 = D(idxMouse);
    response = [];
    switches = [];  
    latencies = [];
    for i = 1:size(D2,2)
        if ~isempty(D2(i).transitions)
            
            %Get the stim conditions for each transition
            SB = D2(i).StimBlock(1:size(D2(i).transitions,1));
            idxBlock = find(SB==stimType);
            
            %Remove first 3 blocks were there are free rewards
            idxBlock = idxBlock(idxBlock>3);
            idxBlock = idxBlock(1:end-1);
            
            %Limit to Unstimulated Blocks
            t = D2(i).transitions(idxBlock,:);
            r = D2(i).responded(idxBlock,:);
            l = D2(i).latArray(idxBlock,:);  
            
            %Make empty variables
            switchArray = nan(size(t,1),1);
            futureResponse = nan(size(t,1),1);
            winLatency = nan(size(l,1),1);
            %for each transition, find the correct/rewarded trials
            checkSize(i)=size(t,1);
            for j=1:size(t,1)
                idx = find(t(j,1:maxTransitionCount-1)==win);
                if ~isempty(idx)
                    %For the first rewarded trial, find the probability of
                    %the next 3 trials
                    for k = 1%:3
                        if numel(idx)>=k
                            reward = idx(k);
                            switchArray(j,k) = t(j,reward+1);
                            futureResponse(j,k) = r(j,reward+1);
                            winLatency(j,k) = l(j,reward+1);
                        end
                    end
                end
            end
        end
        switches = [switches; switchArray];
        response = [response; futureResponse];
        latencies = [latencies; winLatency];
    end
    
    if ~isempty(switches)
    R1(m,stimType+1) = nanmean(response,1);
    S1(m,stimType+1) = nanmean(switches,1);
    L1(m,stimType+1) = nanmean(latencies,1);
    end
end

end


%%%Plot Win-Stay 
figure('Position',[1000 1114 250 224])
y = nanmean(S1,1);
std = nanstd(S1,1);
b = barwitherr(std./sqrt(5),y,'facecolor', 'flat');
pause(.1)

%Figure Settings
b.CData(1,:) = [ 0 0 0]; b.CData(2,:) = colorNum; b.FaceAlpha = .5; b.EdgeAlpha = 0
hold on
plot([ 1 2],S1,'Color',[.3 .3 .3])


xticks([1 2 3]); xticklabels({'No Stim','Stim'}); xtickangle(45  ) 
ylim([0 1.2])
ylabel('Fraction Stay')
title({'Win-Stay'}) 
contingencyType = 'WinStay';
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;

%Add Stats
[~,p] = ttest(S1(:,1),S1(:,2));
text(i,.95,['p = ' num2str(round(p,3))])  
pause(.1)

if saveFigs
print(['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/panels/WinStay_' cohort '_' SessionType '.pdf'],'-dpdf')
end
%close gcf

clearvars -except D maxTransitionCount nMice mArray minTransitions ...
    lightColorLabel colorAlpha colorNum saveFigs cohort SessionType ...
    R1 R2 S1 S2 L1 L2 win lose

%%  Response rate for trial after first win

%Plot Data

figure('Position',[1000 1083 294 255])
b = barwitherr(nanstd(R1,1)./sqrt(size(R1,1)),nanmean(R1,1),'facecolor', 'flat');
b.CData(1,:) = [ 0 0 0 ]; b.CData(2,:) = colorNum; b.FaceAlpha = .5; b.EdgeAlpha = 0;
hold on
plot(R1','Color',[.3 .3 .3])
xticks([1 2])
xticklabels({'No Light',lightColorLabel})
xtickangle(45)
ylim([0 1.1])
ylabel('Response Rate')
title('Trial_t_+_1')
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;
gcf;
if saveFigs
print(['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/panels/responseRateAfterFirst Win_' cohort '_' SessionType '.pdf'],'-dpdf')
end
[~, p ]= ttest((R1(:,1)),(R1(:,2)));
text(i,.95,['p = ' num2str(round(p,3))])  


clearvars -except D maxTransitionCount nMice mArray minTransitions ...
    lightColorLabel colorAlpha colorNum saveFigs cohort SessionType ...
    R1 R2 S1 S2 L1 L2

%% Latencies for wins

figure('Position',[1000 1083 294 255])
b = barwitherr(nanstd(L1,1)./sqrt(size(L1,1)),nanmean(L1,1),'facecolor', 'flat');
b.CData(1,:) = [0 0 0]; b.CData(2,:) = colorNum; b.FaceAlpha = .5; b.EdgeAlpha = 0;
hold on
plot(L1','Color',[.3 .3 .3])
xticks([1 2])
xticklabels({'No Light',lightColorLabel})
xtickangle(45)
ylabel('Latency First Lick')
title('Trial_t_+_1')
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;
[~,p] = ttest((L1(:,1)),(L1(:,2)));
text(.5,.3,['p = ' num2str(round(p,3))])

if saveFigs
print(['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/panels/LatencyAfterFirstWin_' cohort '_' SessionType '.pdf'],'-dpdf')
end
%close gcf

clearvars -except D maxTransitionCount nMice mArray minTransitions ...
     saveFigs cohort SessionType ...
     lightColorLabel colorAlpha colorNum ...
     win lose ...
     

%% Analyze Lose Shift

%%% Get Probability for Non-Stimulated Trials
R1=nan(6,2);
S1 = nan(6,2);

for stimType = [0 1]

for m=1:numel(mArray)
    %Get Sessions From This mouse
    idxMouse = findStrInCell(mArray{m},{D.subject});
    D2 = D(idxMouse);
    response = [];
    switches = [];
    for i = 1:size(D2,2)
        if ~isempty(D2(i).transitions)
            
            %Get the stim conditions for each transition
            SB = D2(i).StimBlock(1:size(D2(i).transitions,1));
            idxBlock = find(SB==stimType);
            
            %Remove first 3 blocks were there are free rewards
            idxBlock = idxBlock(idxBlock>3);
            
            %Limit to Stimulated Blocks
            t = D2(i).transitions(idxBlock,:);
            r = D2(i).responded(idxBlock,:);
            
            %Create Empty Arrays to hold switches and response/omit
            switchArray = nan(size(t,1),10);
            futureResponse = nan(size(t,1),10);
            
            %for each transition, find the unrewarded trials
            for j=1:size(t,1)
                idx = find(t(j,1:maxTransitionCount-1)==lose);
                if ~isempty(idx)
                    %For the first unrewarded trial, find the probability of
                    %the next trial
                    reward = idx(1);  
                    %if reward~=1
                            switchArray(j,1) = t(j,idx(1)+1);
                            futureResponse(j,1) = r(j,idx(1)+1);
                    %end
                end
            end
        end
        switches = [switches; switchArray];
        response = [response; futureResponse];
    end
    allswitches{m} = switches;
    if ~isempty(switches)
    switches(isnan(switches(:,1)),:)=[];
    response(isnan(response(:,1)),:)=[];
    R1(m,stimType+1) = nanmean(response(:,1));
    S1(m,stimType+1) = nanmean(switches(:,1));
    end
    
   
     
end

end


%%%Plot Lose-Shift

y = nanmean(S1,1);
std = nanstd(S1,1);

%%%%Save our illustrator fig
figure('Position',[1000 1083 294 255])
b = barwitherr(std./sqrt(5),y,'facecolor', 'flat');

b.CData(1,:) = [ 0 0 0]; b.CData(2,:) = colorNum; b.FaceAlpha = .5; b.EdgeAlpha = 0
hold on
plot([1 2],S1,'Color',[.3 .3 .3])
xticks([1 2 3]); xticklabels({'1','2','3'}); %xtickangle(45  ) 
xlabel('n Rewarded Trials')
ylim([0 1.2])
ylabel('Fraction Shift')
title({'Lose-Shift'})
contingencyType = 'LoseShift';
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;

%Add Stats
[~,p] = ttest(S1(:,1),S1(:,2));
text(1,.95,['p = ' num2str(round(p,3))])  

if saveFigs
print(['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/panels/LoseShift_TrialT+1_' cohort '_' SessionType '.pdf'],'-dpdf')
end
%close gcf

clearvars -except D maxTransitionCount nMice mArray minTransitions ...
     saveFigs cohort SessionType ...
     lightColorLabel colorAlpha colorNum ...
     win lose ...
     
 