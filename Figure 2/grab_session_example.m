function I = grab_session_example(cohort, subject, protocol, n)
%Load Data Struct
procdir = [pwd '/data/FP/*/']
path = [procdir  cohort protocol '.mat'];
datafile = dir(path)
load(fullfile(datafile.folder,datafile.name),'T', 'time_Win', 'sr','dataUnits')


%Limit to mouse and session number and get data from Cue sync
mice = {T.subject};
idxSession = find(~cellfun(@isempty, strfind(mice,subject))); %get session to find number of trials
T2 = T(idxSession(n));
data = T2.data.Zscore.Cue.FP;

%Get the file date
try
fdate = T2.header.Start_Date;
fdate = datestr(datenum(fdate,'MM/dd/yy'),'dd-mmm-yyyy');
catch
    fdate = datestr(T2.date,'dd-mmm-yyyy');
end

%combine across trial outcomes and reorder according to trial number
trial = T2.data.Raw.Cue.trialNumb;  %Get Trial Numbers
trial = horzcat(trial{:}); %Concatenate trial numbers
data = horzcat(data{:}); %Concatenate data
[~, idx] = sort(trial); %Sort by trial number
data = data(:,idx);


%Make all plots the same number of trials
I=data((time_Win-1)*sr:end,:)';
if size(I,1)>80
    I=I(1:80,:);
end

%Setup Figure
h=figure('DefaultAxesFontSize',36,'Position', [-1303 374 314 258]);
imagesc(I);

%denote reward port entry
idxCue = sort([T2.data.Raw.Cue.trialNumb{1:3}]) %cue trial numbers, sorted to align w/ 'data' variable
idxReward = T2.data.Raw.Cue.trialNumb{1}; %rewarded trail mumbers
[a b c] = intersect(idxCue, idxReward); 
delay = T2.respLat+T2.rewLat; %get delay from cue start
hold on
scatter(delay(a)*sr+sr, b,'.w');
xline(sr,'--w','LineWidth',2)

%Figure Props
t_end = ((time_Win+1)*sr);
xticks(1:sr:t_end+3)
xlim([1 sr*(time_Win+1)+1])
xticklabels({' ','0',' ','2',' ','4',' ','6',' '});
prettyAxis()
ylim([0 size(I,1)])
ylabel('Trials')

%Make perceptually uniform colormap
C = inferno(100);
C(end,:) = [1 1 1];
colormap(C);

%Adjust Color Axis
cb = colorbar; 
set(cb,'position',[.92 .65 .03 .25])
if strcmp(protocol,'7')
    caxis([-1 8])
    %get withheld
    withheld = (T2.rewardDur==0);
    
    %get cue trials
    cue = zeros(numel(T2.rewardDur),1);
    idxCue = sort([T2.data.Raw.Cue.trialNumb{:}]);
    cue(idxCue)=1;
    
    %get correct trials
    correct = zeros(numel(T2.rewardDur),1);
    idxCorrect = T2.data.Raw.Cue.trialNumb{1}
    correct(idxCorrect) = 1;
    
    disappt = find(withheld & cue & correct);
    [a,b,c] =intersect(disappt,idxCue)
    
    
    hold on
    scatter(ones(numel(c),1)*5, c,12,'.w')
    set(cb,'YTick',[-1 8])
else
caxis([-1 4])
set(cb,'YTick',[-1 4])
end
colorbar

%Label Colorbar
if strmatch(dataUnits,'Raw')
    t=text(100,50,'%\DeltaF/F','FontSize',12,'TextAngle',90)
else
    t=text(175,50,'Z Score','FontSize',12)
end
set(t,'Rotation',90)


%Save Out
saveas(h, [pwd '/Figure 2/panels/Example Sessions/' subject '_' fdate '_' '_cue+reward.pdf']) 

end