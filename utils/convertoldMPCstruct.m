function D = convertoldMPCstruct(T,stage)
D=T;
if isfield(D,'c_MagIso')
D = rmfield(D, 'c_MagIso');   
end   
for f=1:size(T,2)
    ntrials = min([T(f).ntrials numel(T(f).outcome)]);
    D(f).subject  = T(f).subject;
    D(f).ntrials  = ntrials;
    D(f).outcome  = T(f).outcome(1:ntrials);
    try
    D(f).rewardDel  = T(f).rewardDur(1:ntrials);
    catch
    D(f).rewardDel  = T(f).rewardDel(1:ntrials);
    end
    try
    D(f).rewardLat  = T(f).rewLat(1:ntrials);
    catch
        D(f).rewardLat  = T(f).rewardLat(1:ntrials);
    end
    if isfield(T,'respLat')
    D(f).respLat  = T(f).respLat(1:ntrials);
    end
    D(f).trialNum = 1:1:ntrials;
    try
    D(f).stage = T(f).stage;
    catch
       D(f).stage = stage;
    end
    
    if isfield(T,'rewardProb')
        D(f).rewardProb = T(f).RewardProb;
    elseif D(f).stage ==6
        D(f).rewardProb = 1;
    end
    
    syncs = fieldnames(D(1).data.Zscore);
    for s = 1:numel(syncs)
        try
        D(f).(syncs{s}) = nan(ntrials,size(T(f).data.Zscore.Start.FP{1,1}.Zscore.(syncs{s}).FP{1},1));
        D(f).([syncs{s} '_df']) = nan(ntrials,size(T(f).data.Zscore.Start.FP{1,1}.Zscore.(syncs{s}).FP{1},1));
        catch
            if size(T(f).data.Zscore.(syncs{s}).FP{1},1) ==0 
                n = 284;
            else
                n=size(T(f).data.Zscore.(syncs{s}).FP{1},1);
            end
        D(f).(syncs{s}) = nan(ntrials, n);
        D(f).([syncs{s} '_df']) = nan(ntrials, n);
        end
        idx = [T(f).data.Raw.(syncs{s}).trialNumb{:}];
            %if s==1
            %    try
            %    fp = [T(f).data.Raw.(syncs{s}).FP{1,1}.Zscore.(syncs{s}).FP{:}];
            %    catch
            %        fp = [T(f).data.Raw.(syncs{s}).FP{:}];
            %    end
            %end
           
           z = [T(f).data.Zscore.(syncs{s}).FP{:}];
           %Get dF/F 
           if isempty(T(f).pct)
               T(f).pct = T(f).d.fifth_pct;
           end
           
           fp = [T(f).data.Raw.(syncs{s}).FP{:}];
           fp=fp./(T(f).pct(5)-190);
           fp=fp*100;
            for j=1:numel(idx)
                D(f).([syncs{s} '_df'])(idx(j),:)=fp(:,j);
                D(f).(syncs{s})(idx(j),:)=z(:,j);
            end
    end
    try
        filedate = datestr(datenum(T(f).header.Start_Date,'mm/dd/yy'),'dd-mmm-yyyy');
        mouse = T(f).subject;
        load(['~/Dropbox/MPC/Processed/' mouse '_' filedate '.mat']);
        D(f).d = d;
    end

end

%sr rigF time_Win protocol cohort
