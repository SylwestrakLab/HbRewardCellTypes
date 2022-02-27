%% FP dynamics at reward and reward port exit

%Plots a heatmap of all trials, sorted by duration in the reward port
cohorts = {'Th','Tac','chat','calb','LHbCombo'};
protocol = '6';
minHeadInDur = .3;
rewardedTimeWin = 30;
unrewardedTimeWin = 10;
nsamples = 50;

for c = 1:numel(cohorts)
 clearvars -except c cohorts protocol rewardedTimeWin unrewardedTimeWin nsamples minHeadInDur
%if c>4; protocol = '10';end
load([pwd '/datafiles/FP/StandardTask/' cohorts{c} protocol '.mat'])
%Separate Data by Mouse Later
keySet = unique({T.subject});
valueSet = 1:1:numel(keySet);
M = containers.Map(keySet,valueSet);
 
%Cannot extract data from newer files aquired w/ bpod
idx = logical(zeros(size(T)));
for s=1:size(T,2)
if isfield(T(s).d,'headIn')
    idx(s) = 1;
end
end
T = T(idx);

%Find Head out sync right after reward sync to get head in duration 
for s=1:size(T,2)

    sr=T(s).d.samplerate;
    clear timeDiff
    T(s).HeadInDur = nan(numel(T(s).d.headIn),1);
    T(s).rewardedHeadEntry = zeros(numel(T(s).d.headIn),1);
    T(s).unrewardedHeadEntry = zeros(numel(T(s).d.headIn),1);
    
    %Calculate the head exit after each head entry
    
    for i=1:numel(T(s).d.headIn)
        %Get which trial this belongs to
        y=find(T(s).d.headIn(i)>T(s).d.St1);%for this head entry, which start syncs are smaller
        y=y(end); %get the largest of these, which will be the nearest time start
        
        %Save out if it is in an unrewarded trial
        if ~isempty(y)
            rewarded = find(T(s).outcome~=1);
            if ismember(y,rewarded)
            T(s).unrewardedHeadEntry(i) = 1;
            end
        end

        %Get head exit after reward and calculate head in duration and
        %place marker at location in figure
        y2=find(T(s).d.headOut>T(s).d.headIn(i));
        if ~isempty(y2)
            T(s).HeadInDur(i) = (T(s).d.headOut(y2(1))-T(s).d.headIn(i))./sr;
        end
        %Save out subject for easy sorting later
        T(s).mouseID = M(T(s).subject)*ones(numel(T(s).HeadInDur),1);
    end
    
    %Get the head entries that overlap with the reward syncs
    for i=1:numel(T(s).d.Re1)
        [~,y1]=min(abs(T(s).d.headIn-T(s).d.Re1(i)));
        T(s).rewardedHeadEntry(y1)=1;
    end
    
end

%%
%Extract the data from the tdt file using d struct, since this is a much
%longer time window than other analysis.  Zscore and then 
%and concatenate across sessions
sr = T(1).d.samplerate;
for i=1:size(T,2)
    fp = nan(numel(T(i).d.headIn),round(sr*(rewardedTimeWin+1)));
    d = zscore(T(i).d.data);
    He = T(i).d.headIn;
    for j=1:numel(He)
        if numel(d)>round(He(j)+(rewardedTimeWin*sr))
            %try
        fp(j,:) = d(He(j)-round(sr):round(He(j)+((rewardedTimeWin)*sr)-1));
            %end
        end
    end
    T(i).head = fp;
end


%% Concatenate datafiles
dur = vertcat(T.HeadInDur);
head = vertcat(T.head);
ids = vertcat(T.mouseID);

%% Index and Sort - Delivered Trials
%Limit to Correct & Delivered Trials
idx = vertcat(T.rewardedHeadEntry)==1 & dur>minHeadInDur;
head2 = head(idx,:);
dur2 = dur(idx);
idx2 = ids(idx);

%Sort by head in duation
[duration,dursort]=sort(dur2); %Get the order of B
FP=head2(dursort,:);

%Downsample so the figure isn't so large

dsRate = sr/nsamples;
for i=1:size(FP,1)
    dFP(i,:) = dsFP(FP(i,:),nsamples);
end
deliveredFP = dFP;
%% Make a figure
figure('Position',[1000 1165 231 173])
imagesc(dFP);
hold on
scatter((duration+1)*dsRate,1:1:size(FP,1),'.w')

% Figure Properties
%yticks([])
xlim([0 31*dsRate])
xticks(dsRate:10*dsRate:(rewardedTimeWin+1)*dsRate)
xticklabels({'0','10','20','30'})
colormap inferno
caxis([-1 3])
colorbar
uniformFigureProps()

%Colorbar
cb = colorbar;
set(cb,'position',[.92 .65 .03 .25])
set(cb,'YTick',[-1 4])
t=text((rewardedTimeWin+1.5)*dsRate,size(dFP,1)*.75,'Z Score','FontSize',12);
set(t,'Rotation',90)

%Save out File
saveas(gcf, [pwd '/Figure S3/panels/' cohort '_HeadInDuration_Delivered.pdf']) 
close gcf
%% Make a figure with mean
colors = rewLightColors(1);
h = figure('Position',[998 1163 220 175]);
x= linspace(-1, 2, dsRate*3);

data = nan(numel(x),numel(keySet));
for i=1:numel(keySet)
    %restrict to animal
    idx = vertcat(T.rewardedHeadEntry)==1 & dur>minHeadInDur & ids ==i;
    y = dsFP(nanmean(head(idx,:),1),nsamples);
    data(:,i) = y(1:numel(x));
end

%get time win around head entry
n=numel(keySet)
shadedErrorBar(x,nanmean(data,2),nanstd(data,[],2)./sqrt(n),{'Color',colors(2,:)},.8,3)
hold on
uniformFigureProps()



%% Index and Sort - Other Head Entries
%Filter here
idx = vertcat(T.unrewardedHeadEntry)==1 & dur>minHeadInDur; 
head2 = head(idx,:);
dur2 = dur(idx);
%Sort by head in duation
[duration,dursort]=sort(dur2); %Get the order of B
FP=head2(dursort,:);

%Downsample so the figure isn't so large
dsRate = sr/nsamples;
dFP=[];
for i=1:size(FP,1)
    dFP(i,:) = dsFP(FP(i,:),nsamples);
end

withheldFP = dFP;
%% Make a figure
figure('Position',[1000 1165 231 173])
imagesc(dFP);
hold on
scatter((duration+1)*dsRate,1:1:size(FP,1),'.w')

% Figure Properties
yticks([])
xlim([0 unrewardedTimeWin*dsRate]) 
xticks(dsRate:5*dsRate:unrewardedTimeWin*dsRate)
xticklabels({'0','5','10'})
colormap inferno
caxis([-1 3])
uniformFigureProps()

%Colorbar
cb = colorbar;
set(cb,'position',[.92 .65 .03 .25])
set(cb,'YTick',[-1 4])
t=text(( unrewardedTimeWin+1.5)*dsRate,size(dFP,1)*.75,'Z Score','FontSize',12);
set(t,'Rotation',90)
saveas(gcf, [pwd '/Figure S3/panels/' cohort '_HeadInDuration_Unrewarded.pdf']) 
%%
close gcf

%% Make a figure with mean
colors = rewLightColors(1);
figure(h);
x= linspace(-1, 2, dsRate*3);

data = nan(numel(x),numel(keySet));
for i=1:numel(keySet)
    %restrict to animal
    idx = vertcat(T.unrewardedHeadEntry)==1 & dur>minHeadInDur & ids ==i;
    y = dsFP(nanmean(head(idx,:),1),nsamples);
    data(:,i) = y(1:numel(x));
end

%get time win around head entry
n=numel(keySet)
shadedErrorBar(x,nanmean(data,2),nanstd(data,[],2)./sqrt(n),{'Color',colors(1,:)},.8,3)
xline(0,'--k','LineWidth',2)

saveas(gcf, [pwd '/Figure S3/panels/' cohort '_HeadInDuration_timeseries.pdf']) 
end

