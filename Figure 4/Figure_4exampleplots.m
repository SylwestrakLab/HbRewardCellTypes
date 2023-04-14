%%  Make example plots for FP across a session in Figure 4
%This script loads the data set for the Tac1 cohort and selects a single
%session to plot as a heat map, restricted to only rewarded trials, and
%sorted according to trial number

%% Make Example session for Figure 4, panel A

cohort = 'Tac';
subject = 'm217';
n=1;
protocol = '6'; 
dataUnits = 'Zscore';


%Select Data directory
dataDir = uigetdir();

%Add the Repo to your path
addpath(genpath('~/Git/HbRewardCellTypes/'))

load([dataDir '/FP/StandardTask/' cohort protocol '.mat'],'T')
%%
%Get correct Trials
mice = {T.subject};
idxSession = findStrInCell(subject,mice); %get session to find number of trials

%Get Correct Trials
correct = T(idxSession(n)).outcome==1;

%Restrict to rewarded trials, depending on protocol
switch protocol
    case '6'
        rewarded = T(idxSession(n)).rewardDur == 0;
    case 'Extinct'
        rewarded = T(idxSession(n)).rewardDur == 1;
    case 'RewLight'
        rewarded = (T(idxSession(n)).rewardDur == 1|T(idxSession(n)).rewardDur == 3);
    case '50'
        rewarded = T(idxSession(n)).rewardDur == .2;
end

%Get Data   
idx = correct & rewarded;
data = T(idxSession(n)).Reward(idx,:);
I=data(:,round((time_Win-2)*sr:(time_Win+6)*sr));

%Make figure
h = figure('PaperUnits', 'centimeters', 'Units', 'centimeters','Position',[0 0 3.4 2.8],'PaperSize',[6 6])
imagesc(I);
t_end = (2*(time_Win)*sr+1);
xticks(1:2*sr:t_end)
xlim([1 sr*(time_Win+1)+1])
xticklabels({'-2','0','2','4','6'});
prettyAxis()
ylim([0 size(I,1)])

%Make  colormap and set color axis
C = inferno(100);
C(end,:) = [1 1 1];
colormap(C);
cb = colorbar; set(cb,'position',[.92 .65 .03 .25]); set(cb,'YTick',[-1 3])
caxis([-1 4])

%Set Axis Labels

if strmatch(dataUnits,'Raw')
    t = text(170,35,'%\DeltaF/F','FontSize',7)
    set(t,'Rotation',90)
else
    t = text(170,35,'Z Score','FontSize',7)
    set(t,'Rotation',90)
end

xlabel('Time from reward (s)')
ylabel('Trial Number')
uniformFigureProps()

%% Grab example first and last 5 trials

h = figure('PaperUnits', 'centimeters', 'Units', 'centimeters','Position',[0 0 4.4 2.8],'PaperSize',[4 3])
subplot(1,2,1)
for i=1:5
%Get the mean value to make y position offset
ypos = mean(I(i,:)'); 
y=I(i,:)'-ypos - 5*i

%Plot at this offset
plot(y,'k', 'LineWidth',.5)
hold on

%Add the time of reward as dot
scatter(2*sr,y(round(time_Win*sr))+2,5,'b','filled')
axis off
end
ylim([-30 3])

for i=1:5
subplot(1,2,2)
%Get the mean value to make y position offset
ypos = mean(I(i,:)');  
hold on
y = I(end-5+i,:)' - ypos - 5*i

%Plot at this offset
plot(y,'k', 'LineWidth',.5)

%Add the time of reward as dot
scatter(2*sr,y(round(time_Win*sr))+2,5,'b','filled')
axis off
end
ylim([-30 3])

%Make Scalebar
plot([size(I,2)-2*sr, size(I,2)],[-1 -1],'k', 'LineWidth',2)
plot([size(I,2), size(I,2)],[-1 1],'k', 'LineWidth',2)
text(size(I,2)-sr,-2,'2 s','FontSize',5)
text(size(I,2)+0.5*sr,0,'2','FontSize',5)
