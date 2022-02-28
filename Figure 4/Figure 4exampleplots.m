cd '~/Dropbox/MHb Figure Drafts/Data/'

%% Make Example session for Figure 4, panel A


cohort = 'Tac'
subject = 'm217'
n=1;
protocol = '6' 
dataUnits = 'Zscore';

load([pwd '/datafiles/FP/StandardTask/' cohort protocol '.mat'],'T')


h=figure('DefaultAxesFontSize',24,'Position', [-1303 374 314 258]);
mice = {T.subject};
idxSession = find(~cellfun(@isempty, strfind(mice,subject))); %get session to find number of trials
trial = T(idxSession(n)).data.(dataUnits).Reward.trialNumb;  %Get Trial Numbers
%trial = horzcat(trial{:});
trial=trial{1};

%Restrict to rewarded trials, depending on protocol
switch protocol
    case '6'
        b=1:numel(trial);
    case 'Extinct'
        b=1:numel(trial);
    case 'RewLight'
        idxDelivered = find(T(idxSession(n)).rewardDur == 1 | T(idxSession(n)).rewardDur == 3)
        [a b c] = intersect(trial, idxDelivered)
    case '50'
        idxDelivered = find(T(idxSession(n)).rewardDur == .2)
        [a b c] = intersect(trial, idxDelivered)       
end

%Get File Date for figure naming
fdate = T(idxSession(n)).header.Start_Date;
fdate = datestr(datenum(fdate,'MM/dd/yy'),'dd-mmm-yyyy');


%Get Data            
data = T(idxSession(n)).data.Zscore.Reward.FP{1}(:,b); 
              
%Truncate long sessions
I=data';
if size(I,1)>90
    I=I(1:90,:)
end

%Make figure
imagesc(I);
t_end = (2*(time_Win)*sr+1);
xticks(1:2*sr:t_end+3)
%xlim([1 sr*(time_Win+1)+1])
xticklabels({' ','0',' ','2',' ','4',' ','6',' '});
prettyAxis()
ylim([0 size(I,1)])

%Make  colormap and set color axis
C = inferno(100);
C(end,:) = [1 1 1];
colormap(C);
if strcmp(cohort,'chat')
    caxis([-1 3])
else
    caxis([-1 4])
end
colorbar

%Set Axis Labels
ylabel('Trial Number')
if strmatch(dataUnits,'Raw')
    text(150,-10,'%\DeltaF/F','FontSize',20)
else
    text(150,-10,'Z Score','FontSize',20)
end
xlabel('Time from cue (s)')
%%

h=figure('Position',[1000 918 268 420])
%h=figure('Position',[1000 918 144 420])
  subplot(1,2,1)
for i=1:5
 ypos = mean(I(i,:)'); 
 y=I(i,:)'-ypos - 5*i
plot(y,'k', 'LineWidth',1)
hold on
scatter(time_Win*sr,y(round(time_Win*sr))+2,30,'b','filled')
axis off
ylim([-30 3])
end

for i=1:5
subplot(1,2,2)
ypos = mean(I(i,:)');  
hold on
y = I(end-5+i,:)' - ypos - 5*i
plot(y,'k', 'LineWidth',1)
scatter(time_Win*sr,y(round(time_Win*sr))+2,30,'b','filled')
axis off
ylim([-30 3])
end
 
hold on

plot([size(I,2)-2*sr, size(I,2)],[-1 -1],'k', 'LineWidth',2)
plot([size(I,2), size(I,2)],[-1 1],'k', 'LineWidth',2)
text(size(I,2)-sr,-2,'2 s','FontSize',18)
text(size(I,2)+0.5*sr,0,'2','FontSize',18)
%text(size(I,2)+2.75*sr,-2,'Z Score','Rotation',90,'FontSize',14)
%saveas(h, ['~/Dropbox/HabenulaData/FP_3CSRTT/Manuscript Panels/Tac1ExampleBuildup_' subject '_' protocol num2str(n) 'firstlast.pdf']) 

% 
% 
idxExtinct = find(trial>30) 
%%
h=figure('Position',[1000 1041 352 297])
  subplot(1,3,1)
for i=1:5
 ypos = mean(I(i,:)');  
plot(I(i,:)'-ypos - 5*i,'k', 'LineWidth',1)
hold on
axis off
ylim([-30 2])
end

for i=1:5
    subplot(1,3,2)
 ypos = mean(I(i,:)');  
plot(I(i+idxExtinct(1)-1,:)'-ypos - 5*i,'k', 'LineWidth',1)
hold on
axis off
ylim([-30 2])
end


for i=1:5
subplot(1,3,3)
ypos = mean(I(i,:)');  
hold on
plot(I(end-5+i,:)' - ypos - 5*i,'k', 'LineWidth',1)
axis off
ylim([-30 2])
end
 
hold on
xlim([0 285])
plot([size(I,2)-2*sr, size(I,2)],[-2 -2],'k', 'LineWidth',1)
plot([size(I,2), size(I,2)],[-2 0],'k', 'LineWidth',1)
text(size(I,2)-1.5*sr,-3.5,'2 s','FontSize',18)
text(size(I,2)+0.5*sr,-.5,'2','FontSize',18)
%text(size(I,2)+2*sr,-2,'Z Score','Rotation',90)
%saveas(h, ['~/Dropbox/HabenulaData/FP_3CSRTT/Manuscript Panels/Tac1ExampleExtinct.pdf']) 
