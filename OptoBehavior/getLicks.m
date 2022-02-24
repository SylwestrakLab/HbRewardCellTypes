function  [lickL, lickR, noLick, firstLick, latency] = getLicks(SessionData)
    %Make empty variables
    nAllTrials = numel(SessionData.TrialTypes);
    firstLick = nan(nAllTrials,1);
    lickL = cell(nAllTrials,1); 
    lickR = cell(nAllTrials,1);
    Cue = nan(nAllTrials,1);
    noLick = zeros(nAllTrials,1);
    latency = nan(nAllTrials,1);
    %iterate through trials
    for t=1:SessionData.nTrials
        %get cue time
        Cue(t) = SessionData.RawEvents.Trial{t}.States.Cue(1);
        
        %Get all Licks for Raster
        y =SessionData.RawEvents.Trial{t}.Events;
        fL = nan(2,1);

        if isfield(y,'Port1In') 
            lickL{t} = y.Port1In-Cue(t);
            fL(1) = y.Port1In(1)-Cue(t);
        end
        if isfield(y,'Port2In') 
            lickR{t} = y.Port2In-Cue(t);
            fL(2) = y.Port2In(1)-Cue(t);
        end
        %Grab latency of first lick
        [lat, idx] = min(fL);     

        %Determine port of first lick
        if any(~isnan(fL))
            latency(t) = lat;
            switch  idx
                case 1
                    firstLick(t)=-1;
                case 2
                    firstLick(t)=1;
            end
        else
            firstLick(t)=0;
        end

        %Get Omitted Trials                   
        if ~isfield(y,'Port1In') && ~isfield(y,'Port2In')
            noLick(t) = 1;
        end
    end
