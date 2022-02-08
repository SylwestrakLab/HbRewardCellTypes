%%% Analyze Opto stim for head-fixed data.  
%behavior:  head-fixed reward0-guided task using Bpod hardward and
%DynamicForagingHattoriStim.m script.   Animals have a pre-cue period in
%which they cannot lick (results in "premature" lick and trialtype==0).
%During 1s stim, licks may result in a reward.  Session has a block
%structure. During each block, one port is assigned a high reward
%probability (SessionData.RewardFraction1), and the other a low probability (SessionData.RewardFraction2) 
%Rewards are delivered based on the side of first lick and the reward
%probability.  Blocks alternate between right and left ports.  To
%crystallize behavior, the first 3 blocks have "helper" water. On the first
%incorrect lick, a small reward is delivered in the "correct" (i.e. high
%prob) port.  These trails are not included in the data analysis.
%After a variable ITI, the next trial begins.  

%Optogenetic Stim consists of two protocols 1) Stimulating/Inhibiting rewarded trials,
%which mainly occur later in the block switch after some persistant licks
%at the perviously rewarded port.  2)  Stimulating/Inhibiting unrewarded trials,
%which mainly occur at the beginning of the block switch during persistant licks
%at the perviously rewarded port


%This script loads data from one cohort and stimuluation protocol (either
%rewarded or unrewarded stim, as indicated above). The data is arranged in
%a stuct (D) that contains all data arranged by behavioral session (rows).  The D
%struct is used to generate plots for behavioral performance, reponse
%latency, lick distribution, and win-stay lose-switch dynamics. 


%Set the cohort and stimulation type
cohort = 'Int-MHb4-NpHR';  %Options: 'Int-MHb4-NpHR' and 'Int-MHb-ChR2'
SessionType = 'Rewarded';  %Options: 'Rewarded' and 'Unrewarded'

%Save out figs or no?
saveFigs=1;

%Get list of Bpod Files
rootdir = '~/Dropbox (University of Oregon)/UO-Sylwestrak Lab/Bpod Local/Data/';
%rootdir = '~/Git/Hb/Data/';
filelist = dir(fullfile(rootdir, '**/m*Stim_*.mat'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list

%Get dates to Analayze
analysisDates = {'20211026', '20211027','20211028','20211029','20211030','20211031','20211101','20211102','20211103',...
    '20211104','20211104','20211106','20211107','20211108','20211109','20211111','20211112','20211211','20211212','20211213','20211214','20211215'};

%Limit Filelist to these dates
idx=[];
for i=1:numel(analysisDates)
    idx1 = findStrInCell(analysisDates{i},{filelist.name});
    idx = [idx idx1];
end
filelist = filelist(idx);
clear idx

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
    %include only valid files, of this stim type, with the laser light on. 
    if (~isfield(SessionData.Info,'Exclude') || SessionData.Info.Exclude==0)...  %files excluded due to run errors
        && strcmp(SessionData.stimType,SessionType) ... %restrict to specificf protocol type
        && ~isempty(find(diff(SessionData.ActivePort)))...  % eliminate sessions stopped short with no transition switches
        && SessionData.lightOn==1    %restrict to session where the laser was on
            
        %Get all lick  for raster and identify which port was the first lick.
        [lickL, lickR, noLick, firstLick, latency] = getLicks(SessionData);
        
        %Make Variables to hold lick rasters
        nAllTrials = SessionData.nTrials;
        StimState = nan(nAllTrials,1);
        Rewarded = nan(nAllTrials,1);
        for t=1:nAllTrials    

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
        D(f).maxTransitionCount = maxTransitionCount;

        %Save out trial data for non-premature trials
        idxKeep = find(SessionData.TrialTypes~=0); %Remove premature trials (where SessionData.TrialTypes==0) 
        D(f).idxKeep = idxKeep;
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
        noLick = D(f).noLick;
        latency = D(f).Latency; 

        %Make transitions variable and laser variable that holds
        %info on if stim was delivered or not
        transitions = nan(numel(idxTransition),maxTransitionCount);
        stimTrials = nan(numel(idxTransition),maxTransitionCount);


        %Calculate duration of each block
        blockDur = [diff(idxTransition) (numel(ActivePort)-idxTransition(end))];%get the total block duration to make sure it's more than the transition count
        %Make array to get response rate and latency
        responded = nan(numel(idxTransition),maxTransitionCount);  %to calculate response rate (% of trials w/ lick)
        latArray = nan(numel(idxTransition),maxTransitionCount); %to calculate latency to first lick
        D(f).portBlock = nan(numel(idxTransition),1);

        %Average over all transitions between blocks\
        for i = 1:numel(idxTransition)
            act = ActivePort(idxTransition(i)); %get high reward prob port for this block
            Correct = D(f).firstLick == act; %determine if first lick was on high prob port
            if blockDur(i)>=(maxTransitionCount) %If the block is longer than the maxTransitionCount, analyze maxTransitionCount
                transitions(i,:) = Correct(idxTransition(i):idxTransition(i)+(maxTransitionCount-1)); %High Prob Choices During Transition
                stimTrials(i,:) = stimDelievered(idxTransition(i):idxTransition(i)+(maxTransitionCount-1)); %Potential Stim Trials
                responded(i,:) = ~noLick(idxTransition(i):idxTransition(i)+(maxTransitionCount-1));  %Was there a lick
                latArray(i,:) =  latency(idxTransition(i):idxTransition(i)+(maxTransitionCount-1)); %Get latency of first lick
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

        %Remove first 3 blocks w/ helper water
        transitions2 = D(f).transitions(4:end-1,:);
        StimBlock = D(f).StimBlock(4:end-1);
        portBlock = D(f).portBlock(4:end-1)';



        %Split up stim and no stim
        stimData(f,:) = nanmean(transitions2(StimBlock,:),1);
        nostimData(f,:) = nanmean(transitions2(~StimBlock,:),1);

        %Exclude if there is too few transitions
        if size(transitions2,1) >=minTransitions
            %Add into D struct
            D(f).stimTransitions = transitions2(StimBlock,:);
            D(f).nostimTransitions = transitions2(~StimBlock,:);
            D(f).noStimTranRight= transitions2((~StimBlock & portBlock==-1),:);
            D(f).StimTranRight= transitions2((StimBlock & portBlock==-1),:);
            D(f).noStimTranLeft= transitions2((~StimBlock & portBlock==1),:);
            D(f).StimTranLeft= transitions2((StimBlock & portBlock==1),:); 

        else
            idxExclude = [idxExclude f];
        end
        
        %Exclude if performance is below criterion in 
        left = transitions2((portBlock==-1),end-2:end);
        right = transitions2((portBlock==1),end-2:end);
        left = left(:);
        right = right(:);
        if mean(left)<.50 || mean(right)<.50
            idxExclude = [idxExclude f];
        end
               
    else     
        idxExclude = [idxExclude f];
    end
    
end

%Remove files excluded
idxExclude=idxExclude(idxExclude<=size(D,2));
filelist(idxExclude)=[];
D(idxExclude)=[];

clearvars -except D maxTransitionCount nMice mArray minTransitions ...
    lightColorLabel colorAlpha colorNum saveFigs ...
    cohort saveFigs SessionType...
    filelist

%% Remove animals w/ very few stim transitions


for f=1:size(D,2)
D(f).nStimTransitions = size(D(f).stimTransitions,1) + size(D(f).nostimTransitions,1);
end
for m=1:numel(mArray)
    idxMouse = findStrInCell(mArray{m},{D.subject});
    nStimTransitions(m) = sum([D(idxMouse).nStimTransitions]);
end
idxRemove = find(nStimTransitions<10)
for r=1:numel(idxRemove)
    idxMouse = findStrInCell(mArray{idxRemove(r)},{D.subject});
    D(idxMouse)=[];
end



%% For YoungJu - pull out data for RL learning

for i=1:size(D,2)
    %get the Subject
    RL(i).subject = D(i).subject;
    %get Index of first trial after the "free water shaping" blocks (1-3)
    %and the trial numbers of the subsequent trials
    %use indicies to pull relevant behavioral variables
    idxStart = D(i).idxTransition(4);
    idxTrials = idxStart:1:numel(D(i).ActivePort);
    RL(i).trialNo = idxTrials;
    RL(i).stim = D(i).StimState(idxTrials); %0= no stim; 1=stim
    RL(i).rewarded = D(i).Rewarded(idxTrials);  %0=no reward; 1=reward
    RL(i).lick = D(i).firstLick(idxTrials); %-1=Left; 1=right; 0=omitted
    RL(i).latency = D(i).Latency(idxTrials);
end

           
%%  Plot the behavior of each session for each animal

[stim, nostim] = plotBehaviorByMouse(D,cohort);

%% Plot Averages for Left vs Right

plotLvsR(D,cohort)

 %Save our figure
 if saveFigs
 plot2svg(['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/panels/cohortAverageLvsR_' cohort '_' SessionType '.svg'],gcf)
 end

%% Plot Averages for Each animal, and Cohort Average

[STIM, NOSTIM] = plotBehaviorAve(D,cohort);
if saveFigs
saveas(gcf,['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/panels/animalAverage_' cohort '_' SessionType '.jpg'],'jpg')
end


%% Analyze switch lag using trials 11-15

%Plot Data
trialNos = 11:15;
y1 = mean(NOSTIM(:,trialNos),2);
y2 = mean(STIM(:,trialNos),2);


figure('Position',[440 378 312 420])
b = barwitherr([nanstd(y1), nanstd(y2)]./sqrt(numel(y1)),[mean(y1), mean(y2)],'facecolor', 'flat');
b.CData(1,:) = [ 0 0 0 ]; b.CData(2,:) = colorNum; b.EdgeAlpha = 0;  hold on
plot([y1'; y2'],'Color',[.3 .3 .3])

%Figure Settings
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;xticks([1 2])
xticklabels({'No Light', lightColorLabel})
xtickangle(45); title('Cohort Average Trials 11-15')
ylabel({'Fraction on'; 'High pReward Port'})
[~, p] = ttest(y1,y2);  text(.5,.95,['p = ' num2str(round(p,3))])

clearvars -except D cohort STIM NOSTIM stim nostim cohort SessionType ...
     lightColorLabel colorAlpha colorNum saveFigs

%% Compare Lick at First Reward after switch w/ and w/o stim to look at general lick suppression


%get lick times.  first column is trial t, second column is trial t+1 and
%each row is a mouse
[stimLicks, nostimLicks,trialCount] = getLickDist(D,cohort);

%Plot Data
figure('Position',[440 514 551 284])
figureLabels = {'Trial_t', 'Trial_t+1'};
for t = 1:2
subplot(1,2,t)
if t==1
    [N,edges1,~] = histcounts([nostimLicks{:,t}]);
else
    [N,edges1,~] = histcounts([nostimLicks{:,t}],edges);
end

counts = N / sum(trialCount(:,1)); %normalize by number of non-stim trials
b1 = bar(edges1(1:end-1), counts,'FaceColor','k','EdgeColor','none','FaceAlpha',0.5);
hold on
maxCounts(1,t) = max(counts);

%Reuse edges from no stim histogram to directly compare
[N,edges,~] = histcounts([stimLicks{:,t}],edges1);
counts = N / sum(trialCount(:,2));  %normalize by number of stim trials
b2 = bar(edges(1:end-1), counts,'FaceColor',colorAlpha,'EdgeColor','none','FaceAlpha',0.5);
maxCounts(2,t) = max(counts);

%Figure Settings
l1=legend({'No Light', 'Light'});
xlim([-.5 6])

set(l1,'Box','off')
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;
xlabel('Time from Cue Start')
ylabel({'Norm. Number of Licks'})
title(figureLabels{t})

end

%Get uniform y limits
for i=1:2
    subplot(1,2,i)
    ylim([0 max(maxCounts(:))+.5])
end

gcf;
if saveFigs
print(['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/panels/lickDist_' cohort '_' SessionType '.pdf'],'-dpdf')
end
%close gcf

clearvars -except D cohort STIM NOSTIM stim nostim cohort SessionType ...
     lightColorLabel colorAlpha colorNum saveFigs

%% Analyze Win-Stay

%Get arrays with first win "accuracy", reponse probability, and response
%latency
%R array is response probabiltiy
%L array is the latency 
%S array is the stay probabily, i.e. the probability of a "correct" lick to
%the high reward port for another win.  

[R, S, L] = getStayShift(D,cohort,1)


%%Plot Win-Stay 
figure('Position',[1000 581 174 224])
y = nanmean(S,1);
std = nanstd(S,1);
b = barwitherr(std./sqrt(5),y,'facecolor', 'flat');
pause(.1)

%Figure Settings
b.CData(1,:) = [ 0 0 0]; b.CData(2,:) = colorNum; b.FaceAlpha = .5; b.EdgeAlpha = 0
%Figure Settings
b.CData(1,:) = [ 0 0 0]; b.FaceAlpha = .5; b.EdgeAlpha = 0
if strcmp(cohort,'Int-MHb4-NpHR')
    if strcmp(SessionType,'Rewarded')
    b.CData(2,:) = colorNum
    else
    b.CData(2,:) = [.8 .8 .8]
    end
else
    if strcmp(SessionType,'Rewarded')
    b.CData(2,:) = [.8 .8 .8]
    else
    b.CData(2,:) = colorNum
    end
end


hold on
plot([ 1 2],S,'Color',[.3 .3 .3])

xticks([1 2 3]); xticklabels({'No Stim','Stim'}); xtickangle(45  ) 
ylim([0 1.2])
ylabel('Fraction Stay')
title({'Win-Stay'}) 
contingencyType = 'WinStay';
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;

%Add Stats
[~,p] = ttest(S(:,1),S(:,2));
text(i,.95,['p = ' num2str(round(p,3))])  
pause(.1)

if saveFigs
print(['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/panels/WinStay_' cohort '_' SessionType '.pdf'],'-dpdf')
end
%close gcf

clearvars -except D cohort STIM NOSTIM stim nostim R L S cohort SessionType ...
     lightColorLabel colorAlpha colorNum saveFigs


%%  Response rate for trial after first win

%Plot Data

figure('Position',[1000 581 174 224])
b = barwitherr(nanstd(R,1)./sqrt(size(R,1)),nanmean(R,1),'facecolor', 'flat');
b.CData(1,:) = [ 0 0 0 ]; b.CData(2,:) = colorNum; b.FaceAlpha = .5; b.EdgeAlpha = 0;
hold on
plot(R','Color',[.3 .3 .3])
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
[~, p ]= ttest((R(:,1)),(R(:,2)));
text(i,.95,['p = ' num2str(round(p,3))])  


clearvars -except D cohort STIM NOSTIM stim nostim R L S cohort SessionType ...
     lightColorLabel colorAlpha colorNum saveFigs


%% Latencies for wins

figure('Position',[1000 581 174 224])
b = barwitherr(nanstd(L,1)./sqrt(size(L,1)),nanmean(L,1),'facecolor', 'flat');
b.CData(1,:) = [0 0 0]; b.CData(2,:) = colorNum; b.FaceAlpha = .5; b.EdgeAlpha = 0;
hold on
plot(L','Color',[.3 .3 .3])
xticks([1 2])
xticklabels({'No Light',lightColorLabel})
xtickangle(45)
ylabel('Latency First Lick')
title('Trial_t_+_1')
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;
[~,p] = ttest((L(:,1)),(L(:,2)));
text(.5,.3,['p = ' num2str(round(p,3))])

if saveFigs
print(['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/panels/LatencyAfterFirstWin_' cohort '_' SessionType '.pdf'],'-dpdf')
end
%close gcf

clearvars -except D maxTransitionCount nMice mArray minTransitions ...
     saveFigs cohort SessionType ...
     lightColorLabel colorAlpha colorNum saveFigs
     

%% Analyze Lose Shift

%Get arrays with first win "accuracy", reponse probability, and response
%latency
%R array is response probabiltiy
%L array is the latency 
%S array is the stay probabily, i.e. the probability of a "correct" lick to
%the high reward port for another win.  

[R, S, L] = getStayShift(D,cohort,0)


%%Plot Win-Stay 
figure('Position',[1000 581 174 224])
y = nanmean(S,1);
std = nanstd(S,1);
b = barwitherr(std./sqrt(5),y,'facecolor', 'flat');
pause(.1)

%Figure Settings
b.CData(1,:) = [ 0 0 0]; b.FaceAlpha = .5; b.EdgeAlpha = 0
if strcmp(cohort,'Int-MHb4-NpHR')
    if strcmp(SessionType,'Rewarded')
    b.CData(2,:) = [.8 .8 .8]
    else
    b.CData(2,:) = colorNum
    end
else
    if strcmp(SessionType,'Rewarded')
    b.CData(2,:) = colorNum
    else
    b.CData(2,:) = [.8 .8 .8]
    end
end

hold on
plot([ 1 2],S,'Color',[.3 .3 .3])

xticks([1 2 3]); xticklabels({'No Stim','Stim'}); xtickangle(45  ) 
ylim([0 1.2])
ylabel('Fraction Shift')
title({'Lose-Shift'})
contingencyType = 'LoseShift';
uniformFigureProps(); ax = gca; ax.TitleFontSizeMultiplier =.7;

%Add Stats
[~,p] = ttest(S(:,1),S(:,2));
text(i,.95,['p = ' num2str(round(p,3))])  
pause(.1)

if saveFigs
print(['~/Dropbox (Personal)/MHb Figure Drafts/Revisions/HeadFixedBehavior/Opto/WithStim/panels/LoseShift_TrialT+1_' cohort '_' SessionType '.pdf'],'-dpdf')
end
%close gcf


clearvars -except D maxTransitionCount nMice mArray minTransitions ...
     saveFigs cohort SessionType ...
     lightColorLabel colorAlpha colorNum saveFigs
     
 