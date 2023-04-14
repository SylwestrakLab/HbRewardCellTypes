% This script loads the dataset for a particular cohort (mouse line), and 
%and then identified one session (n) from a particular subject and protocol
%The cued trials from the selected  day is plotted as a headplot, ordered 
%by trial number with t=0 as the onset of the cue. 


function I = grab_session_example(dataDir, cohort, subject, protocol, n)
%Load Data Struct

%Select Data directory

procdir = [dataDir '/FP/*/'];
path = [procdir  cohort protocol '.mat'];
datafile = dir(path);
load(fullfile(datafile.folder,datafile.name),'T', 'time_Win', 'sr','dataUnits')


%Limit to mouse and session number and get data from Cue sync
mice = {T.subject};
idxSession = find(~cellfun(@isempty, strfind(mice,subject))); %get session to find number of trials
T2 = T(idxSession(n));
%data = T2.data.Zscore.Cue.FP;

cued = T2.outcome < 4;
data = T2.Cue(cued,:);


%Get the file date
try
fdate = T2.header.Start_Date;
fdate = datestr(datenum(fdate,'MM/dd/yy'),'dd-mmm-yyyy');
catch
    fdate = datestr(T2.date,'dd-mmm-yyyy');
end

%Plot from t-1 to end of time window
sr = T2.d.samplerate/T2.filterHz;
I=data(:,round((time_Win-1)*sr):end);

%Make plots of equivalent length, since the number of cued trials varies
%with the number of premature responses
if size(I,1)>80
    I=I(1:80,:);
end

%Setup Figure
%h=figure('DefaultAxesFontSize',36,'Position', [-1303 374 314 258]);
h = figure('PaperUnits', 'centimeters', 'Units', 'centimeters','Position',[0 0 1 1.7],'PaperSize',[4 3]);

imagesc(I);

%Get the delay to reward consumption
rewLat = T2.rewLat(cued);
respLat = T2.rewLat(cued);
delay = (respLat+rewLat + 1)*sr; %get delay from cue start

%remove trials where there was no reward
delay(rewLat==0)=nan;

%Plot reward port entry
hold on
scatter(delay,1:1:numel(delay),3,'.w');
xline(sr,':w','LineWidth',1)

%Figure Props
t_end = ((time_Win+1)*sr);
xticks(1:sr:t_end+3)
xlim([1 sr*(time_Win+1)+1])
xticklabels({' ','0',' ','2',' ','4',' ','6',' '});
uniformFigureProps()
ylim([0 size(I,1)])
ylabel('Trials')

%Make perceptually uniform colormap
C = inferno(100);
C(end,:) = [1 1 1];
colormap(C);
cb = colorbar; 
set(cb,'position',[.92 .65 .03 .25])

%Adjust Color Axis
if strcmp(protocol,'7')
    caxis([-1 8])
    %get withheld
    withheld = T2.rewardDur==0;
    correct = T2.outcome==1;
    disappt = find(withheld & cued & correct);  
    hold on
    scatter(ones(numel(c),1)*5, c,3,'.w')
    set(cb,'YTick',[-1 8])
else
    caxis([-1 4])
    set(cb,'YTick',[-1 4])
end

%Label Colorbar
t=text(175,75,'Z Score','FontSize',7)
set(t,'Rotation',90)

%Save Out
%saveas(h, [dataDir '/Figure 2/panels/Example Sessions/' subject '_' fdate '_' '_cue+reward.pdf']) 

end