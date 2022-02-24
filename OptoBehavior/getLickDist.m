function [stimLicks, nostimLicks, trialCount] = getLickDist(D,cohort)

mArray = get_mice(cohort);
nMice = numel(mArray);

%Keep track of how many stim an no stim trials there are for normalization
trialCount=ones(nMice,2);

nostimLicks = cell(nMice,2);
stimLicks = cell(nMice,2);


for m=1:nMice
    %Grab data from this mouse
    idxFiles = findStrInCell(mArray{m},{D.subject});
        
    %iterate through multiple sessions   
    for j=1:numel(idxFiles)
        f = idxFiles(j);
        
        %%%%Get the indicies of "correct" trials for "laser OFF" condition
        idxStim = find((D(f).firstLick == D(f).ActivePort')&~D(f).stimDelievered');
        
        %Get indices of trials at start of no stim transitions
        idxTran = D(f).idxTransition(~D(f).StimBlock);
        
        %iterate through each stimulated transition
        if ~isempty(idxTran)
            for i=1:numel(idxTran)
                %Find the first would-be trial after the transition
                firstStimIdx = idxStim(idxStim>idxTran(i) & idxStim<idxTran(i)+9);
                if ~isempty(firstStimIdx)
                    %get left and right lick array for first trial
                    nostimLicks{m,1} = [nostimLicks{m,1} [D(f).lickR{firstStimIdx((1))}] [D(f).lickL{firstStimIdx((1))}]];

                    % And the arrays for the next trial
                    nostimLicks{m,2} = [nostimLicks{m,2} [D(f).lickR{firstStimIdx((1))+1}] [D(f).lickL{firstStimIdx((1))+1}]];

                    %Add this trial to the count for normalization
                    trialCount(m,1)  = trialCount(m,1) +1;
                end
            end
        end 
        
        %%%%%Get the  "correct" trials that the  "laser ON" condition
        idxStim = find((D(f).firstLick == D(f).ActivePort')&D(f).stimDelievered');
        
        %Get indices of trials at start of stim transitions
        idxTran = D(f).idxTransition(D(f).StimBlock);
        
        %iterate through each stimulated transition
        if ~isempty(idxTran)
            for i=1:numel(idxTran)
                %Find the first stim trial after the transition
                firstStimIdx = idxStim(idxStim>idxTran(i) & idxStim<idxTran(i)+10) ;
                
                %if one exists, get the lick array for that trial and the
                %next trial
                if ~isempty(firstStimIdx)
                        %if one exists, get left and right lick array for the first trial
                        stimLicks{m,1} = [stimLicks{m,1} [D(f).lickR{firstStimIdx(1)}] [D(f).lickL{firstStimIdx(1)}]];
                        
                        % And the arrays for the next trial
                        stimLicks{m,2} = [stimLicks{m,2} [D(f).lickR{firstStimIdx(1)+1}] [D(f).lickL{firstStimIdx(1)+1}]];
                        
                        %Add this trial to the count for normalization
                        trialCount(m,2)  = trialCount(m,2) +1;
                end
            end
        end        
    end
end

