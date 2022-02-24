%% FP dynamics at reward and reward port exit

%Plots a heatmap of all trials, sorted by duration in the reward port
cohorts = {'Th','Tac','chat','calb','LHbCombo'};
protocol = 'RewLight';
for c = 1:4%numel(cohorts)
 clearvars -except c cohorts protocol
if c>4; protocol = '10';end
load([pwd '/data/FP/WithheldRewards/' cohorts{c} protocol '.mat'])
    
    
%Find Head out sync right after reward sync to get head in duration 
for s=1:size(T,2)
    
    sr=T(s).d.samplerate;
    clear timeDiff
    T(s).HeadInDur = nan(T(s).ntrials,1);
    for i=1:numel(T(s).d.Re1)
        try
        y=find(T(s).d.headOut>T(s).d.Re1(i));
        timeDiff(i,1)=(T(s).d.headOut(y(1))-T(s).d.Re1(i))./sr;
        trialNo = T(s).data.Raw.Reward.trialNumb{1}(i);
        T(s).HeadInDur(trialNo) = timeDiff(i,1);
        end
    end
end

%%
%Extract the data from the tdt file, since this is a much
%longer time window than other analysis.  Zscore and then 
%and concatenate across sessions
sr = T(1).d.samplerate;
for i=1:size(T,2)
    fp = nan(T(i).ntrials,round(sr*31));
    d = zscore(T(i).d.data);
    Re = T(i).d.Re1;
    trailNo = T(i).data.Raw.Reward.trialNumb{1};
    for j=1:numel(Re)
        if numel(d)>round(Re(j)+(30*sr))
            try
        fp(trailNo(j),:) = d(Re(j)-round(sr):round(Re(j)+(30*sr)));
            end
        end
    end
    T(i).head = fp;
end

%% Index and Sort - Delivered Trials
%Limit to Correct & Delivered Trials
dur = vertcat(T.HeadInDur);
head = vertcat(T.head);
idx = vertcat(T.outcome)==1 & vertcat(T.rewardDur)==1;
head = head(idx,:);
dur = dur(idx);

%Sort by head in duation
[duration,dursort]=sort(dur); %Get the order of B
FP=head(dursort,:);

%Downsample so the figure isn't so large
nsamples = 50
dsRate = sr/nsamples;
for i=1:size(FP,1)
    dFP(i,:) = dsFP(FP(i,:),nsamples);
end

%% Make a figure
figure('Position',[1000 1165 231 173])
imagesc(dFP);
hold on
scatter(duration*dsRate,1:1:size(FP,1),'.w')

% Figure Properties
yticks([])
xlim([0 11*dsRate])
xticks([dsRate:10*dsRate:31*dsRate])
xticklabels({'0','10','20','30'})
colormap inferno
caxis([-1 3])
colorbar
uniformFigureProps()

%Save out File
saveas(gcf, [pwd '/Figure S3/panels/' cohort '_HeadInDuration_Delivered.pdf']) 

%%


%% Index and Sort - Withheld Trials
%Limit to Correct & Delivered Trials
dur = vertcat(T.HeadInDur);
head = vertcat(T.head);
idx = vertcat(T.outcome)==1 & vertcat(T.rewardDur)==0;
head = head(idx,:);
dur = dur(idx);

%Sort by head in duation
[duration,dursort]=sort(dur); %Get the order of B
FP=head(dursort,:);

%Downsample so the figure isn't so large
nsamples = 50
dsRate = sr/nsamples;
dFP=[];
for i=1:size(FP,1)
    dFP(i,:) = dsFP(FP(i,:),nsamples);
end

%% Make a figure
figure('Position',[1000 1165 231 173])
imagesc(dFP);
hold on
scatter((duration+1)*dsRate,1:1:size(FP,1),'.w')

% Figure Properties
yticks([])
xlim([0 11*dsRate])
xticks([dsRate:5*dsRate:11*dsRate])
xticklabels({'0','5','10'})
colormap inferno
caxis([-1 3])
colorbar
uniformFigureProps()

saveas(gcf, [pwd '/Figure S3/panels/' cohort '_HeadInDuration_Withheld.pdf']) 

close all
end