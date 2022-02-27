%% Get Reward Latency and Duration in reward port
cd '~/Dropbox/MHb Figure Drafts/Data/'

load([pwd '/datafiles/behaviorFiles/3ChoiceBehavior.mat'])

%% Get Reward Latency from MPC K array (Stanford) and Session data Structures (Oregon)
%Get outcomes
K = vertcat(allbehaviorFiles.kArray);
WithheldStages = vertcat(allbehaviorFiles.stageID)==10;
mouseid = vertcat(allbehaviorFiles.subjID);
correct = K(:,4)~=0;
idx = WithheldStages & correct;
rewardDur = K(idx,13);
lat = K(idx,6);
mouseid = mouseid(idx);


%Calculate Latency Aross All Mices where this protocol was run
latency = nan(numel(mArray),4);
%For all reward contingencies
for r=0:3
    %For each animal
    for m=1:numel(mArray)
        thisLatency = lat(rewardDur==r & mouseid==m);
        latency(m,r+1) = mean(thisLatency)
    end
end
%% Get Reward Latency 
figure('Position',[264 908 178 148])
colors = rewLightColors(1);
newIdx = [2 1 3 4];
colors = colors(newIdx,:);
y = nanmean(latency(:,newIdx),1);
s = nanstd(latency(:,newIdx),[],1)
n = size(latency(:,newIdx),1);
b = bar(nanmean(latency(:,newIdx),1))
b.FaceColor = 'flat';
b.EdgeColor = 'none';
hold on
err = errorbar(1:1:4,y,s./sqrt(n),'.')

for i=1:4
    b.CData(i,:) = colors(i,:);
    err = errorbar(i,y(i),s(i)./sqrt(n),'Color',colors(i,:),'LineWidth',2)
end
uniformFigureProps();
ylabel('Latency (s)')
xticklabels({}) 

%% Get Drink Duration 

%This is not captured by MPC, so the sycns from synapse (TDT) must be used.
% Load the T struct and find the associated processed TDT files. 
load([pwd '/datafiles/FP/WithheldRewards/TacRewLight.mat'])

%Get processed files w/ Syncs
for i=1:size(T,2)
    filedate = datestr(datenum(T(i).header.Start_Date,'mm/dd/yy'),'dd-mmm-yyyy')
    mouse = T(i).subject;
    load(['~/Dropbox/MPC/Processed/' mouse '_' filedate '.mat'])
    T(i).d = d;
end

%Find Head out sync right after reward sync. 
%Set up mouse mapping
keySet = mArray;
valueSet = 1:1:numel(mArray);
M = containers.Map(keySet,valueSet);

%% Calculate how long the animal was in the reward port.
for s=1:size(T,2)
    sr=T(s).d.samplerate;
    clear timeDiff
    T(s).HeadInDur = nan(T(s).ntrials,1);
    for i=1:numel(T(s).d.Re1)
        y=find(T(s).d.headOut>T(s).d.Re1(i));
        timeDiff(i,1)=(T(s).d.headOut(y(1))-T(s).d.Re1(i))./sr;
        trialNo = T(s).data.Raw.Reward.trialNumb{1}(i);
        T(s).HeadInDur(trialNo) = timeDiff(i,1);
        T(s).mouseid = M(T(s).subject)*ones((T(s).ntrials),1);
        
    end
end

%Extract the data and concatenate across 
HeadInDur = vertcat(T.HeadInDur);
mouseid = vertcat(T.mouseid);
rewType = vertcat(T.rewardDur);


%For all Reward Contingencies
for r=0:3
%For Each Animal
    for m=1:numel(mArray)
        mHeadInDur(m,r+1) = nanmean(HeadInDur(mouseid==m & rewType==r))
    end
end

%Plot the Data
drink = vertcat(T.HeadInDur);
figure('Position',[264 908 178 148])
colors = rewLightColors(1);
newIdx = [2 1 3 4]; %swap the first two columns so it matches the figure diagram
colors = colors(newIdx,:);
y = nanmean(mHeadInDur(:,newIdx),1);
s = nanstd(mHeadInDur(:,newIdx),[],1)
n = size(mHeadInDur(:,newIdx),1);
b = bar(nanmean(mHeadInDur(:,newIdx),1))
b.FaceColor = 'flat';
b.EdgeColor = 'none';
hold on
err = errorbar(1:1:4,y,s./sqrt(n),'.')
for i=1:4
    b.CData(i,:) = colors(i,:);
    err = errorbar(i,y(i),s(i)./sqrt(n),'Color',colors(i,:),'LineWidth',2)
end
uniformFigureProps();
ylabel('Duration (s)')
xticklabels({})

