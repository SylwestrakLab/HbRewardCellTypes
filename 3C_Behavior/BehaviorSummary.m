%% Plot basic parameters of 3-Choice behavior for figure 1 and figure S2

%Load struct containing all behavioral filenames and extracted K arrays
%from MPC program. 
load([pwd '/data/behaviorFiles/3ChoiceBehavior.mat'])

%Convert subject names to numerical ids for easier sorting
mArray1 = get_mice('FP_Oregon');
mArray2 = get_mice('FP_Stanford');
mArray = [mArray1, mArray2];
keySet = mArray;
valueSet = 1:1:numel(mArray);
M = containers.Map(keySet,valueSet);

% Set order to chronological
[dates, idx] = sort(vertcat(allbehaviorFiles.bdate),'ascend');
allbehaviorFiles = allbehaviorFiles(idx);

%Determine when animals met criterion.  Plot performance v stage#
criterion=[30 0 100; 30 0 100; 50 0 100; 50 80 100; 50 80 30; 50 80 30];
stagePerformance = nan(4,6,numel(mArray));
for s = 1:6
    idx = find([allbehaviorFiles.stage]==s);
    D = allbehaviorFiles(idx);
    
    %Get behavior from each mouse to identify stage transitions
    for m=1:numel(mArray)
        mouse = mArray{m}
        idxMouse = findStrInCell(mouse,{D.subject});
        if ~isempty(idxMouse)
        D2 = D(idxMouse);
        p = vertcat(D2.performance);
        
            %Determine when animal passes the criterion and add to array
            if s<6
                stagePerformance(:,s,m) = nanmean(p,1)
            else
                c = p(:,1)>criterion(s-3,1);
                a = (p(:,1)./(p(:,1)+p(:,2)))*100>criterion(s-3,2);
                o = p(:,3)<criterion(s-3,3);
                toCrit =find(c & a & o);
                twoSession = find(diff(toCrit)<2);
                if ~isempty(twoSession)
                    stagePerformance(:,s,m) = nanmean(p(toCrit(twoSession):end,:),1); 
                elseif ~isempty(toCrit)
                    stagePerformance(:,s,m) = nanmean(p(toCrit(twoSession),:),1); 
                end
            end
        end
    end
end

%% Plot Graph of Performance vs Stage
figure
mstagePerformance = nanmean(stagePerformance,3)
b = bar(mstagePerformance','stacked','BarWidth',.6);
c=mhbColors(2);
for i=1:4
    b(i).FaceColor = c(i,:);
end
uniformFigureProps();
saveas(gcf, [pwd '/3C_Behavior/' cohortName '/' cohortName '_PerformanceVStage.pdf']); 

%% Calculate Sessions per stage

criterion=[50 80 100;50 80 20;50 80 30];
nSessions = nan(6,numel(mArray));
for s = 1:6
    idx = find([allbehaviorFiles.stage]==s);
    D = allbehaviorFiles(idx);
    
    %Get behavior from each mouse to identify stage transitions
    for m=1:numel(mArray)
        mouse = mArray{m};
        idxMouse = findStrInCell(mouse(2:end),{D.subject});
        if ~isempty(idxMouse)
        D2 = D(idxMouse);
        p = vertcat(D2.performance);
        
        if s<4
            nSessions(s,m) = size(p,1)
        else
            %Determine when animal passes the criterion and add to array
            c = p(:,1)>criterion(s-3,1);
            a = (p(:,1)./(p(:,1)+p(:,2)))*100>criterion(s-3,2);
            o = p(:,3)<criterion(s-3,3);
            toCrit =find(c & a & o);
            twoSession = find(diff(toCrit)<2);
            if ~isempty(twoSession)
                nSessions(s,m) = toCrit(twoSession(1));   
            elseif ~isempty(toCrit)
                nSessions(s,m) = toCrit(1);  
            end
        end
        end
    end
end

%Plot #Sessions per Stage
figure('Position',[1000 1135 253 203])
bar(nanmean(nSessions,2),'k')
uniformFigureProps()

saveas(gcf, [pwd '/3C_Behavior/' cohortName '/' cohortName '_SessionsVStage.pdf']); 


%% Make Animal IDs for easier means across animals

for f = 1:numel(allbehaviorFiles)
    str = split(allbehaviorFiles(f).name,'_');
    ID = M(allbehaviorFiles(f).subject);
    allbehaviorFiles(f).subjID = ID*ones(size(allbehaviorFiles(f).kArray,1),1);
    allbehaviorFiles(f).stageID = allbehaviorFiles(f).stage*ones(size(allbehaviorFiles(f).kArray,1),1);
end


%% Extract data from struct. mouseiD and stage can be used for logical indexing into K array
mouseID = vertcat(allbehaviorFiles.subjID);
K = vertcat(allbehaviorFiles.kArray);
stage = vertcat(allbehaviorFiles.stageID);


%% Calculate Accuracy vs Port Location
%Get outcomes
trained = stage>5;
location = K(:,2);
correct = K(:,4)~=0;
incorrect = K(:,5)~=0;

%Calculate Accuracy
accuracy = nan(numel(mArray),3);
for l=2:4
    for m=1:numel(mArray)
        cor = sum(correct & location==l & mouseID ==m & trained);
        incor = sum(incorrect & location==l & mouseID ==m & trained);
        accuracy(m,l-1) = cor/(cor+incor)*100;
    end
end

%Plot
figure('Position',[1000 1135 253 203])
bar(nanmean(accuracy,1),'k')
hold on
plot(accuracy','Color',[.7 .7 .7])
uniformFigureProps()
xlabel('Port Location')
xticklabels({'Left','Center','Right'})
ylabel('Accuracy')
saveas(gcf, [pwd '/3C_Behavior/' cohortName '/' cohortName '_LocationVAccuracy.pdf']); 



%% Calculate Nosepoke Location vs Response Latency

%Get outcomes
trained = stage==5;
location = K(:,2);
correct = K(:,4)~=0;
lat = K(:,4);

%Calculate Latency
latency = nan(numel(mArray),3);
for l=2:4
    for m=1:numel(mArray)
        corIdx = find(correct & location==l & mouseID ==m & trained);
        latency(m,l-1) = mean(lat(corIdx));
    end
end

%Plot
figure('Position',[1000 1135 253 203])
bar(nanmean(latency,1),'k')
hold on
plot(latency','Color',[.7 .7 .7])
uniformFigureProps()
xlabel('Port Location')
xticklabels({'Left','Center','Right'})
ylabel('Latency')

saveas(gcf, [pwd '/3C_Behavior/' cohortName '/' cohortName '_LocationVLatency.pdf']); 


%% Plot the Lick Distribution
prematureLatency = K(:,14)./ K(:,20);
premature = {};
figure('Position',[1000 974 601 364])
for s = 1:6
    %Get Pokes
    thisStage = stage==s;
    pokes = find(prematureLatency>0 & thisStage);
    premature{s} = prematureLatency(pokes);
    
    %Plot
    subplot(2,3,s)
    histogram(premature{s},0:.1:1,'FaceColor',[.7 .7 .7],'EdgeColor',[.6 .6 .6])
    uniformFigureProps();
    title({['Stage ' num2str(s)]})
end

saveas(gcf, [pwd '/3C_Behavior/' cohortName '/' cohortName '_PrematPokeDist.pdf']); 

save('/Users/emily/Documents/GitHub/HbRewardCellTypes/data/behaviorFiles/3ChoiceBehavior.mat','allbehaviorFiles')