
%purpose:  to get correct, incorrect, omitted and premature responses from
%the K array to track cohort performance across sessions.
%Find all files for an individual mouse
% Specify the folder where the files live.

%% Get Behavior Struct for Stanford Files
dataDir = '~/Dropbox/MPC/Processed/Behavior/';
behaviorFiles =[]; 
mArray = get_mice('FP_Stanford')
%mArray = get_mice('presurgical')
cohortName = 'All_FP';
%cohortName = 'Unimplanted';


for i=1:numel(mArray)
    mouse = mArray{i};
    behaviorFiles = [behaviorFiles; dir(fullfile(dataDir,['*' mouse(2:end) '*']))]
end


idxRemove=[];
for f=1:numel(behaviorFiles)
    load(fullfile(behaviorFiles(f).folder,behaviorFiles(f).name));
    if size(p.K,2)~=5001 & size(p.K,2)>1 %ignore blank sessions
        %Get K Array
        p = reshapeKarray(p);
       
        %Get Stage
        s = p.header.MSN;
        idx = strfind(s,'age') +3;
        if ~isempty(idx)
            behaviorFiles(f).stage = str2num(s(idx));
        elseif ~isempty(strfind(s,'RewLight'))
            behaviorFiles(f).stage = 10;
        else
            behaviorFiles(f).stage = 0;
        end
        
%         %Remove withheld Days
%         idxRew = strfind(s,'Rew');
%         if ~isempty(idxRew)
%             idxRemove = [idxRemove f];
%         end
        %Get Start Date
        behaviorFiles(f).bdate = datenum(p.header.Start_Date,'mm/dd/yy');
        
        %Get Performance
        K = p.K;
        behaviorFiles(f).kArray =K;
        if size(K,1)>80
             trialEnd = 80;
        elseif size(K,1)<30
            idxRemove = [idxRemove f];
            trialEnd = size(K,1);
        else
             trialEnd = size(K,1);
        end
        %Get the data from the K array
        performance(1) = numel(find(K(1:trialEnd,4)));
        performance(2)= numel(find(K(1:trialEnd,5)));
        performance(3)= numel(find(K(1:trialEnd,7)));
        performance(4)= numel(find(K(1:trialEnd,17)));
        trials = sum(performance);
        performance = performance/trials*100; 
        behaviorFiles(f).performance = performance;
        str = split(behaviorFiles(f).name,'_');
        behaviorFiles(f).subject = str{1};
    else
        idxRemove = [idxRemove f];
    end 
 
end
behaviorFiles(idxRemove)=[];

% Do not include first session back from a break
idxRemove = [];
    for a=1:numel(mArray)
        idxMouse = findStrInCell(mArray{a},{behaviorFiles.subject});
        [dates, idx] = sort(vertcat(behaviorFiles(idxMouse).bdate),'ascend');
        idxGap = find(diff(dates)>2)+1
        idxRemove = [idxRemove idxMouse(idx(idxGap))];
    end

behaviorFiles(idxRemove) = []

%add 'm' onto 
idxRemove=[];
for f=1:numel(behaviorFiles)
    if ~strcmp(behaviorFiles(f).name(1),'m')
        behaviorFiles(f).name =['m' behaviorFiles(f).name];
    end
    if ~strcmp(behaviorFiles(f).subject(1),'m')
        behaviorFiles(f).subject = ['m' behaviorFiles(f).subject];
    end
    %Remove second session of the day, if one was run
    str = split(behaviorFiles(f).name,'_')
    if strcmp(str{1}(end),'b')
        idxRemove = [idxRemove f];
    end
end
behaviorFiles(idxRemove) = [];
%% Get Behavior Struct for Oregon Files
%Get All the Files
mArray = get_mice('FP_Oregon');
bpodDir = '~/Dropbox (University of Oregon)/UO-Sylwestrak Lab/Bpod Local/Data/';
bpodFiles = [];
for i=1:numel(mArray)
bpodFiles = [bpodFiles; dir(fullfile(bpodDir, mArray{i},'Light_3CSRTT_spatial*','Session Data','*.mat'))];
end

%Add in their aquisition date and convert to K array format
for f=1:numel(bpodFiles)
    d = split(bpodFiles(f).name,'_');
    if numel(d)==7
        bpodFiles(f).bdate = datenum(d{6},'yyyymmdd');
    elseif numel(d) ==6
        bpodFiles(f).bdate = datenum(d{5},'yyyymmdd');
    end
    
    %Convert bpod format to old MPC format to combine data
    load(fullfile(bpodFiles(f).folder,bpodFiles(f).name));
    K = bpod2mpc(SessionData);
    bpodFiles(f).kArray =K;
    
    %Get the data from the K array
    if size(K,1)>80
         trialEnd = 80;
    elseif size(K,1)<50
        idxRemove = [idxRemove f];
        trialEnd = size(K,1);
    else
         trialEnd = size(K,1);
    end
    performance(1) = numel(find(K(1:trialEnd,4)));
    performance(2)= numel(find(K(1:trialEnd,5)));
    performance(3)= numel(find(K(1:trialEnd,7)));
    performance(4)= numel(find(K(1:trialEnd,17)));
    trials = sum(performance);
    performance = performance/trials*100; 
    bpodFiles(f).performance = performance;
    bpodFiles(f).subject = d{1};
    bpodFiles(f).stage = SessionData.Stage;
    
    
end

% Do not include first session back from a break (Oregon)
idxRemove = [];
    for a=1:numel(mArray)
        idxMouse = findStrInCell(mArray{a},{bpodFiles.subject});
        [dates, idx] = sort(vertcat(bpodFiles(idxMouse).bdate),'ascend');
        idxGap = find(diff(dates)>2)+1
        idxRemove = [idxRemove idxMouse(idx(idxGap))];
    end

bpodFiles(idxRemove) = [];

%% Combine both data sets
mArray1 = get_mice('FP_Oregon');
mArray2 = get_mice('FP_Stanford');
mArray = [mArray1, mArray2];
allbehaviorFiles = [behaviorFiles; bpodFiles];
