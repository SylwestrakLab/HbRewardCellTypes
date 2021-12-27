function [R, S, L] = getStayShift(D,cohort,outcome)

%outcoming indicates win-stay / lose-shift
%outcome=0, lose shift
%outcome=1, win stay

mArray = get_mice(cohort);
maxTransitionCount = D(1).maxTransitionCount;

R=nan(6,2);
S=nan(6,2);
L=nan(6,2);

%For each stim type, i.e. laser condtion
for stimType = [0 1]
%%% Get Probability for  Trials
for m=1:numel(mArray)
    %Get Sessions From This mouse
    idxMouse = findStrInCell(mArray{m},{D.subject});
    D2 = D(idxMouse);
    nSessions = size(D2,2);
    nStim = max(cellfun(@(n) size(n,1),{D.stimTransitions}));
    nNoStim = max(cellfun(@(n) size(n,1),{D.nostimTransitions}));
    nMaxSwitches = max([nStim,nNoStim]);
   
    response = nan(nSessions,nMaxSwitches);
    switches =  nan(nSessions,nMaxSwitches);
    latencies =  nan(nSessions,nMaxSwitches);
    %Iterate through each session for this mouse
    for i = 1:nSessions
        if ~isempty(D2(i).transitions)
            
            %Get the stim conditions for each transition
            SB = D2(i).StimBlock(1:size(D2(i).transitions,1));
            idxBlock = find(SB==stimType);
            
            %remove first 3 and final block switches to remove no stim
            %bias from helper trials
            idxBlock = idxBlock(idxBlock>3 & idxBlock<numel(SB));
            
           
            %Limit to Blocks with this stim condition
            t = D2(i).transitions(idxBlock,:);
            r = D2(i).responded(idxBlock,:);
            l = D2(i).latArray(idxBlock,:);  
            
            %Doublecheck that these are the same blocks previously
            %selected for stim and no stim
            
            switch stimType
                case 0
                    t_check = D2(i).nostimTransitions;
                case 1
                    t_check = D2(i).stimTransitions;
            end
            if t_check ~= t
                error('data does not match.  check transitions')
            end
            
            %Make empty variables
            switchArray = nan(size(t,1),1);
            futureResponse = nan(size(t,1),1);
            winLatency = nan(size(l,1),1);
            
            %for each transition, find the correct/rewarded trials and get
            %result of following trial
            for j=1:size(t,1)
                idx = find(t(j,1:maxTransitionCount-1)==outcome);
                if ~isempty(idx)
                            switchArray(j,1) = t(j,idx(1)+1);
                            futureResponse(j,1) = r(j,idx(1)+1);
                            winLatency(j,1) = l(j,idx(1)+1);
                            switches(i,j) = t(j,idx(1)+1);
                            response(i,j) = r(j,idx(1)+1);
                            latencies(i,j) = l(j,idx(1)+1);
                            
                end
            end
        end
    end
    if ~isempty(switches)
    R(m,stimType+1) = nanmean(response(:));
    S(m,stimType+1) = nanmean(switches(:));
    L(m,stimType+1) = nanmean(latencies(:));
    end
end

end